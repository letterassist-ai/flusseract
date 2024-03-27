#!/bin/sh -eu

# NOTE: This file is invoked by CMAKE_SOURCE_DIR/cmake/ext-run-cmake-for-android.sh

# Run cmake for Tesseract build

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
  -DBUILD_TRAINING_TOOLS=OFF \
  -DDISABLE_CURL=ON \
  -DLeptonica_DIR=${INSTALL_DIR}/lib/cmake/leptonica/ \
  $SOURCE_DIR