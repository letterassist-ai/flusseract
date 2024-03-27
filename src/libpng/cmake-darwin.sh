#!/bin/sh -eu

# NOTE: This file is invoked by CMAKE_SOURCE_DIR/cmake/ext-run-cmake-for-darwin.sh

if [[ ' iphoneos iphonesimulator ' =~ $SDK ]]; then
  export CFLAGS="-Wall -arch $ARCHITECTURE -O3 -miphoneos-version-min=${MIN_IPHONEOS_VERSION} -funwind-tables"
else
  export CFLAGS="-Wall -arch $ARCHITECTURE -O3 -mmacosx-version-min=${MIN_MACOSX_VERSION}"
fi

# Run cmake for libpng build

cmake -G"Unix Makefiles" \
  -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake \
  -DCMAKE_OSX_SYSROOT=${SDK_PATH} \
  -DCMAKE_PREFIX_PATH=${INSTALL_DIR} \
  -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_DIR} \
  -DCMAKE_C_STANDARD_INCLUDE_DIRECTORIES=${INSTALL_DIR}/include \
  -DCMAKE_BUILD_TYPE=Release \
  -DPNG_SHARED=OFF \
  -DPNG_FRAMEWORK=OFF \
  $SOURCE_DIR
