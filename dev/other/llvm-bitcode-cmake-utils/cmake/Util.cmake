# LLVM cmake utils


macro(DetectLLVMIRTools)
  set(LLVMIR_COMPILER "")
  set(LLVMIR_OPT "opt")
  set(LLVMIR_LINK "llvm-link")
  set(LLVMIR_DIR "llvm-ir")
endmacro()

DetectLLVMIRTools()

#

function(attach_llvmir_target OUT_TRGT IN_TRGT)
  ## preamble
  set(BC_DIR "${CMAKE_CURRENT_BINARY_DIR}/${LLVMIR_DIR}/${OUT_TRGT}")
  file(MAKE_DIRECTORY "${BC_DIR}")

  set(OUT_LLVMIR_FILES "")
  set(FULL_OUT_LLVMIR_FILES "")
  get_property(IN_FILES TARGET ${IN_TRGT} PROPERTY SOURCES)
  get_property(LINKER_LANGUAGE TARGET ${IN_TRGT} PROPERTY LINKER_LANGUAGE)

  if("${LINKER_LANGUAGE}" STREQUAL "")
    message(ERROR "linker language for target ${IN_TRGT} must be set.")
  endif()

  if("${LLVMIR_COMPILER}" STREQUAL "")
    set(LLVMIR_COMPILER ${CMAKE_${LINKER_LANGUAGE}_COMPILER})
  endif()

  ## command options
  set(SRC_DEFS "")
  get_property(CMPL_DEFINITIONS TARGET ${IN_TRGT} PROPERTY COMPILE_DEFINITIONS)
  foreach(DEFINITION ${CMPL_DEFINITIONS})
    list(APPEND SRC_DEFS "-D${DEFINITION}")
  endforeach()

  set(SRC_INCLUDES "")
  get_property(INC_DIRS TARGET ${IN_TRGT} PROPERTY INCLUDE_DIRECTORIES)
  foreach(DIRECTORY ${INC_DIRS})
    list(APPEND SRC_INCLUDES "-I${DIRECTORY}")
  endforeach()

  set(SRC_COMPILE_OPTIONS "")
  get_property(SRC_COMPILE_OPTIONS TARGET ${IN_TRGT} PROPERTY COMPILE_OPTIONS)

  set(SRC_LANG_FLAGS_TMP ${CMAKE_${LINKER_LANGUAGE}_FLAGS_${CMAKE_BUILD_TYPE}})
  if("${SRC_LANG_FLAGS_TMP}" STREQUAL "")
    set(SRC_LANG_FLAGS_TMP ${CMAKE_${LINKER_LANGUAGE}_FLAGS})
  endif()
  string(REPLACE " " ";" SRC_LANG_FLAGS ${SRC_LANG_FLAGS_TMP})

  set(CMD_ARGS -emit-llvm ${SRC_LANG_FLAGS} ${SRC_COMPILE_OPTIONS} ${SRC_DEFS} 
    ${SRC_INCLUDES} )

  ## main action
  foreach(IN_FILE ${IN_FILES})
    get_filename_component(OUTFILE ${IN_FILE} NAME_WE)
    get_filename_component(INFILE ${IN_FILE} ABSOLUTE)
    set(OUT_LLVMIR_FILE "${OUTFILE}.bc")
    set(FULL_OUT_LLVMIR_FILE "${BC_DIR}/${OUT_LLVMIR_FILE}")

    add_custom_command(OUTPUT ${FULL_OUT_LLVMIR_FILE}
      COMMAND ${LLVMIR_COMPILER} 
      ARGS ${CMD_ARGS} -c ${INFILE} -o ${FULL_OUT_LLVMIR_FILE}
      DEPENDS ${INFILE}
      IMPLICIT_DEPENDS ${LINKER_LANGUAGE} ${INFILE}
      COMMENT "Building LLVM bitcode ${OUT_LLVMIR_FILE}"
      VERBATIM)

    list(APPEND OUT_LLVMIR_FILES ${OUT_LLVMIR_FILE})
    list(APPEND FULL_OUT_LLVMIR_FILES ${FULL_OUT_LLVMIR_FILE})
  endforeach()

  ## postamble
  # clean up
  set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
    ${FULL_OUT_LLVMIR_FILES})

  # setup custom target
  add_custom_target(${OUT_TRGT} DEPENDS "${FULL_OUT_LLVMIR_FILES}")

  set_target_properties(${OUT_TRGT} PROPERTIES LLVMIR_DIR "${BC_DIR}")
  set_target_properties(${OUT_TRGT} PROPERTIES LLVMIR_FILES "${OUT_LLVMIR_FILES}")
  set_target_properties(${OUT_TRGT} PROPERTIES LINKER_LANGUAGE
    "${LINKER_LANGUAGE}")

  add_dependencies(${OUT_TRGT} ${IN_TRGT})
endfunction()


