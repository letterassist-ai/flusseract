#!/bin/sh -e
set -eo pipefail

INSTALL_LIB_DIR=$1
if [ -z $INSTALL_LIB_DIR ]; then
    echo "Usage: $0 <install-lib-dir>"
    echo "  install-lib-dir: path to the install directory for the combined library"
    exit 1
fi

set -u

mkdir -p $INSTALL_LIB_DIR/unpacked
cd $INSTALL_LIB_DIR/unpacked
ar -x ../libzstd.a
ar -x ../libjpeg.a
ar -x ../libtiff.a
ar -x ../libpng.a
ar -x ../libleptonica.a
cp ../libtesseract.a ../libtesseract-combined.a
ar -q ../libtesseract-combined.a *.o
