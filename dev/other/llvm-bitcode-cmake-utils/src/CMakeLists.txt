
set(SOURCES
  foo.cpp
  bar.cpp)


add_executable(qux ${SOURCES})

target_include_directories(qux 
  PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/../include")

generate_bitcode(qux quxbc)


get_property(LOL TARGET qux PROPERTY BITCODE)

foreach(F ${LOL})
  message("+++++++++${F}")
endforeach()

