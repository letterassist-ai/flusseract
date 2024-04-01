#!/bin/sh -eu

# NOTE: This file is invoked by CMAKE_SOURCE_DIR/cmake/ext-run-cmake-for-android.sh

# Run cmake for libtiff build

cmake -G"Unix Makefiles" ${CMAKE_ARGS[@]} \
  -DCMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES=${INSTALL_DIR}/include \
  -DBUILD_SHARED_LIBS=OFF \
  -Dtiff-tools=OFF \
  -Dtiff-tests=OFF \
  -Dtiff-contrib=OFF \
  -Dtiff-docs=OFF \
  -Dwebp=OFF \
  $SOURCE_DIR
