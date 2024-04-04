#!/bin/sh

if [[ $1 == "all" ]]; then
  flutter clean \
    && rm -fr ../.dart_tool/build \
    && rm -fr ../android/.cxx \
    && rm -fr ios/Pods \
    && rm -fr ios/.symlinks \
    && rm -fr macos/Pods \
    && rm -fr macos/.symlinks \
    && rm -fr .dart_tool/build \
    && rm -fr .flutter-plugins* \
    && flutter pub get
else
  flutter clean \
    && flutter pub get
fi
