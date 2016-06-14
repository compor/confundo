

function(create_hierarchy_dir ROOT_DIR)
  foreach(DIR ${ARGN})
    file(MAKE_DIRECTORY "${ROOT_DIR}/${DIR}")
  endforeach()
endfunction()

 
function(generate_bitcode TRGT BC_TRGT)
  set(BC_DIR "${CMAKE_CURRENT_BINARY_DIR}/bitcode")
  set(BC_PLAIN_DIR "${BC_DIR}/plain")
  set(BC_PRE_DIR "${BC_DIR}/prelink")
  set(BC_POST_DIR "${BC_DIR}/postlink")
  file(MAKE_DIRECTORY "${BC_DIR}")
  file(MAKE_DIRECTORY "${BC_PLAIN_DIR}")
  file(MAKE_DIRECTORY "${BC_PRE_DIR}")
  file(MAKE_DIRECTORY "${BC_POST_DIR}")

  set_target_properties(${TRGT} PROPERTIES BITCODE_ROOT_DIR "${BC_DIR}")
  set_target_properties(${TRGT} PROPERTIES BITCODE_PLAIN_DIR "${BC_PLAIN_DIR}")
  set_target_properties(${TRGT} PROPERTIES BITCODE_PRELINK_DIR "${BC_PRE_DIR}")
  set_target_properties(${TRGT} PROPERTIES BITCODE_POSTLINK_DIR "${BC_POST_DIR}")

  #

  set(SRC_DEFS "")
  get_property(CMPL_DEFINITIONS TARGET ${TRGT} PROPERTY COMPILE_DEFINITIONS)
  foreach(DEFINITION ${CMPL_DEFINITIONS})
    list(APPEND SRC_DEFS -D${DEFINITION})
  endforeach()

  #set(SRCFLAGS "")
  #if(${srcfile} MATCHES "(.*).cpp")
    #separate_arguments(srcflags UNIX_COMMAND ${CMAKE_CXX_FLAGS})
    #set(src_bc_compiler ${LLVM_BC_CXX_COMPILER})
  #else()
    #separate_arguments(srcflags UNIX_COMMAND ${CMAKE_C_FLAGS})
    #set(src_bc_compiler ${LLVM_BC_C_COMPILER} )
  #endif()

  set(SRC_INCLUDES "")
  get_property(INC_DIRS TARGET ${TRGT} PROPERTY INCLUDE_DIRECTORIES)
  foreach(DIRECTORY ${INC_DIRS})
    list(APPEND SRC_INCLUDES -I${DIRECTORY})
  endforeach()
   
  set(SRC_COMPILE_FLAGS "")
  get_property(SRC_COMPILE_FLAGS TARGET ${TRGT} PROPERTY COMPILE_FLAGS)

  # 

  get_property(SRCS TARGET ${TRGT} PROPERTY SOURCES)
  set(BCFILES "")

  foreach(SRC_FILE ${SRCS})
    get_filename_component(OUTFILE ${SRC_FILE} NAME)
    get_filename_component(INFILE ${SRC_FILE} ABSOLUTE)
    set(BCFILE "${SRC_FILE}.bc")
    set(FULL_BCFILE "${BC_PLAIN_DIR}/${BCFILE}")

    add_custom_command(OUTPUT ${FULL_BCFILE}
      COMMAND clang -emit-llvm ${SRC_DEFS} ${SRC_COMPILE_FLAGS} ${SRC_INCLUDES}
      -c ${INFILE} -o ${FULL_BCFILE}
      DEPENDS ${INFILE}
      IMPLICIT_DEPENDS CXX ${INFILE}
      COMMENT "Building LLVM bitcode ${BCFILE}"
      VERBATIM)
    set_property(DIRECTORY APPEND 
      PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${FULL_BCFILE})

    #add_custom_target(${BCFILE} DEPENDS ${OUTFILE})

    ## keep track of every bitcode file we need to create
    list(APPEND BCFILES ${FULL_BCFILE})
  endforeach()

  add_custom_target(${BC_TRGT} DEPENDS "${BCFILES}")

  #set_target_properties(${BC_TRGT} PROPERTIES DEPENDS "${BCFILES}")
  set_target_properties(${TRGT} PROPERTIES BITCODE "${BCFILES}")

  add_dependencies(${TRGT} ${BC_TRGT})
endfunction()

