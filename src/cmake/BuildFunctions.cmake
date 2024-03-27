##############################################
# FUNCTION ext_build_library_from_git
##############################################
function(ext_build_library_from_git SDK ARCH OSTYPE GIT_REPOSITORY GIT_TAG)

  get_filename_component(LIB_NAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

  externalproject_add("${LIB_NAME}-${SDK}-${ARCH}"

    GIT_REPOSITORY "${GIT_REPOSITORY}"
    GIT_TAG        "${GIT_TAG}"
    SOURCE_DIR     "${CMAKE_CURRENT_BINARY_DIR}/src"
    BINARY_DIR     "${CMAKE_CURRENT_BINARY_DIR}/${SDK}-${ARCH}/build"
    INSTALL_DIR    "${CMAKE_BINARY_DIR}/dist/${SDK}-${ARCH}"

    CONFIGURE_COMMAND "${CMAKE_SOURCE_DIR}/cmake/ext-run-cmake-for-${OSTYPE}.sh"
                      "${SDK}" "${ARCH}" "<SOURCE_DIR>" "<INSTALL_DIR>" 
                      "${CMAKE_SOURCE_DIR}/${LIB_NAME}"
  )

endfunction(ext_build_library_from_git)

##############################################
# FUNCTION ext_build_library_from_url
##############################################
function(ext_build_library_from_url SDK ARCH OSTYPE URL URL_HASH)

  get_filename_component(LIB_NAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

  externalproject_add("${LIB_NAME}-${SDK}-${ARCH}"

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

endfunction(ext_build_library_from_url)

##############################################
# FUNCTION ext_create_combined_library
##############################################
function(ext_create_combined_library SDK ARCH)

  get_filename_component(LIB_NAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)

  externalproject_add_step("${LIB_NAME}-${SDK}-${ARCH}"
    build_combined_library DEPENDEES install
    COMMAND "${CMAKE_SOURCE_DIR}/cmake/ext-create-combined-library.sh" "<INSTALL_DIR>/lib"
  )

endfunction(ext_create_combined_library)