function(attach_llvmir_opt_pass_target OUT_TRGT IN_TRGT CMDLINE_OPTION 
    LIB_LOCATION)
  ## preamble
  set(BC_DIR "${CMAKE_CURRENT_BINARY_DIR}/${LLVMIR_DIR}/${OUT_TRGT}")
  file(MAKE_DIRECTORY "${BC_DIR}")

  set(OUT_LLVMIR_FILES "")
  set(FULL_OUT_LLVMIR_FILES "")
  get_property(IN_LLVMIR_DIR TARGET ${IN_TRGT} PROPERTY LLVMIR_DIR)
  get_property(IN_LLVMIR_FILES TARGET ${IN_TRGT} PROPERTY LLVMIR_FILES)
  get_property(LINKER_LANGUAGE TARGET ${IN_TRGT} PROPERTY LINKER_LANGUAGE)

  if("${LINKER_LANGUAGE}" STREQUAL "")
    message(ERROR "linker language for target ${IN_TRGT} must be set.")
  endif()

  ## command options
  set(LIB_OPTION "")
  if(NOT ${LIB_LOCATION} STREQUAL "")
    set(LIB_OPTION "-load ${LIB_LOCATION}")
  endif()
  set(CMDLINE_OPTION "-${CMDLINE_OPTION}")

  # TODO other opt options for debug
  set(OPT_PASS_OPTIONS "")

  foreach(IN_LLVMIR_FILE ${IN_LLVMIR_FILES})
    get_filename_component(OUTFILE ${IN_LLVMIR_FILE} NAME_WE)
    set(INFILE "${IN_LLVMIR_DIR}/${IN_LLVMIR_FILE}")
    set(OUT_LLVMIR_FILE "${OUTFILE}-${OUT_TRGT}.bc")
    set(FULL_OUT_LLVMIR_FILE "${BC_DIR}/${OUT_LLVMIR_FILE}")

    ## main action
    add_custom_command(OUTPUT ${FULL_OUT_LLVMIR_FILE}
      COMMAND ${LLVMIR_OPT}
      ${LIB_OPTION}
      ${CMDLINE_OPTION}
      ${INFILE}
      -o ${FULL_OUT_LLVMIR_FILE}
      DEPENDS ${INFILE}
      IMPLICIT_DEPENDS ${LINKER_LANGUAGE} ${INFILE}
      COMMENT "Building LLVM bitcode ${OUT_LLVMIR_FILE}"
      VERBATIM)

    list(APPEND OUT_LLVMIR_FILES ${OUT_LLVMIR_FILE})
    list(APPEND FULL_OUT_LLVMIR_FILES ${FULL_OUT_LLVMIR_FILE})
  endforeach()

  ## postamble

  # clean up
  set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
    ${FULL_OUT_LLVMIR_FILES})

  # setup custom target
  add_custom_target(${OUT_TRGT} DEPENDS "${FULL_OUT_LLVMIR_FILES}")

  set_target_properties(${OUT_TRGT} PROPERTIES LLVMIR_DIR "${BC_DIR}")
  set_target_properties(${OUT_TRGT} PROPERTIES LLVMIR_FILES "${OUT_LLVMIR_FILES}")
  set_target_properties(${OUT_TRGT} PROPERTIES LINKER_LANGUAGE "${LINKER_LANGUAGE}")

  add_dependencies(${OUT_TRGT} ${IN_TRGT})
endfunction()


#

function(attach_llvmir_link_target OUT_TRGT IN_TRGT)
  ## preamble
  set(BC_DIR "${CMAKE_CURRENT_BINARY_DIR}/${LLVMIR_DIR}/${OUT_TRGT}")
  file(MAKE_DIRECTORY "${BC_DIR}")

  set(OUT_LLVMIR_FILES "")
  set(FULL_OUT_LLVMIR_FILES "")
  get_property(INFILES TARGET ${IN_TRGT} PROPERTY LLVMIR_FILES)
  get_property(IN_LLVMIR_DIR TARGET ${IN_TRGT} PROPERTY LLVMIR_DIR)
  get_property(LINKER_LANGUAGE TARGET ${IN_TRGT} PROPERTY LINKER_LANGUAGE)

  if("${LINKER_LANGUAGE}" STREQUAL "")
    message(ERROR "linker language for target ${IN_TRGT} must be set.")
  endif()

  set(IN_FULL_LLVMIR_FILES "")
  foreach(IN_LLVMIR_FILE ${INFILES})
    list(APPEND IN_FULL_LLVMIR_FILES "${IN_LLVMIR_DIR}/${IN_LLVMIR_FILE}")
  endforeach()

  set(FULL_OUT_LLVMIR_FILE "${BC_DIR}/${OUT_TRGT}.bc")
  get_filename_component(OUT_LLVMIR_FILE ${FULL_OUT_LLVMIR_FILE} NAME)

  ## command options
  #set(CMDLINE_OPTION "-${CMDLINE_OPTION}")
  set(CMDLINE_OPTION "")

  list(APPEND OUT_LLVMIR_FILES ${OUT_LLVMIR_FILE})
  list(APPEND FULL_OUT_LLVMIR_FILES ${FULL_OUT_LLVMIR_FILE})

  # setup custom target
  add_custom_target(${OUT_TRGT} DEPENDS "${FULL_OUT_LLVMIR_FILES}")

  set_target_properties(${OUT_TRGT} PROPERTIES LLVMIR_DIR "${BC_DIR}")
  set_target_properties(${OUT_TRGT} PROPERTIES LLVMIR_FILES "${OUT_LLVMIR_FILES}")
  set_target_properties(${OUT_TRGT} PROPERTIES LINKER_LANGUAGE "${LINKER_LANGUAGE}")

  add_dependencies(${OUT_TRGT} ${IN_TRGT})

  ## main action
  add_custom_command(OUTPUT ${FULL_OUT_LLVMIR_FILE}
    COMMAND llvm-link
    ${CMDLINE_OPTION}
    -o ${FULL_OUT_LLVMIR_FILE}
    ${IN_FULL_LLVMIR_FILES}
    DEPENDS ${IN_FULL_LLVMIR_FILES}
    IMPLICIT_DEPENDS ${LINKER_LANGUAGE} ${IN_FULL_LLVMIR_FILES}
    COMMENT "Linking LLVM bitcode ${OUT_LLVMIR_FILE}"
    VERBATIM)

  ## postamble
  # clean up
  set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
    ${FULL_OUT_LLVMIR_FILES})
