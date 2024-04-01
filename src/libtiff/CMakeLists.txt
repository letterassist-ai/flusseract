# This cmake file builds makefiles for the libtiff library for iOS and macOSX

set(GIT_REPOSITORY https://gitlab.com/libtiff/libtiff.git)
set(GIT_TAG        v4.6.0)

set(DEPENDS "libzstd;libjpeg")

# android device arm32 architecture
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
# android device x86 architecture
ext_build_library_from_git(
  android x86 android
  ${GIT_REPOSITORY} ${GIT_TAG}
  ${DEPENDS}
)
# android device x86_64 architecture
ext_build_library_from_git(
  android x86_64 android
  ${GIT_REPOSITORY} ${GIT_TAG}
  ${DEPENDS}
)

# iOS device arm64 architecture
ext_build_library_from_git(
  iphoneos arm64 darwin
  ${GIT_REPOSITORY} ${GIT_TAG}
  ${DEPENDS}
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
  ${DEPENDS}
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
  ${DEPENDS}
)
# macOSX x86_64 architecture
ext_build_library_from_git(
  macosx x86_64 darwin
  ${GIT_REPOSITORY} ${GIT_TAG}
  ${DEPENDS}
)
# Create multi-arch library for macOSX
ext_create_target_library(
  macosx
  "macosx-arm64;macosx-x86_64"
)
