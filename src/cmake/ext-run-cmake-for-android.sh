#!/bin/sh
set -eox pipefail

SDK=$1
ANDROID_ABI=$2
SOURCE_DIR=$3
INSTALL_DIR=$4
CMAKE_SOURCE_DIR=$5

ANDROID_SDK=${ANDROID_SDK:-"${HOME}/Library/Android/sdk"}

if [[ (! ' android ' =~ $SDK) \
    || (! ' armeabi-v7a arm64-v8a x86 x86_64 ' =~ $ANDROID_ABI) \
    || ( -z $SOURCE_DIR ) \
    || ( -z $INSTALL_DIR ) \
    || ( -z $CMAKE_SOURCE_DIR ) ]]; then
    echo "Usage: $0 <sdk> <architecture> <source-dir> <install-dir> <cmake-source-dir>"
    echo "  sdk: android"
    echo "  architecture: "
    echo "  source-dir: path to the source directory"
    echo "  install-dir: path to the install directory"
    echo "  cmake-source-dir: path to the CMake source directory"
    exit 1
fi

set -u
  
if [[ ! -d "${ANDROID_SDK}" ]]; then
  echo "<android-sdk> argument was not provided and ${ANDROID_SDK} does not exist."
  exit 1
fi

set -u

NDK_PATH="${ANDROID_SDK}/ndk/$(ls -tr ${ANDROID_SDK}/ndk | tail -1)"
ANDROID_TOOLCHAIN="${NDK_PATH}/build/cmake/android.toolchain.cmake"
ANDROID_PLATFORM=28

if [[ ! -e ${CMAKE_SOURCE_DIR}/cmake-android.sh ]]; then
  echo "${CMAKE_SOURCE_DIR}/cmake-android.sh not found."
  exit 1
fi

if [[ -e ${CMAKE_SOURCE_DIR}/cmake-patch.sh ]]; then
  echo "Patching CMakeLists.txt in source directory..."
  cp ${SOURCE_DIR}/CMakeLists.txt ${SOURCE_DIR}/CMakeLists.orig
  source ${CMAKE_SOURCE_DIR}/cmake-patch.sh
fi

CMAKE_ARGS=(  
  -DANDROID_PLATFORM=android-${ANDROID_PLATFORM}
  -DANDROID_ABI=${ANDROID_ABI}
  -DANDROID_NDK=${NDK_PATH}
  -DCMAKE_SYSTEM_NAME=Android
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
  -DCMAKE_SYSTEM_VERSION=${ANDROID_PLATFORM}
  -DCMAKE_ANDROID_ARCH_ABI=${ANDROID_ABI}
  -DCMAKE_ANDROID_NDK=${NDK_PATH}
  -DCMAKE_TOOLCHAIN_FILE=${ANDROID_TOOLCHAIN}
  -DCMAKE_FIND_ROOT_PATH=${INSTALL_DIR}
  -DCMAKE_PREFIX_PATH=${INSTALL_DIR}
  -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_DIR}
  -DCMAKE_C_STANDARD_INCLUDE_DIRECTORIES=${INSTALL_DIR}/include
  -DCMAKE_BUILD_TYPE=Release
  $SOURCE_DIR
)

# Run cmake for external projects build
source ${CMAKE_SOURCE_DIR}/cmake-android.sh

# Reset CMakeLists.txt patch (ensures that the patch is applied only once)
if [[ -e ${CMAKE_SOURCE_DIR}/cmake-patch.sh && -e ${SOURCE_DIR}/CMakeLists.orig ]]; then
  mv -f ${SOURCE_DIR}/CMakeLists.orig ${SOURCE_DIR}/CMakeLists.txt
fi
