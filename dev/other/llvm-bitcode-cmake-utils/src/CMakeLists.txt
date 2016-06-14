
set(SOURCES
  foo.cpp
  bar.cpp)


add_executable(qux ${SOURCES})

target_include_directories(qux 
  PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/../include")

attach_bitcode_target(quxbc qux)
attach_opt_pass_target(quxpass1 quxbc "" "mem2reg")
attach_opt_pass_target(quxpass2 quxpass1 "" "simplifycfg")


