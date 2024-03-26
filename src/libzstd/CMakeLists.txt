# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

include(ExternalProject)

# iOS device arm64 architecture
externalproject_add(libzstd-iphoneos-arm64
  GIT_REPOSITORY    https://github.com/facebook/zstd.git
  GIT_TAG            v1.5.5
  SOURCE_DIR        ${CMAKE_CURRENT_BINARY_DIR}/src
  BINARY_DIR        ${CMAKE_CURRENT_BINARY_DIR}/iphoneos-arm64/build
  INSTALL_DIR       ${CMAKE_CURRENT_BINARY_DIR}/../dist/iphoneos-arm64

  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake-apple.sh 
                    iphoneos arm64 <SOURCE_DIR> <INSTALL_DIR>
)

# iOS simulator x86_64 architecture
externalproject_add(libzstd-iphonesimulator-x86_64
  GIT_REPOSITORY    https://github.com/facebook/zstd.git
  GIT_TAG            v1.5.5
  SOURCE_DIR        ${CMAKE_CURRENT_BINARY_DIR}/src
  BINARY_DIR        ${CMAKE_CURRENT_BINARY_DIR}/iphonesimulator-x86_64/build
  INSTALL_DIR       ${CMAKE_CURRENT_BINARY_DIR}/../dist/iphonesimulator-x86_64

  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake-apple.sh 
                    iphonesimulator x86_64 <SOURCE_DIR> <INSTALL_DIR>
)

# macOSX arm64 architecture
externalproject_add(libzstd-macosx-arm64
  GIT_REPOSITORY    https://github.com/facebook/zstd.git
  GIT_TAG            v1.5.5
  SOURCE_DIR        ${CMAKE_CURRENT_BINARY_DIR}/src
  BINARY_DIR        ${CMAKE_CURRENT_BINARY_DIR}/macosx-arm64/build
  INSTALL_DIR       ${CMAKE_CURRENT_BINARY_DIR}/../dist/macosx-arm64

  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake-apple.sh 
                    macosx arm64 <SOURCE_DIR> <INSTALL_DIR>
)

# macOSX x86_64 architecture
externalproject_add(libzstd-macosx-x86_64
  GIT_REPOSITORY    https://github.com/facebook/zstd.git
  GIT_TAG            v1.5.5
  SOURCE_DIR        ${CMAKE_CURRENT_BINARY_DIR}/src
  BINARY_DIR        ${CMAKE_CURRENT_BINARY_DIR}/macosx-x86_64/build
  INSTALL_DIR       ${CMAKE_CURRENT_BINARY_DIR}/../dist/macosx-x86_64

  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake-apple.sh 
                    macosx x86_64 <SOURCE_DIR> <INSTALL_DIR>
)

# Combined targets

add_custom_target(libzstd-iphoneos
  COMMENT "Building library module for iOS devices and simulators"
  COMMAND make libzstd-iphoneos-arm64 libzstd-iphonesimulator-x86_64
)

add_custom_target(libzstd-macosx
  COMMENT "Building single multi-arch library module for macOSX"
  COMMAND make libzstd-macosx-arm64 libzstd-macosx-x86_64
)
