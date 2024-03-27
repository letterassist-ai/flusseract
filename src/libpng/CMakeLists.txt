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

# Combined targets

add_custom_target(libpng-android
  COMMENT "Building library for Android devices and simulators"
  COMMAND make libpng-android-armeabi-v7a libpng-android-arm64-v8a
)

add_custom_target(libpng-iphoneos
  COMMENT "Building single multi-arch library for iOS devices and simulators"
  COMMAND make libpng-iphoneos-arm64 libpng-iphonesimulator-x86_64
)

add_custom_target(libpng-macosx
  COMMENT "Building single multi-arch library module for macOSX"
  COMMAND make libpng-macosx-arm64 libpng-macosx-x86_64
)
