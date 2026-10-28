import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:nutriview/data/models/food.dart';

class RawDetection {
  final int classId;
  final String className;
  final double confidence;
  final BoundingBox boundingBox;

  const RawDetection({
    required this.classId,
    required this.className,
    required this.confidence,
    required this.boundingBox,
  });

  Map<String, dynamic> toJson() => {
    'class_id': classId,
    'class_name': className,
    'confidence': confidence,
    'bbox': boundingBox.toJson(),
    'bounding_box': boundingBox.toJson(),
  };
}

class _PreprocessedData {
  final int origW;
  final int origH;
  final List<List<List<Float32List>>> input;

  const _PreprocessedData(this.origW, this.origH, this.input);
}

/// Standalone top-level function executed inside background isolate
_PreprocessedData _preprocessImage(Uint8List imageBytes) {
  img.Image? decoded = img.decodeImage(imageBytes);
  if (decoded == null) {
    throw const FormatException('Gambar tidak valid atau rusak.');
  }

  // Handle EXIF orientation
  decoded = img.bakeOrientation(decoded);
  final origW = decoded.width;
  final origH = decoded.height;

  // Resize to 640x640
  final resized = img.copyResize(
    decoded,
    width: YoloDetector.inputSize,
    height: YoloDetector.inputSize,
    interpolation: img.Interpolation.linear,
  );

  // Prepare input tensor: [1, 3, 640, 640] float32
  final input = List.generate(
    1,
    (_) => List.generate(
      3,
      (_) => List.generate(
        YoloDetector.inputSize,
        (_) => Float32List(YoloDetector.inputSize),
      ),
    ),
  );

  for (int y = 0; y < YoloDetector.inputSize; y++) {
    for (int x = 0; x < YoloDetector.inputSize; x++) {
      final pixel = resized.getPixel(x, y);
      // Channels first: 0=R, 1=G, 2=B, normalized 0.0 to 1.0
      input[0][0][y][x] = pixel.r / 255.0;
      input[0][1][y][x] = pixel.g / 255.0;
      input[0][2][y][x] = pixel.b / 255.0;
    }
  }

  return _PreprocessedData(origW, origH, input);
}

class YoloDetector {
  static const int inputSize = 640;
  static const int numAnchors = 8400;
  static const int numClasses = 29;

  static const List<String> defaultClasses = [
    'Apple',
    'Ayam Goreng',
    'Bakso',
    'Banana',
    'Burger',
    'Capcay',
    'Chocolate Chip Cookie',
    'Donat',
    'Ikan Goreng',
    'Kentang Goreng',
    'Kiwi',
    'Mie Goreng',
    'Nasi Goreng',
    'Nasi Putih',
    'Nugget',
    'Pempek',
    'Pineapples',
    'Pizza',
    'Rendang Sapi',
    'Sate',
    'Spaghetti',
    'Steak',
    'Strawberry',
    'Tahu Goreng',
    'Telur Goreng',
    'Telur Rebus',
    'Tempe Goreng',
    'Terong Balado',
    'Tumis Kangkung',
  ];

  Interpreter? _interpreter;
  List<String> _labels = defaultClasses;
  bool _isInitialized = false;

  bool get isAvailable => _isInitialized && _interpreter != null;
  List<String> get labels => _labels;

  Future<void> initialize({
    String modelAssetPath = 'assets/models/best.tflite',
    String labelsAssetPath = 'assets/models/classes.txt',
    int? numThreads,
  }) async {
    if (_isInitialized && _interpreter != null) return;

    final threads = numThreads ?? (Platform.numberOfProcessors >= 4 ? 4 : 2);

    try {
      // 1. Load labels
      try {
        final labelsContent = await rootBundle.loadString(labelsAssetPath);
        final parsed = labelsContent
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        if (parsed.length == numClasses) {
          _labels = parsed;
        }
      } catch (_) {
        // Fallback to local file in test/headless environments
        final localFile = File(labelsAssetPath);
        if (localFile.existsSync()) {
          final lines = localFile
              .readAsLinesSync()
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
          if (lines.length == numClasses) {
            _labels = lines;
          }
        }
      }

      // 2. Load Interpreter
      final options = InterpreterOptions()..threads = threads;
      try {
        _interpreter = await Interpreter.fromAsset(
          modelAssetPath,
          options: options,
        );
      } catch (assetError) {
        // Fallback for tests or local paths
        final candidateFiles = [
          File(modelAssetPath),
          File('frontend/$modelAssetPath'),
          File('assets/models/best.tflite'),
          File('frontend/assets/models/best.tflite'),
        ];
        for (final candidate in candidateFiles) {
          if (candidate.existsSync()) {
            _interpreter = Interpreter.fromFile(candidate, options: options);
            break;
          }
        }
        if (_interpreter == null) {
          rethrow;
        }
      }

      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      _interpreter = null;
      rethrow;
    }
  }

  Future<List<RawDetection>> detect(
    File imageFile, {
    double confidenceThreshold = 0.15,
    double iouThreshold = 0.45,
  }) async {
    if (!_isInitialized || _interpreter == null) {
      await initialize();
    }

    final bytes = await imageFile.readAsBytes();
    return detectFromBytes(
      bytes,
      confidenceThreshold: confidenceThreshold,
      iouThreshold: iouThreshold,
    );
  }

