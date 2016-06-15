# LLVM cmake utils

function(attach_bitcode_target OUT_TRGT IN_TRGT)
  ## preamble
  set(BC_DIR "${CMAKE_CURRENT_BINARY_DIR}/${OUT_TRGT}")
  file(MAKE_DIRECTORY "${BC_DIR}")

  set(OUT_BC_FILES "")
  set(FULL_OUT_BC_FILES "")
  get_property(IN_FILES TARGET ${IN_TRGT} PROPERTY SOURCES)

  ## command options
  set(SRC_DEFS "")
  get_property(CMPL_DEFINITIONS TARGET ${IN_TRGT} PROPERTY COMPILE_DEFINITIONS)
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
  get_property(INC_DIRS TARGET ${IN_TRGT} PROPERTY INCLUDE_DIRECTORIES)
  foreach(DIRECTORY ${INC_DIRS})
    list(APPEND SRC_INCLUDES -I${DIRECTORY})
  endforeach()

  set(SRC_COMPILE_FLAGS "")
  get_property(SRC_COMPILE_FLAGS TARGET ${IN_TRGT} PROPERTY COMPILE_FLAGS)

  ## main action
  foreach(IN_FILE ${IN_FILES})
    get_filename_component(OUTFILE ${IN_FILE} NAME_WE)
    get_filename_component(INFILE ${IN_FILE} ABSOLUTE)
    set(OUT_BC_FILE "${OUTFILE}.bc")
    set(FULL_OUT_BC_FILE "${BC_DIR}/${OUT_BC_FILE}")

    add_custom_command(OUTPUT ${FULL_OUT_BC_FILE}
      COMMAND clang -emit-llvm
      ${SRC_DEFS} ${SRC_COMPILE_FLAGS} ${SRC_INCLUDES}
      -c ${INFILE}
      -o ${FULL_OUT_BC_FILE}
      DEPENDS ${INFILE}
      IMPLICIT_DEPENDS CXX ${INFILE}
      COMMENT "Building LLVM bitcode ${OUT_BC_FILE}"
      VERBATIM)

    list(APPEND OUT_BC_FILES ${OUT_BC_FILE})
    list(APPEND FULL_OUT_BC_FILES ${FULL_OUT_BC_FILE})
  endforeach()

  ## postamble
  # clean up
  set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
    ${FULL_OUT_BC_FILES})

  # setup custom target
  add_custom_target(${OUT_TRGT} DEPENDS "${FULL_OUT_BC_FILES}")

  set_target_properties(${OUT_TRGT} PROPERTIES BITCODE_DIR "${BC_DIR}")
  set_target_properties(${OUT_TRGT} PROPERTIES BITCODE_FILES "${OUT_BC_FILES}")

  add_dependencies(${IN_TRGT} ${OUT_TRGT})
endfunction()


