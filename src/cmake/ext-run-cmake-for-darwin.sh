#!/bin/sh
set -eox pipefail

SDK=$1
ARCHITECTURE=$2
SOURCE_DIR=$3
INSTALL_DIR=$4
CMAKE_SOURCE_DIR=$5

if [[ (! ' iphoneos iphonesimulator macosx ' =~ $SDK) \
    || (! ' arm64 x86_64 ' =~ $ARCHITECTURE) \
    || ( -z $SOURCE_DIR ) \
    || ( -z $INSTALL_DIR ) \
    || ( -z $CMAKE_SOURCE_DIR ) ]]; then
    echo "Usage: $0 <sdk> <architecture> <source-dir> <install-dir> <cmake-source-dir>"
    echo "  sdk: iphoneos, iphonesimulator, macosx"
    echo "  architecture: arm64, x86_64"
    echo "  source-dir: path to the source directory"
    echo "  install-dir: path to the install directory"
    echo "  cmake-source-dir: path to the CMake source directory"
    exit 1
fi

set -u

SDK_PATH=`xcrun --sdk $SDK --show-sdk-path`
SDK_VERSION=$(echo "$(basename ${SDK_PATH})" | awk -F'[a-zA-Z.]+' '{print $2 "." $3}')

CLANG=`xcrun --sdk $SDK --find clang`
CLANG_PLUSPLUS=`xcrun --sdk $SDK --find clang++`

MIN_IPHONEOS_VERSION=11.0
MIN_MACOSX_VERSION=10.14

if [[ "$SDK" = "iphoneos" ]]; then
  TARGET="-target ${ARCHITECTURE}-apple-ios${MIN_IPHONEOS_VERSION}"
elif [[ "$SDK" = "iphonesimulator" ]]; then
  TARGET="-target ${ARCHITECTURE}-apple-ios${MIN_IPHONEOS_VERSION}-simulator"
else
  TARGET="-target ${ARCHITECTURE}-apple-macos${MIN_MACOSX_VERSION}"
fi

cat <<EOF >toolchain.cmake
if(DARWIN_TOOLCHAIN_INCLUDED)
  return()
endif(DARWIN_TOOLCHAIN_INCLUDED)
set(DARWIN_TOOLCHAIN_INCLUDED true)

set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_OSX_SYSROOT $SDK_PATH)
set(CMAKE_OSX_ARCHITECTURES $ARCHITECTURE CACHE INTERNAL "" FORCE)
set(CMAKE_SYSTEM_PROCESSOR $ARCHITECTURE CACHE INTERNAL "" FORCE)
set(CMAKE_C_COMPILER $CLANG)
set(CMAKE_CXX_COMPILER $CLANG_PLUSPLUS)
set(CMAKE_C_FLAGS "\${CMAKE_C_FLAGS} $TARGET -isysroot $SDK_PATH")
set(CMAKE_CXX_FLAGS "\${CMAKE_CXX_FLAGS} $TARGET -isysroot $SDK_PATH")
EOF

if [[ ! -e ${CMAKE_SOURCE_DIR}/cmake-darwin.sh ]]; then
  echo "${CMAKE_SOURCE_DIR}/cmake-darwin.sh not found."
  exit 1
fi

if [[ -e ${CMAKE_SOURCE_DIR}/cmake-patch.sh ]]; then
  echo "Patching CMakeLists.txt in source directory..."
  cp ${SOURCE_DIR}/CMakeLists.txt ${SOURCE_DIR}/CMakeLists.orig
  source ${CMAKE_SOURCE_DIR}/cmake-patch.sh
fi

# Run cmake for external projects build
source ${CMAKE_SOURCE_DIR}/cmake-darwin.sh

# Reset CMakeLists.txt patch (ensures that the patch is applied only once)
if [[ -e ${CMAKE_SOURCE_DIR}/cmake-patch.sh && -e ${SOURCE_DIR}/CMakeLists.orig ]]; then
  mv -f ${SOURCE_DIR}/CMakeLists.orig ${SOURCE_DIR}/CMakeLists.txt
fi
