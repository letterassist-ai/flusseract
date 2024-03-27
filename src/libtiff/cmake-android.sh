#!/bin/sh -eu

# NOTE: This file is invoked by CMAKE_SOURCE_DIR/cmake/ext-run-cmake-for-android.sh

# Run cmake for libtiff build

cmake -G"Unix Makefiles" \
  -DANDROID_PLATFORM=${ANDROID_PLATFORM} \
  -DCMAKE_TOOLCHAIN_FILE=${ANDROID_TOOLCHAIN} \
  -DCMAKE_ANDROID_ARCH_ABI=${ANDROID_ABI} \
  -DCMAKE_PREFIX_PATH=${INSTALL_DIR} \
  -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_DIR} \
  -DCMAKE_C_STANDARD_INCLUDE_DIRECTORIES=${INSTALL_DIR}/include \
  -DCMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES=${INSTALL_DIR}/include \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -Dtiff-tools=OFF \
  -Dtiff-tests=OFF \
  -Dtiff-contrib=OFF \
  -Dtiff-docs=OFF \
  -Dwebp=OFF \
  $SOURCE_DIR
