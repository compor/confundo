# LLVM cmake utils

function(attach_bitcode_target OUT_TRGT TRGT)
  set(BC_DIR "${CMAKE_CURRENT_BINARY_DIR}/${OUT_TRGT}")
  file(MAKE_DIRECTORY "${BC_DIR}")

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
    get_filename_component(OUTFILE ${SRC_FILE} NAME_WE)
    get_filename_component(INFILE ${SRC_FILE} ABSOLUTE)
    set(BCFILE "${OUTFILE}.bc")
    set(FULL_BCFILE "${BC_DIR}/${BCFILE}")

    # TODO add debug flag
    add_custom_command(OUTPUT ${FULL_BCFILE}
      COMMAND clang -emit-llvm
      ${SRC_DEFS} ${SRC_COMPILE_FLAGS} ${SRC_INCLUDES}
      -c ${INFILE}
      -o ${FULL_BCFILE}
      DEPENDS ${INFILE}
      IMPLICIT_DEPENDS CXX ${INFILE}
      COMMENT "Building LLVM bitcode ${BCFILE}"
      VERBATIM)

    set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES 
      ${FULL_BCFILE})
    set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${BCDIR})

    list(APPEND BCFILES ${FULL_BCFILE})
  endforeach()


  # setup custom target

  add_custom_target(${OUT_TRGT} DEPENDS "${BCFILES}")

  set_target_properties(${OUT_TRGT} PROPERTIES BITCODE_DIR "${BC_DIR}")
  set_target_properties(${OUT_TRGT} PROPERTIES BITCODE_FILES "${BCFILES}")

  add_dependencies(${TRGT} ${OUT_TRGT})
endfunction()


function(attach_opt_pass_target OUT_TRGT BITCODE_TRGT LIB_LOCATION
    CMDLINE_OPTION)
  set(BC_DIR "${CMAKE_CURRENT_BINARY_DIR}/${OUT_TRGT}")
  file(MAKE_DIRECTORY "${BC_DIR}")

  set(LIB_OPTION "")
  if(NOT ${LIB_LOCATION} STREQUAL "")
    set(LIB_OPTION "-load ${LIB_LOCATION}")
  endif()
  set(CMDLINE_OPTION "-${CMDLINE_OPTION}")

  # TODO other opt options for debug
  set(OPT_PASS_OPTIONS "")

  set(BCFILES "")
  get_property(INBCFILES TARGET ${BITCODE_TRGT} PROPERTY BITCODE_FILES)

  foreach(INBCFILE ${INBCFILES})
    get_filename_component(OUTFILE ${INBCFILE} NAME_WE)
    get_filename_component(INFILE ${INBCFILE} ABSOLUTE)
    set(BCFILE "${OUTFILE}-${OUT_TRGT}.bc")
    set(FULL_BCFILE "${BC_DIR}/${BCFILE}")

    # TODO add other flags
    add_custom_command(OUTPUT ${FULL_BCFILE}
      COMMAND opt
      ${LIB_OPTION}
      ${CMDLINE_OPTION}
      ${INFILE}
      -o ${FULL_BCFILE}
      DEPENDS ${INFILE}
      IMPLICIT_DEPENDS CXX ${INFILE}
      COMMENT "Building LLVM bitcode ${BCFILE}"
      VERBATIM)

    set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES 
      ${FULL_BCFILE})
    set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${BCDIR})

    list(APPEND BCFILES ${FULL_BCFILE})
  endforeach()


  # setup custom target

  add_custom_target(${OUT_TRGT} DEPENDS "${BCFILES}")

  set_target_properties(${OUT_TRGT} PROPERTIES BITCODE_DIR "${BC_DIR}")
  set_target_properties(${OUT_TRGT} PROPERTIES BITCODE_FILES "${BCFILES}")

  add_dependencies(${BITCODE_TRGT} ${OUT_TRGT})
endfunction()


#

function(attach_llvm_link_target OUT_TRGT BITCODE_TRGT)
  set(BC_DIR "${CMAKE_CURRENT_BINARY_DIR}/${OUT_TRGT}")
  file(MAKE_DIRECTORY "${BC_DIR}")

  #set(CMDLINE_OPTION "-${CMDLINE_OPTION}")
  set(CMDLINE_OPTION "")

  get_property(INFILES TARGET ${BITCODE_TRGT} PROPERTY BITCODE_FILES)

  set(BC_FILE "${BC_DIR}/${OUT_TRGT}.bc")
  get_filename_component(BC_REL_FILE ${BC_FILE} NAME)

  # TODO add other flags
  add_custom_command(OUTPUT ${BC_FILE}
    COMMAND llvm-link
    ${CMDLINE_OPTION}
    -o ${BC_FILE}
    ${INFILES}
    DEPENDS ${INFILES}
    IMPLICIT_DEPENDS CXX ${INFILES}
    COMMENT "Linking LLVM bitcode ${BC_REL_FILE}"
    VERBATIM)

  set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES 
    ${BC_FILE})
  set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${BCDIR})


  # setup custom target

  add_custom_target(${OUT_TRGT} DEPENDS "${BC_FILE}")

  set_target_properties(${OUT_TRGT} PROPERTIES BITCODE_DIR "${BC_DIR}")
  set_target_properties(${OUT_TRGT} PROPERTIES BITCODE_FILES "${BC_FILE}")

  add_dependencies(${BITCODE_TRGT} ${OUT_TRGT})
endfunction()


