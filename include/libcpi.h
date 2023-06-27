#ifndef LIBCPI_H
#define LIBCPI_H
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define CPI_ERROR 0xcafe
#define CPI_SUPPORT_SIZE 0x4000

typedef uint64_t u64;

int __attribute__((constructor)) cpi_init(void);
int cpi_protect(void*);
int cpi_check(void*);
#endif  // LIBCPI_H
