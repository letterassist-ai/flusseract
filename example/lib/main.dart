import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'package:flusseract/flusseract.dart' as flusseract;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    final message = '${record.loggerName}.${record.message}';
    if (kDebugMode) {
      if (record.error != null) {
        print(
          '${record.level.name}: ${record.time}: $message =>'
          'error: ${record.error}; stackTrace: ${record.stackTrace}',
        );
      } else {
        print('${record.level.name}: ${record.time}: $message');
      }
    } else {
      developer.log(
        message,
        time: record.time,
        sequenceNumber: record.sequenceNumber,
        level: record.level.value,
        name: record.loggerName,
        zone: record.zone,
        error: record.error,
        stackTrace: record.stackTrace,
      );
    }
  });
  flusseract.LibFlusseractLogger.init();

  flusseract.TessData.init().then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String tessVersion;

  String? _ocrText;

  @override
  void initState() {
    super.initState();
    tessVersion = flusseract.Tesseract.version;

    rootBundle.load('assets/test-helloworld.png').then(
      (imageData) async {
        final image = flusseract.PixImage.fromBytes(
          imageData.buffer.asUint8List(),
        );
        final tesseract = flusseract.Tesseract(
          tessDataPath: flusseract.TessData.tessDataPath,
        );
        final ocrText = await tesseract.utf8Text(image);

        setState(() {
          _ocrText = ocrText;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const spacerLarge = SizedBox(height: 20);
    const spacerSmall = SizedBox(height: 10);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flusseract OCR Plugin Test App'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  spacerLarge,
                  const Divider(),
                  spacerSmall,
                  Text(
                    'Tesseract Version = $tessVersion',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  spacerSmall,
                  const Divider(),
                  spacerSmall,
                  Text(
                    'Image to OCR',
                    style: theme.textTheme.bodyLarge,
                  ),
                  spacerSmall,
                  Center(
                    child: Image.asset(
                      'assets/test-helloworld.png',
                      width: 200,
                    ),
                  ),
                  spacerSmall,
                  const Divider(),
                  spacerSmall,
                  Text(
                    'OCR Text',
                    style: theme.textTheme.bodyLarge,
                  ),
                  spacerSmall,
                  if (_ocrText == null)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    )
                  else
                    Text(
                      _ocrText!,
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  spacerSmall,
                  const Divider(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
