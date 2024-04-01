#!/bin/sh -eu

# NOTE: This file is invoked by CMAKE_SOURCE_DIR/cmake/ext-run-cmake-for-android.sh

# Run cmake for libjpeg build

cmake -G"Unix Makefiles" ${CMAKE_ARGS[@]} \
  -DENABLE_SHARED=FALSE \
  $SOURCE_DIR
