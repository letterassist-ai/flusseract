#!/bin/sh

if [[ $1 == "all" ]]; then
  flutter clean && \
    rm -fr ../flusseract.framework/ && \
    rm -fr ../build/ && \
    rm -fr ../android/.cxx && \
    rm -fr ios/Pods && \
    rm -fr ios/.symlinks && \
    rm -fr macos/Pods && \
    rm -fr macos/.symlinks && \
    flutter pub get
else
  flutter clean && \
    rm -fr ios/Pods && \
    rm -fr ios/.symlinks && \
    rm -fr macos/Pods && \
    rm -fr macos/.symlinks && \
    flutter pub get
fi
