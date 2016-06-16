
cmake_minimum_required(VERSION 3.0)

project(qux C CXX)

if(NOT DEFINED CMAKE_MODULE_PATH)
  set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
endif()

message(STATUS ${CMAKE_MODULE_PATH})
include(Util)

add_subdirectory(src)