function(attach_opt_pass_target OUT_TRGT IN_TRGT CMDLINE_OPTION 
    LIB_LOCATION)
  ## preamble
  set(BC_DIR "${CMAKE_CURRENT_BINARY_DIR}/${OUT_TRGT}")
  file(MAKE_DIRECTORY "${BC_DIR}")

  set(OUT_BC_FILES "")
  set(FULL_OUT_BC_FILES "")
  get_property(IN_BC_DIR TARGET ${IN_TRGT} PROPERTY BITCODE_DIR)
  get_property(IN_BC_FILES TARGET ${IN_TRGT} PROPERTY BITCODE_FILES)

  ## command options
  set(LIB_OPTION "")
  if(NOT ${LIB_LOCATION} STREQUAL "")
    set(LIB_OPTION "-load ${LIB_LOCATION}")
  endif()
  set(CMDLINE_OPTION "-${CMDLINE_OPTION}")

  # TODO other opt options for debug
  set(OPT_PASS_OPTIONS "")

  foreach(IN_BC_FILE ${IN_BC_FILES})
    get_filename_component(OUTFILE ${IN_BC_FILE} NAME_WE)
    set(INFILE "${IN_BC_DIR}/${IN_BC_FILE}")
    set(OUT_BC_FILE "${OUTFILE}-${OUT_TRGT}.bc")
    set(FULL_OUT_BC_FILE "${BC_DIR}/${OUT_BC_FILE}")

    ## main action
    add_custom_command(OUTPUT ${FULL_OUT_BC_FILE}
      COMMAND opt
      ${LIB_OPTION}
      ${CMDLINE_OPTION}
      ${INFILE}
      -o ${FULL_OUT_BC_FILE}
      DEPENDS ${INFILE}
      IMPLICIT_DEPENDS CXX ${INFILE}
      COMMENT "Building LLVM bitcode ${OUT_BC_FILE}"
      VERBATIM)

    list(APPEND OUT_BC_FILES ${OUT_BC_FILE})
    list(APPEND FULL_OUT_BC_FILES ${FULL_OUT_BC_FILE})
  endforeach()

  ## postamble

  # clean up
  set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
    ${FULL_OUT_BC_FILES})

  # setup custom target
  add_custom_target(${OUT_TRGT} DEPENDS "${FULL_OUT_BC_FILES}")

  set_target_properties(${OUT_TRGT} PROPERTIES BITCODE_DIR "${BC_DIR}")
  set_target_properties(${OUT_TRGT} PROPERTIES BITCODE_FILES "${OUT_BC_FILES}")

  add_dependencies(${IN_TRGT} ${OUT_TRGT})
endfunction()


#

function(attach_llvm_link_target OUT_TRGT IN_TRGT)
  ## preamble
  set(BC_DIR "${CMAKE_CURRENT_BINARY_DIR}/${OUT_TRGT}")
  file(MAKE_DIRECTORY "${BC_DIR}")

  set(OUT_BC_FILES "")
  set(FULL_OUT_BC_FILES "")
  get_property(INFILES TARGET ${IN_TRGT} PROPERTY BITCODE_FILES)
  get_property(IN_BC_DIR TARGET ${IN_TRGT} PROPERTY BITCODE_DIR)

  set(IN_FULL_BC_FILES "")
  foreach(IN_BC_FILE ${INFILES})
    list(APPEND IN_FULL_BC_FILES "${IN_BC_DIR}/${IN_BC_FILE}")
  endforeach()

  set(FULL_OUT_BC_FILE "${BC_DIR}/${OUT_TRGT}.bc")
  get_filename_component(OUT_BC_FILE ${FULL_OUT_BC_FILE} NAME)

  ## command options
  #set(CMDLINE_OPTION "-${CMDLINE_OPTION}")
  set(CMDLINE_OPTION "")

  ## main action
  add_custom_command(OUTPUT ${FULL_OUT_BC_FILE}
    COMMAND llvm-link
    ${CMDLINE_OPTION}
    -o ${FULL_OUT_BC_FILE}
    ${IN_FULL_BC_FILES}
    DEPENDS ${IN_FULL_BC_FILES}
    IMPLICIT_DEPENDS CXX ${IN_FULL_BC_FILES}
    COMMENT "Linking LLVM bitcode ${OUT_BC_FILE}"
    VERBATIM)

  list(APPEND OUT_BC_FILES ${OUT_BC_FILE})
  list(APPEND FULL_OUT_BC_FILES ${FULL_OUT_BC_FILE})

  ## postamble
  # clean up
  set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
    ${FULL_OUT_BC_FILES})

  # setup custom target
  add_custom_target(${OUT_TRGT} DEPENDS "${FULL_OUT_BC_FILES}")

  set_target_properties(${OUT_TRGT} PROPERTIES BITCODE_DIR "${BC_DIR}")
  set_target_properties(${OUT_TRGT} PROPERTIES BITCODE_FILES "${OUT_BC_FILES}")

  add_dependencies(${IN_TRGT} ${OUT_TRGT})
endfunction()


