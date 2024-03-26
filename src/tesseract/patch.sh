#!/bin/sh
set -eo pipefail

CMAKE_CURRENT_SOURCE_DIR=$1
TESSERACT_SOURCE_DIR=$2
if [[ ( -z $CMAKE_CURRENT_SOURCE_DIR ) || ( -z $TESSERACT_SOURCE_DIR ) ]]; then
  echo "Usage: $0 <cmake-current-source-dir> <tesseract-source-dir>"
  echo "  cmake-current-source-dir: path to the cmake-current source directory"
  echo "  tesseract-source-dir: path to the tesseract source directory"
  exit 1
fi

set -u

echo "Patching tesseract..."
cp -f ${CMAKE_CURRENT_SOURCE_DIR}/patch/Find*.cmake ${TESSERACT_SOURCE_DIR}/cmake

cat << EOF \
  | sed -e '/\s*include_directories(\${Leptonica_INCLUDE_DIRS})/r /dev/stdin' ${TESSERACT_SOURCE_DIR}/CMakeLists.txt \
  > ${TESSERACT_SOURCE_DIR}/CMakeLists.txt.patched
$(cat ${CMAKE_CURRENT_SOURCE_DIR}/patch/CMakeLists.txt)
EOF
mv ${TESSERACT_SOURCE_DIR}/CMakeLists.txt ${TESSERACT_SOURCE_DIR}/CMakeLists.orig
mv ${TESSERACT_SOURCE_DIR}/CMakeLists.txt.patched ${TESSERACT_SOURCE_DIR}/CMakeLists.txt
