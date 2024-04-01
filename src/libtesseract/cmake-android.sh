#!/bin/sh -eu

# NOTE: This file is invoked by CMAKE_SOURCE_DIR/cmake/ext-run-cmake-for-android.sh

# Run cmake for Tesseract build

cmake -G"Unix Makefiles" ${CMAKE_ARGS[@]} \
  -DCMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES=${INSTALL_DIR}/include \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_TRAINING_TOOLS=OFF \
  -DDISABLE_CURL=ON \
  -DLeptonica_DIR=${INSTALL_DIR}/lib/cmake/leptonica/ \
  $SOURCE_DIR
