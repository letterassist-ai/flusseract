# This cmake file builds makefiles for the Tesseract OCR library for iOS and macOSX

set(GIT_REPOSITORY https://github.com/tesseract-ocr/tesseract.git)
set(GIT_TAG        5.3.4)

set(DEPENDS "libleptonica")

# android device arm64 architecture
ext_build_library_from_git(
  android armeabi-v7a android
  ${GIT_REPOSITORY} ${GIT_TAG}
  ${DEPENDS}
)

# android device arm64 architecture
ext_build_library_from_git(
  android arm64-v8a android
  ${GIT_REPOSITORY} ${GIT_TAG}
  ${DEPENDS}
)

# iOS device arm64 architecture
ext_build_library_from_git(
  iphoneos arm64 darwin
  ${GIT_REPOSITORY} ${GIT_TAG}
  ${DEPENDS}
)

# iOS simulator x86_64 architecture
ext_build_library_from_git(
  iphonesimulator x86_64 darwin
  ${GIT_REPOSITORY} ${GIT_TAG}
  ${DEPENDS}
)

# Create multi-arch library for iOS
ext_create_multi_arch_library(
  ios
  "iphoneos-arm64;iphonesimulator-x86_64"
)

# macOSX arm64 architecture
ext_build_library_from_git(
  macosx arm64 darwin
  ${GIT_REPOSITORY} ${GIT_TAG}
  ${DEPENDS}
)

# macOSX x86_64 architecture
ext_build_library_from_git(
  macosx x86_64 darwin
  ${GIT_REPOSITORY} ${GIT_TAG}
  ${DEPENDS}
)

# Create multi-arch library for macOSX
ext_create_multi_arch_library(
  macos
  "macosx-arm64;macosx-x86_64"
)

# Tesseract library build targets

## Android

# add_custom_command(
#   OUTPUT ${CMAKE_BINARY_DIR}/dist/android-armeabi-v7a/lib/libtesseract.a
#   DEPENDS leptonica-android-armeabi-v7a
#   COMMENT "Building library module for Android armeabi-v7a devices"
#   BYPRODUCTS ${CMAKE_BINARY_DIR}/dist/android/lib/libtesseract.a
#   COMMAND make tesseract-armeabi-v7a
# )

# add_custom_command(
#   OUTPUT ${CMAKE_BINARY_DIR}/dist/android-arm64-v8a/lib/libtesseract.a
#   DEPENDS leptonica-android-arm64-v8a
#   COMMENT "Building library module for Android arm64-v8a devices"
#   BYPRODUCTS ${CMAKE_BINARY_DIR}/dist/android/lib/libtesseract.a
#   COMMAND make tesseract-arm64-v8a
# )

## Apple iOS and MacOSX

# set(TESSERACT_IOS_LIB ${CMAKE_BINARY_DIR}/dist/ios/lib/libtesseract.a)

# set_target_library(libtesseract iphoneos arm64)
# set_target_library(libtesseract iphonesimulator x86_64)

# add_custom_command(
#   OUTPUT ${TESSERACT_IOS_LIB}
#   COMMENT "Building library module for iOS devices"
#   BYPRODUCTS ${TESSERACT_IOS_LIB}
#   DEPENDS
#     ${libtesseract-iphoneos-arm64}          # set_target_library(libtesseract iphoneos arm64)
#     ${libtesseract-iphonesimulator-x86_64}  # set_target_library(libtesseract iphonesimulator x86_64)
#   COMMAND lipo
#     ${CMAKE_BINARY_DIR}/dist/iphoneos-arm64/lib/libtesseract.a 
#     ${CMAKE_BINARY_DIR}/dist/iphonesimulator-x86_64/lib/libtesseract-combined.a
#     -create -output ${TESSERACT_IOS_LIB}
#   COMMAND cp -r 
#     ${CMAKE_BINARY_DIR}/dist/iphoneos-arm64/include/*
#     ${CMAKE_BINARY_DIR}/dist/ios/include/
# )
# add_custom_target(tesseract-ios
#   DEPENDS ${TESSERACT_IOS_LIB}
# )

# set(TESSERACT_MACOS_LIB ${CMAKE_BINARY_DIR}/dist/macos/lib/libtesseract.a)

# set_target_library(libtesseract macosx arm64)
# set_target_library(libtesseract macosx x86_64)

# add_custom_command(
#   OUTPUT ${TESSERACT_MACOS_LIB}
#   COMMENT "Building single multi-arch library module for macOSX"
#   BYPRODUCTS ${TESSERACT_MACOS_LIB}
#   DEPENDS
#     ${libtesseract-macosx-arm64}   # set_target_library(libtesseract macosx arm64)
#     ${libtesseract-macosx-x86_64}  # set_target_library(libtesseract macosx x86_64)
#   COMMAND lipo
#     ${CMAKE_BINARY_DIR}/dist/macosx-arm64/lib/libtesseract-combined.a
#     ${CMAKE_BINARY_DIR}/dist/macosx-x86_64/lib/libtesseract-combined.a
#     -create -output ${TESSERACT_MACOS_LIB}
#   COMMAND cp -r 
#     ${CMAKE_BINARY_DIR}/dist/macosx-arm64/include/*
#     ${CMAKE_BINARY_DIR}/dist/macos/include/
# )
# add_custom_target(tesseract-macos
#   DEPENDS ${TESSERACT_MACOS_LIB}
# )
