#!/bin/sh -eu

# NOTE: This file is invoked by CMAKE_SOURCE_DIR/cmake/ext-run-cmake-for-android.sh

# Run cmake for libzstd build

cmake -G"Unix Makefiles" ${CMAKE_ARGS[@]} \
  -DCMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES=${INSTALL_DIR}/include \
  -DZSTD_BUILD_SHARED=OFF \
  -DZSTD_LEGACY_SUPPORT=OFF \
  $SOURCE_DIR/build/cmake
