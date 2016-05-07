# cmake file

cmake_minimum_required(VERSION 3.0.0)
project(circulardep)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-rtti")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-exceptions")

set(SOURCES
  main.cpp
  Node.cpp
  Bar.cpp)

add_executable(circulardep ${SOURCES})

target_include_directories(circulardep PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

