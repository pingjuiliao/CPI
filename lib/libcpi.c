#define _GNU_SOURCE
#include "libcpi.h"

#include <asm/prctl.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <unistd.h>



int init_gs_base(size_t size) {
  void* gs_base = mmap(NULL, size, PROT_READ|PROT_WRITE, 
                       MAP_ANONYMOUS|MAP_PRIVATE, 0, 0);
  return syscall(SYS_arch_prctl, ARCH_SET_GS, gs_base);
}

int __attribute__((constructor)) cpi_init(void) {
  int r;
  void* safe_region =  mmap(NULL, SAFE_REGION_SIZE, 
                            PROT_READ|PROT_WRITE, 
                            MAP_ANONYMOUS|MAP_PRIVATE,
                            0, 0);
  printf("gsbase: %p\n", safe_region);
  memset(safe_region, 0, SAFE_REGION_SIZE);
  r = syscall(SYS_arch_prctl, ARCH_SET_GS, safe_region);
  if (r != 0) {
    fprintf(stderr, "set gs error\n");
    exit(-1);
  }
  safe_region = NULL;
  return 0;
}

int cpi_ptr_store(void* ptr) {
  void* entry;
  u64 pd_off, pt_off;
  // printf("%p, %lu\n", ptr, (u64)ptr >> 21);
  asm volatile(
    "movq %[ptr], %[pd_off];"
    "shrq $21, %[pd_off];"
    "movq %[ptr], %[pt_off];"
    "andq $0x1fffff, %[pt_off];"
    "movq %%gs:0x0(%[pd_off]), %[entry];"
    : [pd_off] "=r"(pd_off),
      [pt_off] "=r"(pt_off),
      [entry] "=r"(entry)
    : [ptr] "r"(ptr)
  );

  if (entry == 0) {
    entry = mmap(NULL, SUPERPAGE,
                 PROT_READ|PROT_WRITE,
                 MAP_ANONYMOUS|MAP_PRIVATE, 0, 0); 
    asm volatile(
      "mov %[entry], %%gs:0x0(%[pd_off]);"
      : /*no output*/
      : [entry] "r"(entry),
        [pd_off] "r"(pd_off)
    );
  }
  asm volatile(
    "leaq (%[entry], %[pt_off]), %[pt_off];"
    "movq (%[ptr]), %%r11;"
    "movq %%r11, (%[pt_off]);"
    : /*no output*/
    : [ptr] "r"(ptr),
      [pt_off] "r"(pt_off),
      [entry] "r"(entry)
  );
  return 0;
}


int cpi_ptr_check(void* ptr) {
  u64 result = 0;
  u64 before = 0;
  asm volatile(
    "movq %[ptr], %%r10;"
    "shrq $21, %%r10;"
    "movq %%gs:0x0(%%r10), %%r10;"
    "movq %[ptr], %%r11;"
    "andq $0x1fffff, %%r11;" 
    "movq (%[ptr]), %[result];"
    "xorq (%%r10, %%r11), %[result];"
    : [result] "=r"(result)
    : [ptr] "r"(ptr)
  );

  printf("check result: %p\n", (void *)result);
  if (result != 0) {
    fprintf(stderr, "[FATAL] CPI check failed\n");
    asm volatile (
      "movq (%[ptr]), %[before];"
      "xorq %[result], %[before];"
      : [before] "=r"(before)
      : [ptr] "r"(ptr),
        [result] "r"(result)
    );
    fprintf(stderr, " before: %p\n", (void *)(before));
    fprintf(stderr, " after : %p\n", *(void **)(ptr));
    return CPI_ERROR;
  }
  return result;
}

