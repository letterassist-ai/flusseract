import 'dart:ffi';
import 'dart:io';

import 'flusseract_bindings_generated.dart';

/// The name of the dynamic library.

const String _libName = 'flusseract';

/// The dynamic library in which the symbols for [UserBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final FlusseractBindings flusseract = FlusseractBindings(_dylib);
