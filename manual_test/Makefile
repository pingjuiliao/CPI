BIN_DIR=../llvm-project/build/bin
CC=$(BIN_DIR)/clang
CXX=$(BIN_DIR)/clang++
OPT=$(BIN_DIR)/opt

CFLAGS=-m64
EMIT_FLAGS=-S -emit-llvm
LD_LIB=-L. -lCPI -Wl,-rpath,.
.PHONY: all clean libCPI


testcases := heap_printable.exe heap_printable.ll
#testcases += stack_printable.exe stack_printable.ll

all: libCPI $(testcases)
%.exe: %.c
	$(CC) $(CFLAGS) $(LD_LIB) -o $@ $<
%.ll: %.c
	$(CC) $(EMIT_FLAGS) -o $@ $<
libCPI: ./lib/libcpi.c
	clang -shared -fPIC -m64 -o $@.so $<
clean:
	rm $(wildcard *.exe) $(wildcard *.ll) $(wildcard *.bc) $(wildcard *.so)
