import 'dart:ffi' as ffi;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

import 'package:ffi_helper_ab/ffi_helper.dart';

import 'flusseract_bindings.dart' as bindings;

class PixImage extends ForeignInstanceStub {
  int get width => bindings.flusseract.GetPixImageWidth(handle);
  int get height => bindings.flusseract.GetPixImageHeight(handle);

  static PixImage fromFile(String filePath) {
    final ffi.Pointer<ffi.Char> filePathPtr =
        filePath.toNativeUtf8().cast<ffi.Char>();

    try {
      return PixImage._(filePath: filePathPtr);
    } finally {
      calloc.free(filePathPtr);
    }
  }

  static PixImage fromBytes(Uint8List imageBytes) {
    ffi.Pointer<ffi.Uint8> imageBytesPtr =
        calloc.allocate<ffi.Uint8>(imageBytes.length);

    try {
      imageBytesPtr.asTypedList(imageBytes.length).setAll(0, imageBytes);
      return PixImage._(
        imageBytes: imageBytesPtr,
        length: imageBytes.length,
      );
    } finally {
      calloc.free(imageBytesPtr);
    }
  }

  PixImage._({
    ffi.Pointer<ffi.Char>? filePath,
    ffi.Pointer<ffi.Uint8>? imageBytes,
    int? length,
  })  : assert(
          (filePath != null && (imageBytes == null && length == null)) ||
              (filePath == null && (imageBytes != null && length != null)),
        ),
        super(
          filePath != null
              ? bindings.flusseract.CreatePixImageByFilePath(
                  filePath,
                )
              : bindings.flusseract.CreatePixImageFromBytes(
                  imageBytes!,
                  length!,
                ),
          bindings.flusseract.DestroyPixImage,
        );
}
