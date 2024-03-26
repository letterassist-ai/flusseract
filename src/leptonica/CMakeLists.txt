# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

include(ExternalProject)

# iOS device arm64 architecture
externalproject_add(leptonica-iphoneos-arm64
  GIT_REPOSITORY    https://github.com/DanBloomberg/leptonica.git
  GIT_TAG           1.84.1
  SOURCE_DIR        ${CMAKE_CURRENT_BINARY_DIR}/src
  BINARY_DIR        ${CMAKE_CURRENT_BINARY_DIR}/iphoneos-arm64/build
  INSTALL_DIR       ${CMAKE_CURRENT_BINARY_DIR}/../dist/iphoneos-arm64

  PATCH_COMMAND     ${CMAKE_CURRENT_SOURCE_DIR}/patch.sh ${CMAKE_CURRENT_SOURCE_DIR} <SOURCE_DIR>

  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake-apple.sh 
                    iphoneos arm64 <SOURCE_DIR> <INSTALL_DIR>
)

# iOS simulator x86_64 architecture
externalproject_add(leptonica-iphonesimulator-x86_64
  GIT_REPOSITORY    https://github.com/DanBloomberg/leptonica.git
  GIT_TAG           1.84.1
  SOURCE_DIR        ${CMAKE_CURRENT_BINARY_DIR}/src
  BINARY_DIR        ${CMAKE_CURRENT_BINARY_DIR}/iphonesimulator-x86_64/build
  INSTALL_DIR       ${CMAKE_CURRENT_BINARY_DIR}/../dist/iphonesimulator-x86_64

  PATCH_COMMAND     ${CMAKE_CURRENT_SOURCE_DIR}/patch.sh ${CMAKE_CURRENT_SOURCE_DIR} <SOURCE_DIR>

  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake-apple.sh 
                    iphonesimulator x86_64 <SOURCE_DIR> <INSTALL_DIR>
)

# macOSX arm64 architecture
externalproject_add(leptonica-macosx-arm64
  GIT_REPOSITORY    https://github.com/DanBloomberg/leptonica.git
  GIT_TAG           1.84.1
  SOURCE_DIR        ${CMAKE_CURRENT_BINARY_DIR}/src
  BINARY_DIR        ${CMAKE_CURRENT_BINARY_DIR}/macosx-arm64/build
  INSTALL_DIR       ${CMAKE_CURRENT_BINARY_DIR}/../dist/macosx-arm64

  PATCH_COMMAND     ${CMAKE_CURRENT_SOURCE_DIR}/patch.sh ${CMAKE_CURRENT_SOURCE_DIR} <SOURCE_DIR>

  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake-apple.sh 
                    macosx arm64 <SOURCE_DIR> <INSTALL_DIR>
)

# macOSX x86_64 architecture
externalproject_add(leptonica-macosx-x86_64
  GIT_REPOSITORY    https://github.com/DanBloomberg/leptonica.git
  GIT_TAG           1.84.1
  SOURCE_DIR        ${CMAKE_CURRENT_BINARY_DIR}/src
  BINARY_DIR        ${CMAKE_CURRENT_BINARY_DIR}/macosx-x86_64/build
  INSTALL_DIR       ${CMAKE_CURRENT_BINARY_DIR}/../dist/macosx-x86_64

  PATCH_COMMAND     ${CMAKE_CURRENT_SOURCE_DIR}/patch.sh ${CMAKE_CURRENT_SOURCE_DIR} <SOURCE_DIR>

  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake-apple.sh 
                    macosx x86_64 <SOURCE_DIR> <INSTALL_DIR>
)

# Combined targets

add_custom_target(leptonica-iphoneos
  COMMENT "Building library module for iOS devices and simulators"
  COMMAND make leptonica-iphoneos-arm64 leptonica-iphonesimulator-x86_64
)
add_dependencies(leptonica-iphoneos 
  libjpeg-iphoneos 
  libpng-iphoneos 
  libtiff-iphoneos
)

add_custom_target(leptonica-macosx
  COMMENT "Building single multi-arch library module for macOSX"
  COMMAND make leptonica-macosx-arm64 leptonica-macosx-x86_64
)
add_dependencies(leptonica-macosx 
  libjpeg-macosx 
  libpng-macosx 
  libtiff-macosx
)
