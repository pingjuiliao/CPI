cmake_minimum_required(VERSION 3.11)

project(CPI VERSION 1.0.0)

# Paths
SET(PROJ_DIR ${PROJECT_SOURCE_DIR})
SET(LLVM_DIR ${PROJ_DIR}/llvm-project)
SET(TEST_DIR ${PROJ_DIR}/test)
execute_process(COMMAND nproc OUTPUT_VARIABLE NJOB)

add_custom_target(echy
  COMMAND cd ${TEST_DIR}/ && objdump
          -d
          ./a.exe)

add_custom_target(llvm
  COMMAND cd ${LLVM_DIR}/ && rm -rf build
  COMMAND mkdir ${LLVM_DIR}/build
  COMMAND cd ${LLVM_DIR}/build && cmake
          -DLLVM_ENABLE_PROJECTS=clang
          -DBUILD_SHARED_LIBS=On
          -DLLVM_BUILD_TOOLS=Off
          -DLLVM_ENABLE_LTO=Off
          -DLLVM_ENABLE_DOXYGEN=Off
          -G "Unix Makefiles" ../llvm
  COMMAND cd ${LLVM_DIR}/build && make -j${NJOB}
)

add_custom_target(llvm-remake
  COMMAND cd $(LLVM_DIR)/build && make -j${NJOB})