  Future<List<RawDetection>> detectFromBytes(
    Uint8List imageBytes, {
    double confidenceThreshold = 0.15,
    double iouThreshold = 0.45,
  }) async {
    if (_interpreter == null) {
      throw StateError('YOLO interpreter is not initialized.');
    }

    // Heavy preprocessing (image decode, orientation baking, resize, tensor generation)
    // runs in a dedicated background isolate so UI thread remains silky smooth (60/120 fps)
    final preprocessed = await Isolate.run(() => _preprocessImage(imageBytes));
    final origW = preprocessed.origW;
    final origH = preprocessed.origH;
    final input = preprocessed.input;

    // Prepare output tensor: [1, 33, 8400] float32
    // 33 = 4 (cx, cy, w, h) + 29 class scores
    final output = List.generate(
      1,
      (_) => List.generate(
        4 + numClasses,
        (_) => List<double>.filled(numAnchors, 0.0),
      ),
    );

    _interpreter!.run(input, output);

    // Optimized parsing: Hoist channel arrays to eliminate 730,000 bounds checks
    final List<List<double>> outputChannels = output[0];
    final List<double> cxList = outputChannels[0];
    final List<double> cyList = outputChannels[1];
    final List<double> wList = outputChannels[2];
    final List<double> hList = outputChannels[3];

    final List<List<double>> classScoreLists = List<List<double>>.generate(
      numClasses,
      (c) => outputChannels[4 + c],
      growable: false,
    );

    final List<_CandidateBox> candidates = [];

    for (int i = 0; i < numAnchors; i++) {
      // Find maximum class score
      double maxScore = -1.0;
      int bestClassId = -1;

      for (int c = 0; c < numClasses; c++) {
        final score = classScoreLists[c][i];
        if (score > maxScore) {
          maxScore = score;
          bestClassId = c;
        }
      }

      if (maxScore >= confidenceThreshold && bestClassId >= 0) {
        final cx = cxList[i];
        final cy = cyList[i];
        final w = wList[i];
        final h = hList[i];

        // Normalized coords to original image pixels
        final x1 = ((cx - (w / 2.0)) * origW).clamp(0.0, origW.toDouble());
        final y1 = ((cy - (h / 2.0)) * origH).clamp(0.0, origH.toDouble());
        final x2 = ((cx + (w / 2.0)) * origW).clamp(0.0, origW.toDouble());
        final y2 = ((cy + (h / 2.0)) * origH).clamp(0.0, origH.toDouble());

        final className = bestClassId < _labels.length
            ? _labels[bestClassId]
            : 'Class_$bestClassId';

        candidates.add(
          _CandidateBox(
            classId: bestClassId,
            className: className,
            confidence: maxScore,
            x1: x1.toInt(),
            y1: y1.toInt(),
            x2: x2.toInt(),
            y2: y2.toInt(),
          ),
        );
      }
    }

    // Apply Non-Maximum Suppression (NMS)
    final suppressed = _nonMaximumSuppression(candidates, iouThreshold);

    return suppressed.map((c) {
      return RawDetection(
        classId: c.classId,
        className: c.className,
        confidence: double.parse(c.confidence.toStringAsFixed(4)),
        boundingBox: BoundingBox(x1: c.x1, y1: c.y1, x2: c.x2, y2: c.y2),
      );
    }).toList();
  }

  List<_CandidateBox> _nonMaximumSuppression(
    List<_CandidateBox> boxes,
    double iouThreshold,
  ) {
    if (boxes.isEmpty) return [];

    // Sort descending by confidence
    boxes.sort((a, b) => b.confidence.compareTo(a.confidence));

    final List<_CandidateBox> selected = [];

    for (final box in boxes) {
      bool keep = true;
      for (final prev in selected) {
        if (prev.classId == box.classId) {
          final iou = _calculateIoU(box, prev);
          if (iou > iouThreshold) {
            keep = false;
            break;
          }
        }
      }
      if (keep) {
        selected.add(box);
      }
    }

    return selected;
  }

  double _calculateIoU(_CandidateBox a, _CandidateBox b) {
    final x1 = max(a.x1, b.x1);
    final y1 = max(a.y1, b.y1);
    final x2 = min(a.x2, b.x2);
    final y2 = min(a.y2, b.y2);

    final intersectionArea = max(0, x2 - x1) * max(0, y2 - y1);
    final areaA = (a.x2 - a.x1) * (a.y2 - a.y1);
    final areaB = (b.x2 - b.x1) * (b.y2 - b.y1);
    final unionArea = areaA + areaB - intersectionArea;

    if (unionArea <= 0) return 0.0;
    return intersectionArea / unionArea;
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}

class _CandidateBox {
  final int classId;
  final String className;
  final double confidence;
  final int x1;
  final int y1;
  final int x2;
  final int y2;

  const _CandidateBox({
    required this.classId,
    required this.className,
    required this.confidence,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });
}
