import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Class that manages tesseract configuration and
/// data assets within the device sandbox.
class TessData {
  static final Completer<bool> _intialized = Completer<bool>();
  static Future<void> get initialized => _intialized.future;

  static String? _tessConfigPath;
  static get tessConfigPath => _tessConfigPath;

  static String? _tessDataPath;
  static get tessDataPath => _tessDataPath;

  /// Initializes the tessdata directory path.
  static Future<void> init({
    AssetBundle? assetBundle,
    String? tessDataAssetPath,
    String? tessConfigAssetPath,
  }) {
    assetBundle ??= rootBundle;

    () async {
      final appDataPath = (await getApplicationDocumentsDirectory()).path;
      _tessDataPath = '$appDataPath/tessdata';

      await Directory(tessDataPath).create(recursive: true);

      final assetManifest = jsonDecode(
        await assetBundle!.loadString('AssetManifest.json'),
      );

      final tessConfig = assetManifest.keys.firstWhere(
        (String key) => key.toLowerCase().startsWith('assets/tessconfig'),
      );
      if (tessConfig != null) {
        final tessConfigBytes = await assetBundle.load(tessConfig);
        final configFileName = tessConfig.split('/').last;
        final tessConfigFile = File('$_tessDataPath/$configFileName');
        await tessConfigFile.writeAsBytes(tessConfigBytes.buffer.asUint8List());
        _tessConfigPath = tessConfigFile.path;
      }

      final tessDataFiles = assetManifest.keys.where(
        (String key) => key.toLowerCase().startsWith('assets/tessdata/'),
      );
      for (final assetFile in tessDataFiles) {
        final tessDataBytes = await assetBundle.load(assetFile);
        final assetFileName = assetFile.split('/').last;
        final tessDataFile = File('$_tessDataPath/$assetFileName');
        await tessDataFile.writeAsBytes(tessDataBytes.buffer.asUint8List());
      }

      _intialized.complete(true);
    }();

    return _intialized.future;
  }
}
