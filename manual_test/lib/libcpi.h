#ifndef LIBCPI_H
#define LIBCPI_H
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define CPI_ERROR 0xcafe
#define CPI_SUPPORT_SIZE 0x4000

#define SUPERPAGE (1 << 21)
#define BLOCKSIZE 8
#define SAFE_REGION_SIZE (1 << (48 - 21)) /* BLOCKSIZE / 8 */
#define SAFE_REGION_ENTRIES (SAFE_REGION_SIZE >> 3)

typedef uint64_t u64;

typedef struct _SafeRegion {
  u64 entry[SAFE_REGION_ENTRIES];
} SafeRegion;

int __attribute__((constructor)) cpi_init(void);

// for safe region
int cpi_ptr_store(void*);
int cpi_ptr_check(void*);

#endif  // LIBCPI_H
