# This cmake file builds makefiles for the libtiff library for iOS and macOSX

set(GIT_REPOSITORY https://gitlab.com/libtiff/libtiff.git)
set(GIT_TAG        v4.6.0)

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

add_custom_target(libtiff-android
  COMMENT "Building library for Android devices and simulators"
  COMMAND make libtiff-android-armeabi-v7a libtiff-android-arm64-v8a
)
add_dependencies(libtiff-android
  libzstd-android 
  libjpeg-android
)

add_custom_target(libtiff-iphoneos
  COMMENT "Building single multi-arch library for iOS devices and simulators"
  COMMAND make libtiff-iphoneos-arm64 libtiff-iphonesimulator-x86_64
)
add_dependencies(libtiff-iphoneos 
  libzstd-iphoneos 
  libjpeg-iphoneos
)

add_custom_target(libtiff-macosx 
  COMMENT "Building single multi-arch library module for macOSX"
  COMMAND make libtiff-macosx-arm64 libtiff-macosx-x86_64
)
add_dependencies(libtiff-macosx 
  libzstd-macosx 
  libjpeg-macosx
)
