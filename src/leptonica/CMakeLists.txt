# This cmake file builds makefiles for the leptonica library for iOS and macOSX

set(GIT_REPOSITORY https://github.com/DanBloomberg/leptonica.git)
set(GIT_TAG        1.84.1)

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

# iOS simulator x86_64 architecture
ext_build_library_from_git(
  iphonesimulator x86_64 darwin
  ${GIT_REPOSITORY} ${GIT_TAG}
)

# macOSX arm64 architecture
ext_build_library_from_git(
  macosx arm64 darwin
  ${GIT_REPOSITORY} ${GIT_TAG}
)

# macOSX x86_64 architecture
ext_build_library_from_git(
  macosx x86_64 darwin
  ${GIT_REPOSITORY} ${GIT_TAG}
)

# Combined targets

add_custom_target(leptonica-android
  COMMENT "Building library for Android devices and simulators"
  COMMAND make leptonica-android-armeabi-v7a leptonica-android-arm64-v8a
)
add_dependencies(leptonica-android 
  libjpeg-android 
  libpng-android 
  libtiff-android
)

add_custom_target(leptonica-iphoneos
  COMMENT "Building single multi-arch library for iOS devices and simulators"
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
