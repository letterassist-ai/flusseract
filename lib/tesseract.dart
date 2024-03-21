import 'dart:io';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:ffi_helper_ab/ffi_helper.dart';

import 'flusseract_bindings.dart' as bindings;
import 'flusseract_bindings_generated.dart' as generated;

import 'pix_image.dart';

class Tesseract extends ForeignInstanceStub {
  /// Languages are languages to be detected. If not
  /// specified, it's gonna be "eng".
  final List<String> _languages;

  final Map<String, String> _variables = {};

  final String _tessDataPath;
  final String _configFilePath;
  bool _needsInit = true;

  Tesseract({
    /// The path to the Tesseract data directory.
    List<String> languages = const ['eng'],
    String? tessDataPath,
    String? configFilePath,
  })  : _languages = languages,
        _tessDataPath =
            tessDataPath ?? Platform.environment['TESS_DATA_PATH'] ?? '',
        _configFilePath =
            configFilePath ?? Platform.environment['TESS_CONFIG_FILE'] ?? '',
        super(
          bindings.flusseract.Create(),
          bindings.flusseract.Destroy,
        );

  /// Adds a language to the list of languages to be
  /// detected.
  void addLanguage(String language) {
    _languages.add(language);
    _needsInit = true;
  }

  /// Adds a list of languages to the list of languages
  /// to be detected.
  void addLanguages(List<String> languages) {
    _languages.addAll(languages);
    _needsInit = true;
  }

  /// Disables debug output from Tesseract.
  void disableDebug() {
    setVariable(_debugFile, '/dev/null');
  }

  /// Sets whitelist chars.
  ///
  /// ref: https://tesseract-ocr.github.io/tessdoc/ImproveQuality#dictionaries-word-lists-and-patterns
  ///
  void setWhiteList(String whitelist) {
    setVariable(_tesseditCharWhitelist, whitelist);
  }

  /// Sets blacklist chars.
  ///
  /// ref: https://tesseract-ocr.github.io/tessdoc/ImproveQuality#dictionaries-word-lists-and-patterns
  ///
  void setBlackList(String blacklist) {
    setVariable(_tesseditCharBlacklist, blacklist);
  }

  /// Sets the value of a Tesseract variable.
  void setVariable(String name, String value) {
    _variables[name] = value;

    // Variables can be set only after the Tesseract
    // instance is initialized. Otherwise, the variables
    // can be set directly on the Tesseract instance.
    if (!_needsInit) {
      _setVariable(name, value);
    }
  }

  /// Sets "Page Segmentation Mode" (PSM) to detect layout
  /// of characters.
  ///
  /// ref: https://tesseract-ocr.github.io/tessdoc/ImproveQuality#page-segmentation-method
  ///
  void setPageSegMode(PageSegMode mode) {
    bindings.flusseract.SetPageSegMode(handle, mode.index);
  }

  /// Executes character recognition on the given document
  /// image and returns the detected text.
  Future<String> utf8Text(PixImage image) async {
    if (_needsInit) {
      _init();
    }

    bindings.flusseract.SetPixImage(
      handle,
      image.handle,
    );
    final text = bindings.flusseract.UTF8Text(handle);
    try {
      return text.cast<Utf8>().toDartString();
    } finally {
      calloc.free(text);
    }
  }

  /// Executes character recognition on the given document
  /// imageand returns the detected text in hOCR format.
  ///
  /// ref: https://en.wikipedia.org/wiki/HOCR
  ///
  Future<String> hocrText(PixImage image) async {
    if (_needsInit) {
      _init();
    }

    bindings.flusseract.SetPixImage(
      handle,
      image.handle,
    );
    final text = bindings.flusseract.HOCRText(handle);
    try {
      return text.cast<Utf8>().toDartString();
    } finally {
      calloc.free(text);
    }
  }

  /// Retrieves the bounding boxes of the detected text.
  List<BoundingBox> getBoundingBoxes(PageIteratorLevel level) {
    if (_needsInit) {
      _init();
    }

    final boxes = bindings.flusseract.GetBoundingBoxes(
      handle,
      level.index,
    );
    try {
      final count = boxes.ref.length;
      final data = boxes.ref.boxes.cast<generated.bounding_box>();
      final boundingBoxes = <BoundingBox>[];
      for (var i = 0; i < count; i++) {
        final box = data[i];
        boundingBoxes.add(BoundingBox._(box));
      }
      return boundingBoxes;
    } finally {
      calloc.free(boxes.ref.boxes);
      calloc.free(boxes);
    }
  }

  // Sets the variable on the Tesseract instance.
  void _setVariable(String name, String value) {
    ffi.Pointer<ffi.Char>? namePtr, valuePtr;

    try {
      namePtr = name.toNativeUtf8().cast<ffi.Char>();
      valuePtr = value.toNativeUtf8().cast<ffi.Char>();
      bindings.flusseract.SetVariable(handle, namePtr, valuePtr);
    } finally {
      if (namePtr != null) calloc.free(namePtr);
      if (valuePtr != null) calloc.free(valuePtr);
    }
  }

