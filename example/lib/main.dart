import 'package:flutter/material.dart';

import 'package:flusseract/flusseract.dart' as flusseract;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String tessVersion;

  @override
  void initState() {
    super.initState();
    tessVersion = flusseract.Tesseract.version;
    // sumAsyncResult = flusseract.sumAsync(3, 4);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  const SizedBox(height: 20),
                  Text(
                    'Tesseract Version = $tessVersion',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
