# This cmake file builds makefiles for the leptonica library for iOS and macOSX

set(GIT_REPOSITORY https://github.com/DanBloomberg/leptonica.git)
set(GIT_TAG        1.84.1)

set(DEPENDS "libjpeg;libpng;libtiff")

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
