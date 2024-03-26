#!/bin/sh
set -eo pipefail

CMAKE_CURRENT_SOURCE_DIR=$1
LEPTONICA_SOURCE_DIR=$2
if [[ ( -z $CMAKE_CURRENT_SOURCE_DIR ) || ( -z $LEPTONICA_SOURCE_DIR ) ]]; then
  echo "Usage: $0 <cmake-current-source-dir> <leptonica-source-dir>"
  echo "  cmake-current-source-dir: path to the cmake-current source directory"
  echo "  leptonica-source-dir: path to the leptonica source directory"
  exit 1
fi

set -u

echo "Patching leptonica..."
cp -f ${CMAKE_CURRENT_SOURCE_DIR}/patch/Find*.cmake ${LEPTONICA_SOURCE_DIR}/cmake

cat << EOF \
  | sed -e '/\s*if(ENABLE_TIFF)/r /dev/stdin' ${LEPTONICA_SOURCE_DIR}/CMakeLists.txt \
  > ${LEPTONICA_SOURCE_DIR}/CMakeLists.txt.patched
$(cat ${CMAKE_CURRENT_SOURCE_DIR}/patch/CMakeLists.txt)
EOF
mv ${LEPTONICA_SOURCE_DIR}/CMakeLists.txt ${LEPTONICA_SOURCE_DIR}/CMakeLists.orig
mv ${LEPTONICA_SOURCE_DIR}/CMakeLists.txt.patched ${LEPTONICA_SOURCE_DIR}/CMakeLists.txt
