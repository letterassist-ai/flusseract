# This cmake file builds makefiles for the libjpeg library for iOS and macOSX

set(GIT_REPOSITORY https://github.com/libjpeg-turbo/libjpeg-turbo.git)
set(GIT_TAG        3.0.2)

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

add_custom_target(libjpeg-android
  COMMENT "Building library for Android devices and simulators"
  COMMAND make libjpeg-android-armeabi-v7a libjpeg-android-arm64-v8a
)

add_custom_target(libjpeg-iphoneos
  COMMENT "Building single multi-arch library for iOS devices and simulators"
  COMMAND make libjpeg-iphoneos-arm64 libjpeg-iphonesimulator-x86_64
)

add_custom_target(libjpeg-macosx
  COMMENT "Building single multi-arch library module for macOSX"
  COMMAND make libjpeg-macosx-arm64 libjpeg-macosx-x86_64
)
