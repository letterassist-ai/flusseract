import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:ffi_helper_ab/ffi_helper.dart';
import 'package:logging/logging.dart' as logging;

import 'flusseract_bindings.dart' as bindings;
import 'flusseract_bindings_generated.dart' as generated;

// FFI logger interface implementation
class LibFlusseractLogger extends ForeignInterfaceSkel<generated.logger_t> {
  final logger = logging.Logger('libflusseract');

  static LibFlusseractLogger? _instance;

  static init() {
    _instance ??= LibFlusseractLogger._();
  }

  LibFlusseractLogger._() : super() {
    logger.log(logging.Level.FINE, 'LibFlusseractLogger initialized');
    bindings.flusseract.setLogger(handle);
  }

  @override
  ffi.Pointer<generated.logger_t> create() {
    ffi.Pointer<generated.logger_t> handle = calloc<generated.logger_t>();
    handle.ref.context = handle.address;
    handle.ref.log = ffi.Pointer.fromFunction(_log);
    return handle;
  }

  // Interface func skeletons for calling
  // Dart code from foreign code

  static void _log(int context, int level, ffi.Pointer<ffi.Char> s) {
    final LibFlusseractLogger libFlusseractLogger =
        ForeignInterfaceSkel.lookupInstance<LibFlusseractLogger>(
      context,
    );

    libFlusseractLogger.logger.log(
      logging.Level.LEVELS[level],
      s.cast<Utf8>().toDartString(),
    );
  }
}
