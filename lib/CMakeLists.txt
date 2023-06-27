
SET(CMAKE_C_COMPILER ${PROJECT_SOURCE_DIR}/llvm-project/build/bin/clang)
SET(CMAKE_CXX_COMPILER ${PROJECT_SOURCE_DIR}/llvm-project/build/bin/clang++)

SET(CMAKE_C_FLAGS "-Wall -shared -fPIC -O3")

add_library(cpi OBJECT
  libcpi.c
  "${PROJECT_SOURCE_DIR}/include/libcpi.h"
)

target_include_directories(cpi PUBLIC
  ${PROJECT_SOURCE_DIR}/include/
  ${PROJECT_SOURCE_DIR}/lib/
)
