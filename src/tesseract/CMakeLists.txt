# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

include(ExternalProject)

function(build_combined_library EXTERNAL_TARGET)
  ExternalProject_Add_Step(${EXTERNAL_TARGET}
    build_combined_library DEPENDEES install
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/create-combined-library.sh <INSTALL_DIR>/lib
  )
endfunction(build_combined_library)

# iOS device arm64 architecture
externalproject_add(tesseract-iphoneos-arm64
  GIT_REPOSITORY    https://github.com/tesseract-ocr/tesseract.git
  GIT_TAG           5.3.4
  SOURCE_DIR        ${CMAKE_CURRENT_BINARY_DIR}/src
  BINARY_DIR        ${CMAKE_CURRENT_BINARY_DIR}/iphoneos-arm64/build
  INSTALL_DIR       ${CMAKE_CURRENT_BINARY_DIR}/../dist/iphoneos-arm64

  PATCH_COMMAND     ${CMAKE_CURRENT_SOURCE_DIR}/patch.sh ${CMAKE_CURRENT_SOURCE_DIR} <SOURCE_DIR>

  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake-apple.sh 
                    iphoneos arm64 <SOURCE_DIR> <INSTALL_DIR>
)
build_combined_library(tesseract-iphoneos-arm64)

# iOS simulator x86_64 architecture
externalproject_add(tesseract-iphonesimulator-x86_64
  GIT_REPOSITORY    https://github.com/tesseract-ocr/tesseract.git
  GIT_TAG           5.3.4
  SOURCE_DIR        ${CMAKE_CURRENT_BINARY_DIR}/src
  BINARY_DIR        ${CMAKE_CURRENT_BINARY_DIR}/iphonesimulator-x86_64/build
  INSTALL_DIR       ${CMAKE_CURRENT_BINARY_DIR}/../dist/iphonesimulator-x86_64

  PATCH_COMMAND     ${CMAKE_CURRENT_SOURCE_DIR}/patch.sh ${CMAKE_CURRENT_SOURCE_DIR} <SOURCE_DIR>

  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake-apple.sh 
                    iphonesimulator x86_64 <SOURCE_DIR> <INSTALL_DIR>
)
build_combined_library(tesseract-iphonesimulator-x86_64)

# macOSX arm64 architecture
externalproject_add(tesseract-macosx-arm64
  GIT_REPOSITORY    https://github.com/tesseract-ocr/tesseract.git
  GIT_TAG           5.3.4
  SOURCE_DIR        ${CMAKE_CURRENT_BINARY_DIR}/src
  BINARY_DIR        ${CMAKE_CURRENT_BINARY_DIR}/macosx-arm64/build
  INSTALL_DIR       ${CMAKE_CURRENT_BINARY_DIR}/../dist/macosx-arm64

  PATCH_COMMAND     ${CMAKE_CURRENT_SOURCE_DIR}/patch.sh ${CMAKE_CURRENT_SOURCE_DIR} <SOURCE_DIR>

  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake-apple.sh 
                    macosx arm64 <SOURCE_DIR> <INSTALL_DIR>
)
build_combined_library(tesseract-macosx-arm64)

# macOSX x86_64 architecture
externalproject_add(tesseract-macosx-x86_64
  GIT_REPOSITORY    https://github.com/tesseract-ocr/tesseract.git
  GIT_TAG           5.3.4
  SOURCE_DIR        ${CMAKE_CURRENT_BINARY_DIR}/src
  BINARY_DIR        ${CMAKE_CURRENT_BINARY_DIR}/macosx-x86_64/build
  INSTALL_DIR       ${CMAKE_CURRENT_BINARY_DIR}/../dist/macosx-x86_64

  PATCH_COMMAND     ${CMAKE_CURRENT_SOURCE_DIR}/patch.sh ${CMAKE_CURRENT_SOURCE_DIR} <SOURCE_DIR>

  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/cmake-apple.sh 
                    macosx x86_64 <SOURCE_DIR> <INSTALL_DIR>
)
build_combined_library(tesseract-macosx-x86_64)

# Combined targets

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/../dist/iphoneos/lib)
add_custom_target(tesseract-iphoneos
  COMMENT "Building library module for iOS devices"
  COMMAND make tesseract-iphoneos-arm64 tesseract-iphonesimulator-x86_64
  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/../dist/iphoneos/lib
  COMMAND lipo
    ${CMAKE_CURRENT_BINARY_DIR}/../dist/iphoneos-arm64/lib/libtesseract.a 
    ${CMAKE_CURRENT_BINARY_DIR}/../dist/iphonesimulator-x86_64/lib/libtesseract-combined.a
    -create -output ${CMAKE_CURRENT_BINARY_DIR}/../dist/iphoneos/lib/libtesseract.a    
  COMMAND cp -r 
    ${CMAKE_CURRENT_BINARY_DIR}/../dist/iphoneos-arm64/include 
    ${CMAKE_CURRENT_BINARY_DIR}/../dist/iphoneos/
)
add_dependencies(tesseract-iphoneos 
  leptonica-iphoneos
)

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/../dist/macosx/lib)
add_custom_target(tesseract-macosx
  COMMENT "Building single multi-arch library module for macOSX"
  COMMAND make tesseract-macosx-arm64 tesseract-macosx-x86_64
  COMMAND lipo
    ${CMAKE_CURRENT_BINARY_DIR}/../dist/macosx-arm64/lib/libtesseract-combined.a
    ${CMAKE_CURRENT_BINARY_DIR}/../dist/macosx-x86_64/lib/libtesseract-combined.a
    -create -output ${CMAKE_CURRENT_BINARY_DIR}/../dist/macosx/lib/libtesseract.a
  COMMAND cp -r 
    ${CMAKE_CURRENT_BINARY_DIR}/../dist/macosx-arm64/include 
    ${CMAKE_CURRENT_BINARY_DIR}/../dist/macosx/
)
add_dependencies(tesseract-macosx 
  leptonica-macosx
)