  // Initializes the Tesseract instance.
  void _init() {
    if (!_needsInit) {
      return;
    }

    ffi.Pointer<ffi.Char> languagesPtr = ffi.nullptr,
        configFilePathPtr = ffi.nullptr,
        tessDataPathPtr = ffi.nullptr,
        errorBufferPtr = ffi.nullptr;

    try {
      if (_languages.isNotEmpty) {
        languagesPtr = _languages.join('+').toNativeUtf8().cast<ffi.Char>();
      }
      if (_configFilePath.isNotEmpty) {
        if (!File(_configFilePath).existsSync()) {
          throw TesseractInitException(
            'Config file not found: $_configFilePath',
          );
        }
        configFilePathPtr = _configFilePath.toNativeUtf8().cast<ffi.Char>();
      }
      if (_tessDataPath.isNotEmpty) {
        if (!Directory(_tessDataPath).existsSync()) {
          throw TesseractInitException(
            'Tess data path not found: $_tessDataPath',
          );
        }
        tessDataPathPtr = _tessDataPath.toNativeUtf8().cast<ffi.Char>();
      }
      errorBufferPtr = calloc.allocate<ffi.Char>(512);

      final res = bindings.flusseract.Init(
        handle,
        tessDataPathPtr,
        languagesPtr,
        configFilePathPtr,
        errorBufferPtr,
      );
      if (res != 0) {
        final error = errorBufferPtr.cast<Utf8>().toDartString();
        throw TesseractInitException(
          'failed to initialize TessBaseAPI with code $res: $error',
        );
      }

      _variables.forEach((name, value) {
        _setVariable(name, value);
      });

      _needsInit = false;
    } finally {
      if (languagesPtr != ffi.nullptr) calloc.free(languagesPtr);
      if (configFilePathPtr != ffi.nullptr) calloc.free(configFilePathPtr);
      if (tessDataPathPtr != ffi.nullptr) calloc.free(tessDataPathPtr);
      if (errorBufferPtr != ffi.nullptr) calloc.free(errorBufferPtr);
    }
  }

  /// Returns the version of the Tesseract library.
  static String version() {
    final tesseract = Tesseract();
    try {
      final v = bindings.flusseract.Version(tesseract.handle);
      final version = v.cast<Utf8>().toDartString();
      return version;
    } finally {
      tesseract.dispose();
    }
  }

  /// Clears any library-level memory caches. There are a variety
  /// of expensive-to-load constant data structures (mostly language
  /// dictionaries) that are cached globally – surviving the Init()
  /// and End() of individual TessBaseAPI's. This function allows
  /// the clearing of these caches.
  static void clearPersistentCache() {
    final tesseract = Tesseract();
    try {
      bindings.flusseract.ClearPersistentCache(tesseract.handle);
    } finally {
      tesseract.dispose();
    }
  }

  /// Returns the path to the Tesseract data directory.
  static get defaultTessDataPath {
    final path = bindings.flusseract.GetDataPath();
    try {
      return path.cast<Utf8>().toDartString();
    } finally {
      calloc.free(path);
    }
  }
}

/// Tessaract PageSegMode. See following links for more information.
///
/// https://github.com/tesseract-ocr/tesseract/wiki/ImproveQuality#page-segmentation-method
/// https://github.com/tesseract-ocr/tesseract/blob/a18620cfea33d03032b71fe1b9fc424777e34252/ccstruct/publictypes.h#L158-L183
///
enum PageSegMode {
  osdOnly, // Orientation and script detection only.
  autoOsd, // Automatic page segmentation with orientation and script detection. (OSD)
  autoOnly, // Automatic page segmentation, but no OSD, or OCR.
  auto, // Fully automatic page segmentation, but no OSD. (Default)
  singleColumn, // Assume a single column of text of variable sizes.
  singleBlockVertText, // Assume a single uniform block of vertically aligned text.
  singleBlock, // Assume a single uniform block of text. (Default)
  singleLine, // Treat the image as a single text line.
  singleWord, // Treat the image as a single word.
  circleWord, // Treat the image as a single word in a circle.
  singleChar, // Treat the image as a single character.
  sparseText, // Find as much text as possible in no particular order.
  sparseTextOsd, // Sparse text with orientation and script detection.
  rawLine, // Treat the image as a single text line, bypassing hacks that are Tesseract-specific.
}

/// Tesseract PageIteratorLevel. Represents the hierarchy of the
/// page elements used in ResultIterator. See following links for more
/// information.
///
/// https://github.com/tesseract-ocr/tesseract/blob/a18620cfea33d03032b71fe1b9fc424777e34252/ccstruct/publictypes.h#L219-L225
///
enum PageIteratorLevel {
  block, // Block of text/image/separator line.
  para, // Paragraph within a block.
  textline, // Line within a paragraph.
  word, // Word within a textline.
  symbol, // Symbol/character within a word.
}

/// Tessearact variable keys
const _debugFile = 'debug_file';
const _tesseditCharWhitelist = 'tessedit_char_whitelist';
const _tesseditCharBlacklist = 'tessedit_char_blacklist';

/// Bounding box for a detected text.
class BoundingBox {
  late final int x1;
  late final int y1;
  late final int x2;
  late final int y2;
  late final String word;
  late final double confidence;
  late final int blockNum;
  late final int parNum;
  late final int lineNum;
  late final int wordNum;

  BoundingBox._(generated.bounding_box box) {
    x1 = box.x1;
    y1 = box.y1;
    x2 = box.x2;
    y2 = box.y2;
    word = box.word.cast<Utf8>().toDartString();
    confidence = box.confidence;
    blockNum = box.block_num;
    parNum = box.par_num;
    lineNum = box.line_num;
    wordNum = box.word_num;
  }

  @override
  String toString() => 'BoundingBox('
      'x1: $x1, y1: $y1, x2: $x2, y2: $y2, '
      'word: "$word", confidence: ${confidence.toStringAsFixed(2)}%)';
}

/// Tesseract Initialization exception
class TesseractInitException implements Exception {
  final String message;

  TesseractInitException(this.message);

  @override
  String toString() => 'TesseractInitException: $message';
}
