# This cmake file builds makefiles for the libpng library for iOS and macOSX

set(URL      https://phoenixnap.dl.sourceforge.net/project/libpng/libpng16/1.6.43/libpng-1.6.43.tar.gz)
set(URL_HASH SHA256=e804e465d4b109b5ad285a8fb71f0dd3f74f0068f91ce3cdfde618180c174925)

# android device arm64 architecture
ext_build_library_from_url(
  android armeabi-v7a android
  ${URL} ${URL_HASH}
)

# android device arm64 architecture
ext_build_library_from_url(
  android arm64-v8a android
  ${URL} ${URL_HASH}
)

# iOS device arm64 architecture
ext_build_library_from_url(
  iphoneos arm64 darwin
  ${URL} ${URL_HASH}
)

# iOS simulator x86_64 architecture
ext_build_library_from_url(
  iphonesimulator x86_64 darwin
  ${URL} ${URL_HASH}
)

# Create multi-arch library for iOS
ext_create_multi_arch_library(
  ios
  "iphoneos-arm64;iphonesimulator-x86_64"
)

# macOSX arm64 architecture
ext_build_library_from_url(
  macosx arm64 darwin
  ${URL} ${URL_HASH}
)

# macOSX x86_64 architecture
ext_build_library_from_url(
  macosx x86_64 darwin
  ${URL} ${URL_HASH}
)

# Create multi-arch library for macOSX
ext_create_multi_arch_library(
  macos
  "macosx-arm64;macosx-x86_64"
)
