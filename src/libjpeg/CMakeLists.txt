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
ext_create_target_library(
  iphoneos
  "iphoneos-arm64"
)

# iOS simulator arm64 architecture
ext_build_library_from_git(
  iphonesimulator arm64 darwin
  ${GIT_REPOSITORY} ${GIT_TAG}
  ${DEPENDS}
)
# iOS simulator x86_64 architecture
ext_build_library_from_git(
  iphonesimulator x86_64 darwin
  ${GIT_REPOSITORY} ${GIT_TAG}
)
# Create multi-arch library for iOS
ext_create_target_library(
  iphonesimulator
  "iphonesimulator-arm64;iphonesimulator-x86_64"
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
# Create multi-arch library for macOSX
ext_create_target_library(
  macosx
  "macosx-arm64;macosx-x86_64"
)
