#!/bin/sh

flutter clean && \
  rm -fr ../flusseract.framework/ && \
  rm -fr ../build/ && \
  rm -fr ../android/.cxx && \
  rm -fr ios/Pods && \
  rm -fr ios/.symlinks && \
  rm -fr macos/Pods && \
  rm -fr macos/.symlinks && \
  flutter pub get