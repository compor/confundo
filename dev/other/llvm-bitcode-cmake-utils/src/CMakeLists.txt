
set(SOURCES
  foo.cpp
  bar.cpp)


add_executable(qux ${SOURCES})
set_target_properties(qux PROPERTIES LINKER_LANGUAGE CXX)

target_include_directories(qux 
  PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/../include")


#

attach_llvmir_target(qux_bc qux)

attach_llvmir_opt_pass_target(qux_pass1 qux_bc "mem2reg" "")
attach_llvmir_opt_pass_target(qux_pass2 qux_pass1 "simplifycfg" "")

attach_llvmir_link_target(qux_llvmlink qux_pass2)

attach_llvmir_opt_pass_target(qux_pass4 qux_llvmlink "simplifycfg" "")

add_llvmir_executable(qux_bc_exe qux_pass4)
add_llvmir_executable(qux_bc_exe2 qux_pass2)

add_llvmir_library(qux_bc_lib qux_pass2 SHARED)

