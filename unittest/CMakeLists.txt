SET(UNITTEST ut_test)

SET(DEBUG_FLAGS "-DUNITTEST -g")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${DEBUG_FLAGS}")
SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${DEBUG_FLAGS}")

add_executable(${UNITTEST}
  ut_test.c
)

target_link_libraries(${UNITTEST} PUBLIC
  cpi
)


