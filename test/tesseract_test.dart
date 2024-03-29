import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'package:ffi_helper_ab/ffi_helper.dart';
import 'package:flusseract/flusseract.dart';

void main() {
  test('Checks version of Tesseract library', () async {
    final version = Tesseract.version;
    expect(version, matches(RegExp(r'^5\.3\.4(-\d\d-\S+)?$')));
  });

  test('Clears persistent cache', () async {
    Tesseract.clearPersistentCache();
  });

  test('Check default data path', () async {
    final tessDataPath = Tesseract.defaultTessDataPath;
    expect(tessDataPath, matches(RegExp(r'(/usr/local/share/tessdata/)|(./)')));
  });

  test('Creates PixImage from file', () async {
    final imagePNG = PixImage.fromFile(
      'test/data/images/test-image.png',
    );
    expect(imagePNG.width, equals(1024));
    expect(imagePNG.height, equals(576));
    imagePNG.dispose();

    final imageTIFF = PixImage.fromFile(
      'test/data/images/test-business-letter.tiff',
    );
    expect(imageTIFF.width, equals(600));
    expect(imageTIFF.height, equals(730));
    imageTIFF.dispose();
  });

  test('Creates PixImage from bytes', () async {
    final file = File(
      'test/data/images/test-hand-written-image.png',
    );
    final image = PixImage.fromBytes(file.readAsBytesSync());
    expect(image.width, equals(1896));
    expect(image.height, equals(2528));
    image.dispose();
  });

  test('Attempts to create a PixImage from invalid file', () async {
    expect(
      () => PixImage.fromFile(
        'test/data/images/invalid-image.png',
      ),
      throwsA(isA<InstanceCreateError>()),
    );
  });

  test('Extracts text from an image using default settings', () async {
    PixImage? image;
    Tesseract? tesseract;

    try {
      image = PixImage.fromFile(
        'test/data/images/test-helloworld.png',
      );
      tesseract = Tesseract(
        tessDataPath: '${Directory.current.path}/test/data/tessdata/',
      );
      final textUTF8 = await tesseract.utf8Text(image);
      expect(textUTF8.trim(), contains('Hello, World!'));
      final textHOCR = await tesseract.hocrText(image);
      expect(
        textHOCR,
        equals(
          """
  <div class='ocr_page' id='page_1' title='image "unknown"; bbox 0 0 1174 236; ppageno 0; scan_res 144 144'>
   <div class='ocr_carea' id='block_1_1' title="bbox 74 64 1099 190">
    <p class='ocr_par' id='par_1_1' lang='eng' title="bbox 74 64 1099 190">
     <span class='ocr_line' id='line_1_1' title="bbox 74 64 1099 190; baseline 0 -22; x_size 126; x_descenders 21; x_ascenders 27">
      <span class='ocrx_word' id='word_1_1' title='bbox 74 64 524 190; x_wconf 88'>Hello,</span>
      <span class='ocrx_word' id='word_1_2' title='bbox 638 64 1099 170; x_wconf 91'>World!</span>
     </span>
    </p>
   </div>
  </div>
""",
        ),
      );
    } finally {
      image?.dispose();
      tesseract?.dispose();
    }
  });

  test('Extracts text from an image with a whitelisted chars', () async {
    PixImage? image;
    Tesseract? tesseract;

    try {
      image = PixImage.fromFile(
        'test/data/images/test-helloworld.png',
      );
      tesseract = Tesseract(
        tessDataPath: '${Directory.current.path}/test/data/tessdata/',
      );
      tesseract.setWhiteList('HeloWd,');
      final textUTF8 = await tesseract.utf8Text(image);
      expect(textUTF8.trim(), contains('Hello,Wold'));
    } finally {
      image?.dispose();
      tesseract?.dispose();
    }
  });

  test('Extracts text from an image with a blacklisted chars', () async {
    PixImage? image;
    Tesseract? tesseract;

    try {
      image = PixImage.fromFile(
        'test/data/images/test-helloworld.png',
      );
      tesseract = Tesseract(
        tessDataPath: '${Directory.current.path}/test/data/tessdata/',
      );
      tesseract.setBlackList('l');
      final textUTF8 = await tesseract.utf8Text(image);
      expect(textUTF8.trim(), contains('Heo, Word!'));
    } finally {
      image?.dispose();
      tesseract?.dispose();
    }
  });

  test('Extracts french text from an image', () async {
    PixImage? image;
    Tesseract? tesseract;

    try {
      image = PixImage.fromFile(
        'test/data/images/test-french-text.png',
      );
      tesseract = Tesseract(
        languages: ['fra'],
        tessDataPath: '${Directory.current.path}/test/data/tessdata/',
      );
      final textUTF8 = await tesseract.utf8Text(image);
      expect(
        textUTF8.trim(),
        equals(
          """des systèmes d'état-cvil et de l'ambigüité et des contradictions des codes de
nationalité. Sur la base d'une étude qu'elle préconise pour les prochains mois,
cette Inititive de N'Djaména entend développer une poltique commune pour
une prévention conséquente et une réelle éradication du phénomène, tant ses
enjeux sont cruciaux pourle développement et la stabilté. Car lapatridie n'est
pas seulement une dénégation des droits humains ; elle constitue aussi une
incompatibiité avec les valeurs de gouvemance et compromet de ce fait la
stabilité.
La Commission de la CEMAC s'engage en conséquence, avant octobre 2019,
à obtenir de ses États membres la désignation des points focaux apatridie,
porte d'entrée pour la réalisation de la feulle de route tracée par l'Initiative de
N'Djaména.
Vive les initatives de protection des droits de la personne !
Vive les projets destinés à garantir la dimension humaine du développement !
Je vous remercie.

3""",
        ),
      );
    } finally {
      image?.dispose();
      tesseract?.dispose();
    }
  });

  test('Retrieves the bounding boxes of an extracted image', () async {
    PixImage? image;
    Tesseract? tesseract;

    try {
      image = PixImage.fromFile(
        'test/data/images/test-helloworld.png',
      );
      tesseract = Tesseract(
        tessDataPath: '${Directory.current.path}/test/data/tessdata/',
      );
      final textUTF8 = await tesseract.utf8Text(image);
      expect(textUTF8.trim(), contains('Hello, World!'));

      final boxes = tesseract.getBoundingBoxes(PageIteratorLevel.word);
      expect(boxes.length, equals(2));
      expect(
        boxes[0].toString(),
        'BoundingBox(x1: 74, y1: 64, x2: 524, y2: 190, '
        'word: "Hello,", confidence: 88.32%)',
      );
      expect(
        boxes[1].toString(),
        'BoundingBox(x1: 638, y1: 64, x2: 1099, y2: 170, '
        'word: "World!", confidence: 91.28%)',
      );
    } finally {
      image?.dispose();
      tesseract?.dispose();
    }
  });
}
