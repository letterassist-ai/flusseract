#!/bin/sh
set -eo pipefail

APPLE_SDK=$1
ARCHITECTURE=$2
SOURCE_DIR=$3
INSTALL_DIR=$4

if [[ (! ' iphoneos iphonesimulator macosx ' =~ $APPLE_SDK) \
    || (! ' x86_64 arm64 ' =~ $ARCHITECTURE) \
    || ( -z $SOURCE_DIR ) \
    || ( -z $INSTALL_DIR ) ]]; then
    echo "Usage: $0 <sdk> <architecture> <source-dir> <install-dir>"
    echo "  sdk: iphoneos, iphonesimulator, macosx"
    echo "  architecture: x86_64, arm64"
    echo "  source-dir: path to the source directory"
    echo "  install-dir: path to the install directory"
    exit 1
fi

set -u

SDK_PATH=`xcrun --sdk $APPLE_SDK --show-sdk-path`
CLANG=`xcrun --sdk $APPLE_SDK --find clang`
CLANGPLUSPLUS=`xcrun --sdk $APPLE_SDK --find clang++`

cat <<EOF >toolchain.cmake
set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_OSX_ARCHITECTURES $ARCHITECTURE CACHE INTERNAL "" FORCE)
set(CMAKE_SYSTEM_PROCESSOR $ARCHITECTURE CACHE INTERNAL "" FORCE)
set(CMAKE_C_COMPILER $CLANG)
set(CMAKE_CXX_COMPILER $CLANGPLUSPLUS)
EOF

if [[ ' iphoneos iphonesimulator ' =~ $APPLE_SDK ]]; then
  export CFLAGS="-Wall -arch $ARCHITECTURE -O3 -miphoneos-version-min=11.0 -funwind-tables"
else
  export CFLAGS="-Wall -arch $ARCHITECTURE -O3 -mmacosx-version-min=10.13"
fi

cmake -G"Unix Makefiles" \
  -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
  -DCMAKE_OSX_SYSROOT=${SDK_PATH} \
  -DCMAKE_PREFIX_PATH=${INSTALL_DIR} \
  -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_DIR} \
  -DCMAKE_C_STANDARD_INCLUDE_DIRECTORIES=${INSTALL_DIR}/include \
  -DCMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES=${INSTALL_DIR}/include \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_TRAINING_TOOLS=OFF \
  -DDISABLE_CURL=ON \
  $SOURCE_DIR

# Reset CMakeLists.txt patch (ensures that the patch is applied only once)
mv -f ${SOURCE_DIR}/CMakeLists.orig ${SOURCE_DIR}/CMakeLists.txt
