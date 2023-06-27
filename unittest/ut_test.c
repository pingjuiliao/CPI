#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>
#include "libcpi.h"


#define TEST(X, S) { fprintf(stdout, S); X(); }

void test_switch_jt(void) {
  char chr;
  scanf("%c", &chr);
  switch(chr) {
    case 'a':
    case 'A':
      puts("A for apple");
      break;
    case 'b':
    case 'B':
      puts("B for bird");
      break;
    case 'c':
    case 'C':
      puts("C for cat");
      break;
    case 'd':
    case 'D':
      puts("D for dog");
      break;
    case 'e':
    case 'E':
      puts("E for elite");
      break;
    case 'f':
    case 'F':
      puts("F for flower");
      break;
    default:
      puts("character not handled");
      break;
  }
}

typedef struct _Printable {
  char buffer[8];
  int (*print_func)(const char*);
} Printable;

void test_bufovfl(jmp_buf jb) {
  int r = 0;
  Printable ptb;
  ptb.print_func = puts;
  cpi_protect(&ptb.print_func);
  printf(" printf_func b4: %p\n", ptb.print_func);

  strcpy((char *)&ptb.buffer, "12345678abcdefgh12345678abcdefgh");
  printf(" printf_func after: %p\n", ptb.print_func);

  r = cpi_check(&ptb.print_func);
  if (r == CPI_ERROR) {
    longjmp(jb, 1);
  }
  ptb.print_func((const char *)&ptb.buffer);
}

void testcase(void (*func)(jmp_buf), char* name) {
  jmp_buf jb;
  int val;
  printf("\n[Testing] %s\n", name);
  val = setjmp(jb);
  if (val == 0) {
    func(jb);
  }
  return;
}

int main(int argc, char** argv) {
  // test_init();
  // test_bufovfl();
  testcase(test_bufovfl, "buffer overflow into code pointer");
  puts("Bye!");
  return 0;
}



