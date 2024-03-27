# This cmake file builds makefiles for the Tesseract OCR library for iOS and macOSX

set(GIT_REPOSITORY https://github.com/tesseract-ocr/tesseract.git)
set(GIT_TAG        5.3.4)

# android device arm64 architecture
ext_build_library_from_git(
  android armeabi-v7a android
  ${GIT_REPOSITORY} ${GIT_TAG}
)

# android device arm64 architecture
ext_build_library_from_git(
  android arm64-v8a android
  ${GIT_REPOSITORY} ${GIT_TAG}
)

# iOS device arm64 architecture
ext_build_library_from_git(
  iphoneos arm64 darwin
  ${GIT_REPOSITORY} ${GIT_TAG}
)
ext_create_combined_library(
  iphoneos arm64
)

# iOS simulator x86_64 architecture
ext_build_library_from_git(
  iphonesimulator x86_64 darwin
  ${GIT_REPOSITORY} ${GIT_TAG}
)
ext_create_combined_library(
  iphonesimulator x86_64
)

# macOSX arm64 architecture
ext_build_library_from_git(
  macosx arm64 darwin
  ${GIT_REPOSITORY} ${GIT_TAG}
)
ext_create_combined_library(
  macosx arm64
)

# macOSX x86_64 architecture
ext_build_library_from_git(
  macosx x86_64 darwin
  ${GIT_REPOSITORY} ${GIT_TAG}
)
ext_create_combined_library(
  macosx x86_64
)

# Combined targets

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/dist/iphoneos/lib)
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

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/dist/macosx/lib)
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
