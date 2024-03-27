#!/bin/sh -eu

# NOTE: This file is invoked by CMAKE_SOURCE_DIR/cmake/ext-run-cmake-for-darwin.sh

# Patch leptonica cmake files

echo "Patching leptonica..."

cp -f ${CMAKE_SOURCE_DIR}/patch/Find*.cmake ${SOURCE_DIR}/cmake

cat << EOF \
  | sed -e '/\s*if(ENABLE_TIFF)/r /dev/stdin' ${SOURCE_DIR}/CMakeLists.txt \
  > ${SOURCE_DIR}/CMakeLists.txt.patched
$(cat ${CMAKE_SOURCE_DIR}/patch/CMakeLists.txt)
EOF

mv ${SOURCE_DIR}/CMakeLists.txt.patched ${SOURCE_DIR}/CMakeLists.txt
