#!/bin/sh -eu

# NOTE: This file is invoked by CMAKE_SOURCE_DIR/cmake/ext-run-cmake-for-darwin.sh

# Patch tesseract cmake files

echo "Patching tesseract..."

cp -f ${CMAKE_SOURCE_DIR}/patch/Find*.cmake ${SOURCE_DIR}/cmake

cat << EOF \
  | sed -e '/\s*include_directories(\${Leptonica_INCLUDE_DIRS})/r /dev/stdin' ${SOURCE_DIR}/CMakeLists.txt \
  > ${SOURCE_DIR}/CMakeLists.txt.patched
$(cat ${CMAKE_SOURCE_DIR}/patch/CMakeLists.txt)
EOF
mv ${SOURCE_DIR}/CMakeLists.txt.patched ${SOURCE_DIR}/CMakeLists.txt

sed '/if(ANDROID)/,+8 d' \
  ${SOURCE_DIR}/CMakeLists.txt \
  > ${SOURCE_DIR}/CMakeLists.txt.patched
mv ${SOURCE_DIR}/CMakeLists.txt.patched ${SOURCE_DIR}/CMakeLists.txt
