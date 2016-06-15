
set(SOURCES
  foo.cpp
  bar.cpp)


add_executable(qux ${SOURCES})

target_include_directories(qux 
  PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/../include")

attach_bitcode_target(qux_bc qux)
attach_opt_pass_target(qux_pass1 qux_bc "mem2reg" "")
attach_opt_pass_target(qux_pass2 qux_pass1 "simplifycfg" "")

attach_llvm_link_target(qux_llvmlink qux_pass2)


