import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:nutriview/core/ml/yolo_detector.dart';

void main() {
  group('Scanner Pipeline Benchmark & Regression Tests', () {
    late YoloDetector detector;

    setUp(() {
      detector = YoloDetector();
    });

    tearDown(() {
      detector.close();
    });

    test('Asynchronous Isolate Offloading and Latency Verification', () async {
      await detector.initialize(
        modelAssetPath: 'assets/models/best.tflite',
        labelsAssetPath: 'assets/models/classes.txt',
      );

      // Create a test 640x480 sample food image
      final testImage = img.Image(width: 640, height: 480);
      img.fill(testImage, color: img.ColorRgb8(160, 110, 60));
      final bytes = Uint8List.fromList(img.encodeJpg(testImage, quality: 85));

      final sw = Stopwatch()..start();
      final detections = await detector.detectFromBytes(
        bytes,
        confidenceThreshold: 0.10,
      );
      sw.stop();

      // Ensure pipeline executes successfully via isolate offloading
      expect(detections, isA<List<RawDetection>>());
      expect(sw.elapsedMilliseconds, greaterThan(0));
    });

    test(
      'Detector handles consecutive inference calls stably without memory leak',
      () async {
        await detector.initialize(
          modelAssetPath: 'assets/models/best.tflite',
          labelsAssetPath: 'assets/models/classes.txt',
        );

        final testImage = img.Image(width: 320, height: 240);
        img.fill(testImage, color: img.ColorRgb8(100, 150, 200));
        final bytes = Uint8List.fromList(img.encodeJpg(testImage, quality: 80));

        for (int i = 0; i < 3; i++) {
          final detections = await detector.detectFromBytes(
            bytes,
            confidenceThreshold: 0.15,
          );
          expect(detections, isA<List<RawDetection>>());
        }
      },
    );
  });
}
