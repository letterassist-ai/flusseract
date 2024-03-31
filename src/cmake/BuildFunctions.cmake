##############################################
# FUNCTION add_static_library_dependency
##############################################
function(add_static_library_dependency LIB_NAME TARGET_TYPE)

  set(LIB_PATH    ${CMAKE_BINARY_DIR}/dist/${TARGET_TYPE}/lib/${LIB_NAME}.a)
  set(LIB_INCLUDE ${CMAKE_BINARY_DIR}/dist/${TARGET_TYPE}/include)

  message(STATUS "Adding library dependency: ${LIB_NAME} (${LIB_PATH}) - ${LIB_NAME}-${TARGET_TYPE}")

  add_library(${LIB_NAME} STATIC IMPORTED GLOBAL)
  add_dependencies(${LIB_NAME} "${LIB_NAME}-${TARGET_TYPE}")
  set_target_properties(${LIB_NAME} 
    PROPERTIES
      IMPORTED_LOCATION ${LIB_PATH}
      INTERFACE_INCLUDE_DIRECTORIES ${LIB_INCLUDE}
  )
  
endfunction(add_static_library_dependency)

##############################################
# FUNCTION ext_build_library_from_git
##############################################
function(ext_build_library_from_git SDK ARCH OSTYPE GIT_REPOSITORY GIT_TAG)
  get_filename_component(LIB_NAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

  set(TARGET      "${LIB_NAME}-${SDK}-${ARCH}")
  set(LIB_DIR     "${CMAKE_BINARY_DIR}/dist/${SDK}-${ARCH}/lib")
  set(LIB_FILE    "${CMAKE_BINARY_DIR}/dist/${SDK}-${ARCH}/lib/${LIB_NAME}.a")
  set(LIB_INCLUDE "${CMAKE_BINARY_DIR}/dist/${SDK}-${ARCH}/include")

  file(MAKE_DIRECTORY ${LIB_DIR})
  file(MAKE_DIRECTORY ${LIB_INCLUDE})

  set_property(GLOBAL PROPERTY "${TARGET}" "${LIB_FILE}")
  set_property(GLOBAL PROPERTY "${TARGET}_include" "${LIB_INCLUDE}")

  message(STATUS "Creating external project build target: ${TARGET}")

  externalproject_add("ext_${TARGET}"

    GIT_REPOSITORY "${GIT_REPOSITORY}"
    GIT_TAG        "${GIT_TAG}"
    SOURCE_DIR     "${CMAKE_CURRENT_BINARY_DIR}/src"
    BINARY_DIR     "${CMAKE_CURRENT_BINARY_DIR}/${SDK}-${ARCH}/build"
    INSTALL_DIR    "${CMAKE_BINARY_DIR}/dist/${SDK}-${ARCH}"

    CONFIGURE_COMMAND "${CMAKE_SOURCE_DIR}/cmake/ext-run-cmake-for-${OSTYPE}.sh"
                      "${SDK}" "${ARCH}" "<SOURCE_DIR>" "<INSTALL_DIR>" 
                      "${CMAKE_SOURCE_DIR}/${LIB_NAME}"
  )

  message(STATUS "  Adding custom command to build: ${CMAKE_BINARY_DIR}/dist/${SDK}-${ARCH}/lib/${LIB_NAME}.a")
  
  set(DEPENDS ${ARGN})
  foreach(value ${DEPENDS})
    set(DEPENDENCY "${value}-${SDK}-${ARCH}")
    message(STATUS "    with dependency: ${DEPENDENCY}")
    list(APPEND DEPENDENCIES "${DEPENDENCY}")
  endforeach()
  
  add_custom_command(
    OUTPUT "${LIB_FILE}"
    COMMENT "Building library ${LIB_NAME} using ${SDK} SDK..."
    COMMAND "${CMAKE_COMMAND}" --build "${CMAKE_BINARY_DIR}" --target "ext_${TARGET}"
    DEPENDS ${DEPENDENCIES}
  )
  add_custom_target("${TARGET}" DEPENDS "${LIB_FILE}")

endfunction(ext_build_library_from_git)

##############################################
# FUNCTION ext_build_library_from_url
##############################################
function(ext_build_library_from_url SDK ARCH OSTYPE URL URL_HASH)
  get_filename_component(LIB_NAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

  set(TARGET      "${LIB_NAME}-${SDK}-${ARCH}")
  set(LIB_DIR     "${CMAKE_BINARY_DIR}/dist/${SDK}-${ARCH}/lib/")
  set(LIB_FILE    "${CMAKE_BINARY_DIR}/dist/${SDK}-${ARCH}/lib/${LIB_NAME}.a")
  set(LIB_INCLUDE "${CMAKE_BINARY_DIR}/dist/${SDK}-${ARCH}/include")

  file(MAKE_DIRECTORY ${LIB_DIR})
  file(MAKE_DIRECTORY ${LIB_INCLUDE})
  
  set_property(GLOBAL PROPERTY "${TARGET}" "${LIB_FILE}")
  set_property(GLOBAL PROPERTY "${TARGET}_include" "${LIB_INCLUDE}")
  
  message(STATUS "Creating external project build target: ${TARGET}")

  externalproject_add("ext_${TARGET}"

    URL         "${URL}"
    URL_HASH    "${URL_HASH}"
    SOURCE_DIR  "${CMAKE_CURRENT_BINARY_DIR}/src"
    BINARY_DIR  "${CMAKE_CURRENT_BINARY_DIR}/${SDK}-${ARCH}/build"
    INSTALL_DIR "${CMAKE_BINARY_DIR}/dist/${SDK}-${ARCH}"

    DOWNLOAD_EXTRACT_TIMESTAMP true

    CONFIGURE_COMMAND "${CMAKE_SOURCE_DIR}/cmake/ext-run-cmake-for-${OSTYPE}.sh"
                      "${SDK}" "${ARCH}" "<SOURCE_DIR>" "<INSTALL_DIR>" 
                      "${CMAKE_SOURCE_DIR}/${LIB_NAME}"
  )

  message(STATUS "  Adding custom command to build: ${CMAKE_BINARY_DIR}/dist/${SDK}-${ARCH}/lib/${LIB_NAME}.a")
  
  set(DEPENDS ${ARGN})
  foreach(value ${DEPENDS})
    set(DEPENDENCY "${value}-${SDK}-${ARCH}")
    message(STATUS "    with dependency: ${DEPENDENCY}")
    list(APPEND DEPENDENCIES "${DEPENDENCY}")
  endforeach()
  
  add_custom_command(
    OUTPUT "${CMAKE_BINARY_DIR}/dist/${SDK}-${ARCH}/lib/${LIB_NAME}.a"
    COMMENT "Building library ${LIB_NAME} using ${SDK} SDK..."
    COMMAND "${CMAKE_COMMAND}" --build "${CMAKE_BINARY_DIR}" --target "ext_${TARGET}"
    DEPENDS ${DEPENDENCIES}
  )
  add_custom_target("${TARGET}" DEPENDS "${LIB_FILE}")

endfunction(ext_build_library_from_url)

##############################################
# FUNCTION ext_create_target_library
##############################################
function(ext_create_target_library TARGET_TYPE)
  get_filename_component(LIB_NAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
  set(TARGET "${LIB_NAME}-${TARGET_TYPE}")
  set(TARGET_LIB "${CMAKE_BINARY_DIR}/dist/${TARGET_TYPE}/lib/${LIB_NAME}.a")

  message(STATUS "Creating multi-arch library target: ${TARGET}")

  set(DEPENDS ${ARGN})
  foreach(SDK_ARCH ${DEPENDS})
    get_property(LIB_FILE GLOBAL PROPERTY "${LIB_NAME}-${SDK_ARCH}")
    message(STATUS "  with dependency: ${LIB_FILE}")
    list(APPEND DEPENDENCIES "${LIB_FILE}")
    set(SINGLE_ARCH_LIBS "${LIB_FILE} ${SINGLE_ARCH_LIBS}")
  endforeach()

  list(LENGTH DEPENDS NUM_DEPENDS)
  list(GET DEPENDS 0 FIRST_DEPENDS)

  if(${NUM_DEPENDS} GREATER 1)
    # Create a multi-arch library using lipo

    set(LIPO_COMMAND "lipo ${SINGLE_ARCH_LIBS} -create -output ${TARGET_LIB}")
    add_custom_command(
      OUTPUT ${TARGET_LIB}
      COMMENT "Building multi-arch library module for ${TARGET_TYPE}..."
      BYPRODUCTS ${TARGET_LIB}
      DEPENDS ${DEPENDENCIES}
      COMMAND sh -c ${LIPO_COMMAND}
      COMMAND cp -r 
        ${CMAKE_BINARY_DIR}/dist/${FIRST_DEPENDS}/include/*
        ${CMAKE_BINARY_DIR}/dist/${TARGET_TYPE}/include/
    )
  else()
    # Only single arch library, no need to create multi-arch library
    # Simply copy the single arch library to the target library directory
    list(GET FIRST_DEPENDENCY 0 DEPENDENCIES)

    add_custom_command(
      OUTPUT ${TARGET_LIB}
      COMMENT "Building multi-arch library module for ${TARGET_TYPE}..."
      BYPRODUCTS ${TARGET_LIB}
      DEPENDS ${DEPENDENCIES}
      COMMAND cp
        ${FIRST_DEPENDENCY}
        ${CMAKE_BINARY_DIR}/dist/${TARGET_TYPE}/lib/
      COMMAND cp -r 
        ${CMAKE_BINARY_DIR}/dist/${FIRST_DEPENDS}/include/*
        ${CMAKE_BINARY_DIR}/dist/${TARGET_TYPE}/include/
    )

  endif()

  add_custom_target("${TARGET}"
    DEPENDS ${TARGET_LIB}
  )

endfunction(ext_create_target_library)

## Apple platform target library build output directories

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/dist/iphoneos/lib)
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/dist/iphoneos/include)
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/dist/iphonesimulator/lib)
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/dist/iphonesimulator/include)
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/dist/macosx/lib)
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/dist/macosx/include)
