#define _GNU_SOURCE
#include "libcpi.h"

#include <asm/prctl.h>
#include <sys/mman.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <unistd.h>


void* read_stack_ptr() {
  void* rsp;
  asm volatile(
    "mov %%rsp, %[rsp]"
    : [rsp] "=r"(rsp)
    :
  );
  return rsp;
}

int __attribute__((constructor)) cpi_init(void) {
  int r;
  void* gsbase = 0;
  void* safe_stack_p = 0;
  u64 stack_base = 0;
  u64 safe_stack_offset = 0;

  // set gsbase 
  gsbase = mmap(NULL, 
                0x1000,
                PROT_READ|PROT_WRITE,
                MAP_ANONYMOUS|MAP_PRIVATE, 0, 0);
  r = syscall(SYS_arch_prctl, ARCH_SET_GS, gsbase);
  if (r == 0) {
    fprintf(stderr, "set gsbase failed\n");
  }

  // calculate stack base
  stack_base = ((u64) read_stack_ptr()) & ((u64)~0xfff);
  printf("stack base: %p\n", (void*)stack_base);
  
  // safe stack pointer
  safe_stack_p = mmap(NULL, 
                      CPI_SUPPORT_SIZE, 
                      PROT_READ|PROT_WRITE|PROT_EXEC, 
                      MAP_ANONYMOUS|MAP_PRIVATE, 0, 0);
  if (!safe_stack_p) {
    fprintf(stderr, "CPI initialization failed\n");
    return -1;
  }
  
  // safe stack offset
  safe_stack_offset = (u64)safe_stack_p - stack_base;
    printf("stack offset: %p\n", (void*)safe_stack_offset);

  asm volatile (
    "mov %[safe_stack_p], %%gs:0x20;"
    "mov %[safe_stack_offset], %%gs:0x28;"
    : /* no output */
    : [safe_stack_p] "r"(safe_stack_p),
      [safe_stack_offset] "r"(safe_stack_offset)  
  );

  return 0;
}

int cpi_protect(void* code_ptr) {
  asm volatile(
    "mov %%gs:0x28, %%r10;"
    "mov (%[code_ptr]), %%r11;"
    "mov %%r11, (%%r10, %[code_ptr]);"
    : /* no output */
    : [code_ptr] "r"(code_ptr)
  );
  return 0; 
}

int cpi_check(void* code_ptr) {
  u64 result = 0;
  u64 before = 0;

  asm volatile(
    "mov %%gs:0x28, %%r10;"
    "mov (%[code_ptr]), %[result];"
    "xor (%%r10, %[code_ptr]), %[result];"
    : [result] "=r"(result)
    : [code_ptr] "r"(code_ptr)
  );
  printf("check result: %p\n", (void *)result);
  if (result != 0) {
    fprintf(stderr, "[FATAL] CPI check failed\n");
    asm volatile (
      "mov %%gs:0x28, %%r10;"
      "mov (%%r10, %[code_ptr]), %[before];"
      : [before] "=r"(before)
      : [code_ptr] "r"(code_ptr)
    );
    fprintf(stderr, " before: %p\n", (void *) before);
    fprintf(stderr, " after : %p\n", *(void **)(code_ptr));
    return CPI_ERROR;
  }
  return 0;
}

