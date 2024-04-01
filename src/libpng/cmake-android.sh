#!/bin/sh -eu

# NOTE: This file is invoked by CMAKE_SOURCE_DIR/cmake/ext-run-cmake-for-android.sh

# Run cmake for libpng build

cmake -G"Unix Makefiles" ${CMAKE_ARGS[@]} \
  -DPNG_SHARED=OFF \
  $SOURCE_DIR
