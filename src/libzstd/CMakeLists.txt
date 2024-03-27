# This cmake file builds makefiles for the libzstd library for iOS and macOSX

set(GIT_REPOSITORY https://github.com/facebook/zstd.git)
set(GIT_TAG        v1.5.5)

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

add_custom_target(libzstd-android
  COMMENT "Building library for Android devices and simulators"
  COMMAND make libzstd-android-armeabi-v7a libzstd-android-arm64-v8a
)

add_custom_target(libzstd-iphoneos
  COMMENT "Building single multi-arch library for iOS devices and simulators"
  COMMAND make libzstd-iphoneos-arm64 libzstd-iphonesimulator-x86_64
)

add_custom_target(libzstd-macosx
  COMMENT "Building single multi-arch library module for macOSX"
  COMMAND make libzstd-macosx-arm64 libzstd-macosx-x86_64
)
