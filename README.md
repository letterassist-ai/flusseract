# Flusseract

Flutter plugin for the [Tesseract OCR](https://tesseract-ocr.github.io/) C++ library. This plugin provides bindings for [Flutter](https://flutter.dev/) that are similar to that provided by the [gosseract](https://github.com/otiai10/gosseract) SDK for Golang. It implements support for OCR using pure Tesseract solutions across all platforms. However, both Andriod and MacOS/iOS provide native OCR capability via the [Google ML-Kit for Mobile](https://developers.google.com/ml-kit) and [Apple's Vision Framework](https://developer.apple.com/documentation/vision/recognizing_text_in_images) respectively. They may have better and more accurate models and if your use case is specific to those eco-systems you should consider using the native capability.

## Getting Started

This project builds the [Tesseract OCR](https://tesseract-ocr.github.io/) libraries and its dependencies from source. The plugin is built using make files generated via [CMake](https://cmake.org/). The build root can be found at `src/CMakeLists.txt` which adds Tesseract and its dependencies as external sub-projects that are downloaded directly from their official git our download site. The plugin wraps the Tesseract API within the `Flusseract` Dart class and exposes the most common functions used for OCR.

You can use the *example* application to build and run the plugin on the various supported platforms. If you want to develop this project then follow the instructions below to set up the environment so you can run the unit tests during development.

## Using the Plugin

### Install

Add the plugin as a dependency to you Flutter app's pubspec.yaml.

```
dependencies:
  .
  .
  flusseract: ^0.1.1
  .
  .
```

The initial build of the plugin will take around 10 minutes as when used within a Flutter app it will download and compile Tesseract and its dependencies from source for the target platform.

> For MacOS and iOS builds you can find the native C/C++ library build logs within the `<app>/<macos|ios>/Pods/flusseract/build/` folder.

### Usage

The tesseract data files packaged with the application's asset bundle need to be copied to a sandbox folder before the Tesseract library can load them. You will need at least the default trained language model (eng.trainedata) for Tesseract to intialize. Trained models may be found in the [tessdata](https://github.com/tesseract-ocr/tessdata) git repository. This initialization can be done via `TessData.Init()` which is an asynchronous call that needs to be run before any text extraction calls.

```
.
.

import 'package:flusseract/flusseract.dart' as flusseract;

.
.

await TessData.init();

.
.

rootBundle.load('assets/test-helloworld.png').then(
  (imageData) {

    final image = flusseract.PixImage.fromBytes(
      imageData.buffer.asUint8List(),
    );

    final tesseract = flusseract.Tesseract(
      tessDataPath: TessData.tessDataPath,
    );

    tesseract.utf8Text(image).then(
      (ocrText) {
        setState(() {
          _ocrText = ocrText;
        });
      }
    );    
  },
);
```

### Developing on Mac OSX Systems

**Install Dependencies**

```
# Packages which are always needed.
brew install \
  nasm \
  automake \
  autoconf \
  libtool \
  pkgconfig

# Optional package for builds using g++.
brew install gcc

# Packages required for training tools.
brew install pango

# Build dependencoes.  
brew install \
  icu4c \
  leptonica \
  tesseract

# Optional packages for extra features.
brew install libarchive
```

**Building and Running Unit Tests**

```
mkdir build
cd build
PLATFORM_NAME=macosx cmake ../src
make test
```

## Project structure

This template uses the following structure:

* `example`: Contains an example app that uses the plugin.

* `src`: Contains the native source code, and a CmakeFile.txt file for building
  that source code into a dynamic library.

* `lib`: Contains the Dart code that defines the API of the plugin, and which
  calls into the native code using `dart:ffi`.

* `test`: Contains the Dart unit tests that can be used to develop and test the plugin outside the context of device.

* platform folders (`android`, `ios`, `windows`, etc.): Contains the build files
  for building and bundling the native code library with the platform application.

## Flutter help

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

