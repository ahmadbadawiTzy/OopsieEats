import 'dart:typed_data';

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

  bool get isAvailable => false;
  List<String> get labels => defaultClasses;

  Future<void> initialize({
    String modelAssetPath = 'assets/models/best.tflite',
    String labelsAssetPath = 'assets/models/classes.txt',
    int? numThreads,
  }) async {}

  Future<List<RawDetection>> detect(
    dynamic imageFile, {
    double confidenceThreshold = 0.15,
    double iouThreshold = 0.45,
  }) async {
    return [];
  }

  Future<List<RawDetection>> detectFromBytes(
    Uint8List imageBytes, {
    double confidenceThreshold = 0.15,
    double iouThreshold = 0.45,
  }) async {
    return [];
  }

  void close() {}
}
