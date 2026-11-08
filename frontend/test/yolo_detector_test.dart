import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:oopsieeats/core/ml/yolo_detector.dart';

void main() {
  group('YOLO Detector On-Device Tests', () {
    late YoloDetector detector;

    setUp(() {
      detector = YoloDetector();
    });

    tearDown(() {
      detector.close();
    });

    test('YoloDetector initializes and loads classes', () async {
      await detector.initialize(
        modelAssetPath: 'assets/models/best.tflite',
        labelsAssetPath: 'assets/models/classes.txt',
      );
      expect(detector.isAvailable, isTrue);
      expect(detector.labels.length, 29);
      expect(detector.labels[0], 'Apple');
      expect(detector.labels[1], 'Ayam Goreng');
      expect(detector.labels[13], 'Nasi Putih');
      expect(detector.labels[28], 'Tumis Kangkung');
    });

    test(
      'YoloDetector detects on synthetic test image without throwing',
      () async {
        await detector.initialize(
          modelAssetPath: 'assets/models/best.tflite',
          labelsAssetPath: 'assets/models/classes.txt',
        );

        // Create a test image
        final testImage = img.Image(width: 320, height: 240);
        img.fill(testImage, color: img.ColorRgb8(128, 128, 128));
        final bytes = Uint8List.fromList(img.encodeJpg(testImage));

        final detections = await detector.detectFromBytes(
          bytes,
          confidenceThreshold: 0.05,
        );

        expect(detections, isA<List<RawDetection>>());
        // All detections must have valid coordinates and confidence
        for (final det in detections) {
          expect(det.confidence, greaterThanOrEqualTo(0.05));
          expect(det.confidence, lessThanOrEqualTo(1.0));
          expect(det.classId, inInclusiveRange(0, 28));
          expect(det.className, isNotEmpty);
          expect(det.boundingBox.x1, greaterThanOrEqualTo(0));
          expect(det.boundingBox.y1, greaterThanOrEqualTo(0));
          expect(det.boundingBox.x2, lessThanOrEqualTo(320));
          expect(det.boundingBox.y2, lessThanOrEqualTo(240));
        }
      },
    );

    test('YoloDetector rejects corrupt or empty image bytes', () async {
      await detector.initialize(
        modelAssetPath: 'assets/models/best.tflite',
        labelsAssetPath: 'assets/models/classes.txt',
      );

      final corruptBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      expect(
        () => detector.detectFromBytes(corruptBytes),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