endfunction()


function(add_llvmir_executable OUT_TRGT IN_TRGT)
  ## preamble
  set(OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/${LLVMIR_DIR}/${OUT_TRGT}")
  file(MAKE_DIRECTORY "${OUT_DIR}")

  get_property(INFILES TARGET ${IN_TRGT} PROPERTY LLVMIR_FILES)
  get_property(IN_LLVMIR_DIR TARGET ${IN_TRGT} PROPERTY LLVMIR_DIR)
  get_property(LINKER_LANGUAGE TARGET ${IN_TRGT} PROPERTY LINKER_LANGUAGE)

  if("${LINKER_LANGUAGE}" STREQUAL "")
    message(ERROR "linker language for target ${IN_TRGT} must be set.")
  endif()

  set(IN_FULL_LLVMIR_FILES "")
  foreach(IN_LLVMIR_FILE ${INFILES})
    list(APPEND IN_FULL_LLVMIR_FILES "${IN_LLVMIR_DIR}/${IN_LLVMIR_FILE}")
  endforeach()

  add_executable(${OUT_TRGT} "${ARGN}" "${IN_FULL_LLVMIR_FILES}")

  set_property(TARGET ${OUT_TRGT} PROPERTY LINKER_LANGUAGE ${LINKER_LANGUAGE})
  set_property(TARGET ${OUT_TRGT} PROPERTY RUNTIME_OUTPUT_DIRECTORY ${OUT_DIR})

  foreach(IN_FULL_LLVMIR_FILE ${IN_FULL_LLVMIR_FILES})
    set_property(SOURCE ${IN_FULL_LLVMIR_FILE} PROPERTY EXTERNAL_OBJECT TRUE)
  endforeach()

  add_dependencies(${OUT_TRGT} ${IN_TRGT})

  ## postamble
endfunction()


function(add_llvmir_library OUT_TRGT IN_TRGT)
  ## preamble
  set(OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/${LLVMIR_DIR}/${OUT_TRGT}")
  file(MAKE_DIRECTORY "${OUT_DIR}")

  get_property(INFILES TARGET ${IN_TRGT} PROPERTY LLVMIR_FILES)
  get_property(IN_LLVMIR_DIR TARGET ${IN_TRGT} PROPERTY LLVMIR_DIR)
  get_property(LINKER_LANGUAGE TARGET ${IN_TRGT} PROPERTY LINKER_LANGUAGE)

  if("${LINKER_LANGUAGE}" STREQUAL "")
    message(ERROR "linker language for target ${IN_TRGT} must be set.")
  endif()

  set(IN_FULL_LLVMIR_FILES "")
  foreach(IN_LLVMIR_FILE ${INFILES})
    list(APPEND IN_FULL_LLVMIR_FILES "${IN_LLVMIR_DIR}/${IN_LLVMIR_FILE}")
  endforeach()

  add_library(${OUT_TRGT} "${ARGN}" "${IN_FULL_LLVMIR_FILES}")

  set_property(TARGET ${OUT_TRGT} PROPERTY LINKER_LANGUAGE ${LINKER_LANGUAGE})
  set_property(TARGET ${OUT_TRGT} PROPERTY LIBRARY_OUTPUT_DIRECTORY ${OUT_DIR})

  foreach(IN_FULL_LLVMIR_FILE ${IN_FULL_LLVMIR_FILES})
    set_property(SOURCE ${IN_FULL_LLVMIR_FILE} PROPERTY EXTERNAL_OBJECT TRUE)
  endforeach()

  add_dependencies(${OUT_TRGT} ${IN_TRGT})

  ## postamble
endfunction()

