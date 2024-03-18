# Flusseract

Flutter plugin for the [Tesseract OCR](https://tesseract-ocr.github.io/) C++ library. This plugin recreates the [gosseract](https://github.com/otiai10/gosseract) SDK as a Flutter FFI plugin.

## Getting Started

This project depends on the [Tesseract OCR](https://tesseract-ocr.github.io/) libraries which must be [installed](https://tesseract-ocr.github.io/tessdoc/Installation.html) to your development or build environment before you can run the example provided or add and use it as a dependency in your application. 

If you wish to [build Tessaract from source](https://tesseract-ocr.github.io/tessdoc/Compiling.html) additional detail for different build platforms can be found below in addition to the official documentation for building from source.

### Mac OS Build

**Install Dependencies**

```
# Packages which are always needed.
brew install \
  automake \
  autoconf \
  libtool \
  pkgconfig \
  icu4c \
  leptonica
# Packages required for training tools.
brew install pango
# Optional packages for extra features.
brew install libarchive
# Optional package for builds using g++.
brew install gcc
```

**Compile**

```
git clone https://github.com/tesseract-ocr/tesseract/ && cd tesseract
./autogen.sh && mkdir build && cd build
# Optionally add CXX=g++-8 to the configure command if you really want to use a different compiler.
BREW_PKG_PATH=/opt/homebrew/opt
../configure \
  PKG_CONFIG_PATH=${BREW_PKG_PATH}/icu4c/lib/pkgconfig:${BREW_PKG_PATH}/libarchive/lib/pkgconfig:${BREW_PKG_PATH}/libffi/lib/pkgconfig \
  && make -j
# Optionally install Tesseract.
make install
# Optionally build and install training tools.
make training
make training-install
```

## Project structure

This template uses the following structure:

* `src`: Contains the native source code, and a CmakeFile.txt file for building
  that source code into a dynamic library.

* `lib`: Contains the Dart code that defines the API of the plugin, and which
  calls into the native code using `dart:ffi`.

* platform folders (`android`, `ios`, `windows`, etc.): Contains the build files
  for building and bundling the native code library with the platform application.

## Building and bundling native code

The `pubspec.yaml` specifies FFI plugins as follows:

```yaml
  plugin:
    platforms:
      some_platform:
        ffiPlugin: true
```

This configuration invokes the native build for the various target platforms
and bundles the binaries in Flutter applications using these FFI plugins.

This can be combined with dartPluginClass, such as when FFI is used for the
implementation of one platform in a federated plugin:

```yaml
  plugin:
    implements: some_other_plugin
    platforms:
      some_platform:
        dartPluginClass: SomeClass
        ffiPlugin: true
```

A plugin can have both FFI and method channels:

```yaml
  plugin:
    platforms:
      some_platform:
        pluginClass: SomeName
        ffiPlugin: true
```

The native build systems that are invoked by FFI (and method channel) plugins are:

* For Android: Gradle, which invokes the Android NDK for native builds.
  * See the documentation in android/build.gradle.
* For iOS and MacOS: Xcode, via CocoaPods.
  * See the documentation in ios/image_processor.podspec.
  * See the documentation in macos/image_processor.podspec.
* For Linux and Windows: CMake.
  * See the documentation in linux/CMakeLists.txt.
  * See the documentation in windows/CMakeLists.txt.

## Binding to native code

To use the native code, bindings in Dart are needed.
To avoid writing these by hand, they are generated from the header file
(`src/image_processor.h`) by `package:ffigen`.
Regenerate the bindings by running `flutter pub run ffigen --config ffigen.yaml`.

## Invoking native code

Very short-running native functions can be directly invoked from any isolate.
For example, see `sum` in `lib/image_processor.dart`.

Longer-running functions should be invoked on a helper isolate to avoid
dropping frames in Flutter applications.
For example, see `sumAsync` in `lib/image_processor.dart`.

## Flutter help

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

