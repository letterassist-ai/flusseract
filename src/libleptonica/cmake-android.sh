#!/bin/sh -eu

# NOTE: This file is invoked by CMAKE_SOURCE_DIR/cmake/ext-run-cmake-for-android.sh

# Run cmake for Leptonica build

cmake -G"Unix Makefiles" ${CMAKE_ARGS[@]} \
  -DCMAKE_MODULE_LINKER_FLAGS=-whole-archive \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_PROG=0 \
  -DENABLE_GIF=OFF \
  -DENABLE_WEBP=OFF \
  -DENABLE_OPENJPEG=OFF \
  $SOURCE_DIR
