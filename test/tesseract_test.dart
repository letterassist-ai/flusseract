import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

import 'package:ffi_helper_ab/ffi_helper.dart';
import 'package:flusseract/flusseract.dart';

void main() {
  initLogging();

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

    final dataPath = '${Directory.current.path}/test/data/';

    try {
      image = PixImage.fromFile(
        'test/data/images/test-helloworld.png',
      );
      tesseract = Tesseract(
        tessDataPath: '$dataPath/tessdata/',
        configFilePath: '$dataPath/tessconfig',
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
      <span class='ocrx_word' id='word_1_1' title='bbox 74 64 524 190; x_wconf 94'>Hello,</span>
      <span class='ocrx_word' id='word_1_2' title='bbox 638 64 1099 170; x_wconf 96'>World!</span>
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
        pageSegMode: PageSegMode.singleBlock,
        tessDataPath: '${Directory.current.path}/test/data/tessdata/',
      );
      final textUTF8 = await tesseract.utf8Text(image);
      expect(
        textUTF8.trim(),
        equals(
          """des systèmes d'état-cvil et de l'ambigüité et des contradictions des codes de
nationalité. Sur la base d'une étude qu'elle préconise pour les prochains mois,
cette Initiative de N'Djaména entend développer une politique commune pour
une prévention conséquente et une réelle éradication du phénomène, tant ses
enjeux sont cruciaux pour le développement et la stabilité. Car lapatridie n'est
pas seulement une dénégation des droits humains ; elle constitue aussi une
incompatibiité avec les valeurs de gouvemance et compromet de ce fait la
stabilité.
La Commission de la CEMAC s'engage en conséquence, avant octobre 2019,
à obtenir de ses États membres la désignation des points focaux apatridie,
porte d'entrée pour la réalisation de la feuille de route tracée par l'Initiative de
N'Djaména.
Vive les initiatives de protection des droits de la personne !
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
        'word: "Hello,", confidence: 94.81%)',
      );
      expect(
        boxes[1].toString(),
        'BoundingBox(x1: 638, y1: 64, x2: 1099, y2: 170, '
        'word: "World!", confidence: 96.12%)',
      );
    } finally {
      image?.dispose();
      tesseract?.dispose();
    }
  });

  test('Extracts text from a multi-page TIFF', () async {
    Tesseract? tesseract;

    final dataPath = '${Directory.current.path}/test/data/';

    try {
      tesseract = Tesseract(
        languages: ['eng'],
        tessDataPath: '$dataPath/tessdata/fast/',
        configFilePath: '$dataPath/tessconfig',
      );
      final text = await tesseract.processDocument(
        'test/data/images/discharge-letter.tiff',
      );
      expect(
        text.trim(),
        equals(
          """Discharge Advice Letter ‘Cwm Taf Morgannwg University Heath Board
Unit 3Ynysmeurg House, Navigation

Park, Abereynon, Mountain Ash CF4S 4SN

ratient: Alfred Jenkins (Mr.) OUNCE

DOB: 25-May-1965 Sex: M Howptal Number M9909
GP details Patient details
GP Name Dr O'SULLIVAN Patient Name Alfred Jenkins (Mr)
Organisation 1D ‘was00s ‘
GP Address PONT NEWvop me centre | | Known As al
‘Aberthondda Road Date of Birth 25-May-1965
Port
Sex M
Rhondda
ca90 NHS Number 432456 3783
GP Telephone Number 01443 688880 Hospital Number 9999099
Patient Address 13 St Andrews Road
Penycoedcae
Pointypridd
cea7 De
‘Admission details Discharge details
Date of admission 27-Now-2023, Discharging consultant Dr Timathy Oye
Time of admission 10:00
Method of admission Usual place of residence
Source of admission Emergency other means
Hospital site wards

Presenting complaints) or reason for admission

The patient reports experiencing episodes of chest pain for the past [duration]. The pain is typically
described as a squeezing, pressure-ike sensation in the chest, often radiating to the left arm, neck, jaw,
fr back. The episodes are usualy triggered by physical exertion or emotional stress and relieved by rest
Cr sublingual nitroglycerin. The frequency and severity of the episodes have been progressively
Increasing over the past few weeks/months.

Diagnoses, problems
Angina

Page Lof3
Document Author System on 27-Nov-2023 at 10:19 /1
Printed By KULATILAKE, Priyantha , GPST on 29-Nov-2023,
\f‘The patient will follow up with the cardiologist in 3 months for further assessment and management.

Please could you ade these new medications to his repeat prescription

Cum Tt Morgan University Heath Board
Discharge Advice Letter Unit 3 Ynysmeurig House, Navigation
Park, Abeceyan Mountain Ah CF 44

patient: James Jones (Mr.) AE

‘Atorvastatin

Dr O'SULLIVAN Patient Name James Jones (Me)
Organisation 1D ‘was00s
GP Address PONT NEWvop me centre | | Known As James
Aberthondda Road Date of Birth (05-Jun-1970 (53y)
Port Sex M
Rhondda
3900 NHS Number 123456 7899
GPTelephone Number 01443 688880 Hospital Number 19999999
Patient Address 13 St Andrews Road
Penycoedcae
Pointypridd
cea7 De
== ae Stated
Page 2013
Document Author System on 27-Nov-2023 at 10:19 1

Printed By KULATILAKE, Priyantha , GPST on 29-Nov-2023,
\fWeight (¥@) Not Stated

Page 30f3
Document Author System on 27-Nov-2023 at 10:19 1
Printed By KULATILAKE, Priyantha , GPST on 29-Nov-2023,""",
        ),
      );
    } finally {
      tesseract?.dispose();
    }
  });
}

void initLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint(
      '${record.time} '
      '[${record.loggerName}] '
      '${record.level.name}: '
      '${record.message}',
    );
  });
  LibFlusseractLogger.init();
}
