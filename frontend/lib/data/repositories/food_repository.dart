import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/core/ml/yolo_detector.dart';
import 'package:nutriview/data/api_client.dart';
import 'package:nutriview/data/models/food.dart';

class FoodRepository {
  final FirebaseFirestore? _customFirestore;
  final YoloDetector _detector;

  List<Map<String, dynamic>>? _cachedSeedFoods;

  FoodRepository([
    ApiClient? apiClient,
    FirebaseFirestore? firestore,
    YoloDetector? detector,
  ]) : _customFirestore = firestore,
       _detector = detector ?? YoloDetector();

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    if (Firebase.apps.isNotEmpty) return FirebaseFirestore.instance;
    return null;
  }

  Future<List<Map<String, dynamic>>> _loadSeedFoods() async {
    if (_cachedSeedFoods != null && _cachedSeedFoods!.isNotEmpty) {
      return _cachedSeedFoods!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/seed_foods.json',
      );
      final list = jsonDecode(jsonString) as List<dynamic>;
      _cachedSeedFoods = list
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      return _cachedSeedFoods!;
    } catch (_) {
      // Fallback for tests or direct filesystem environments
      final candidateFiles = [
        File('assets/data/seed_foods.json'),
        File('frontend/assets/data/seed_foods.json'),
      ];
      for (final file in candidateFiles) {
        if (file.existsSync()) {
          final content = file.readAsStringSync();
          final list = jsonDecode(content) as List<dynamic>;
          _cachedSeedFoods = list
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
          return _cachedSeedFoods!;
        }
      }
    }
    return [];
  }

  List<Map<String, dynamic>>? _cachedAllFoods;
  DateTime? _foodsCacheTime;
  static const Duration _foodsCacheTtl = Duration(minutes: 10);

  void invalidateCache() {
    _cachedAllFoods = null;
    _foodsCacheTime = null;
    _cachedSeedFoods = null;
  }

  Future<List<Map<String, dynamic>>> _getAllFoods({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _cachedAllFoods != null &&
        _cachedAllFoods!.isNotEmpty &&
        _foodsCacheTime != null &&
        DateTime.now().difference(_foodsCacheTime!) < _foodsCacheTtl) {
      return _cachedAllFoods!;
    }

    final db = _firestore;
    if (db != null) {
      try {
        final snapshot = await db.collection('foods').get();
        if (snapshot.docs.isNotEmpty) {
          _cachedAllFoods = snapshot.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            if (!data.containsKey('id')) {
              data['id'] = int.tryParse(doc.id) ?? doc.id.hashCode.abs();
            }
            return data;
          }).toList();
          _foodsCacheTime = DateTime.now();
          return _cachedAllFoods!;
        }
      } catch (_) {
        // Fallback to local seeds if Firestore is unavailable
      }
    }
    final seeds = await _loadSeedFoods();
    _cachedAllFoods = seeds;
    _foodsCacheTime = DateTime.now();
    return seeds;
  }

  Future<List<FoodItem>> searchFoods({
    String? query,
    int page = 1,
    int pageSize = 20,
  }) async {
    final allFoods = await _getAllFoods();
    var filtered = allFoods.where((f) => f['is_active'] == true).toList();

    if (query != null && query.trim().isNotEmpty) {
      final cleanQuery = query.trim().toLowerCase();
      filtered = filtered.where((f) {
        final name = (f['name'] as String? ?? '').toLowerCase();
        final yoloClass = (f['yolo_class'] as String? ?? '').toLowerCase();
        return name.contains(cleanQuery) || yoloClass.contains(cleanQuery);
      }).toList();
    }

    final startIndex = (page - 1) * pageSize;
    if (startIndex >= filtered.length) {
      return [];
    }
    final paginated = filtered.skip(startIndex).take(pageSize).toList();

    return paginated.map((json) => FoodItem.fromJson(json)).toList();
  }

  Future<FoodDetail> getFoodDetail(int id) async {
    final allFoods = await _getAllFoods();
    final item = allFoods.cast<Map<String, dynamic>?>().firstWhere(
      (f) => f?['id'] == id,
      orElse: () => null,
    );

    if (item == null) {
      throw ApiException(
        statusCode: 404,
        code: 'FOOD_NOT_FOUND',
        message: 'Makanan dengan ID $id tidak ditemukan.',
      );
    }

    return FoodDetail.fromJson(item);
  }

  Future<List<DetectionItem>> detectFood(File imageFile) async {
    if (!_detector.isAvailable) {
      await _detector.initialize();
    }

    final rawDetections = await _detector.detect(imageFile);
    final allFoods = await _getAllFoods();

    final List<DetectionItem> result = [];

    for (final raw in rawDetections) {
      final normalizedRawClass = raw.className.trim().toLowerCase();

      final matchedFood = allFoods.cast<Map<String, dynamic>?>().firstWhere(
        (f) =>
            (f?['yolo_class'] as String?)?.trim().toLowerCase() ==
                normalizedRawClass ||
            (f?['name'] as String?)?.trim().toLowerCase() == normalizedRawClass,
        orElse: () => null,
      );

      String status = 'mapped';
      String? errorMessage;
      int? foodId;
      String? foodName;
      double? calories;
      double? protein;
      double? carbs;
      double? fat;
      bool hasNutrition = false;

      if (matchedFood != null) {
        foodId = (matchedFood['id'] as num?)?.toInt();
        foodName = matchedFood['name'] as String?;
        final isActive = matchedFood['is_active'] as bool? ?? true;
        hasNutrition =
            matchedFood['has_nutrition_data'] as bool? ??
            (matchedFood['calories_kcal_per_100g'] != null);

        if (!isActive) {
          status = 'food_unavailable';
          errorMessage =
              "Makanan '$foodName' sedang dinonaktifkan oleh administrator.";
        } else if (!hasNutrition) {
          status = 'nutrition_unavailable';
          errorMessage =
              "Informasi nilai gizi untuk '$foodName' belum tersedia.";
        } else {
          status = 'mapped';
          calories = (matchedFood['calories_kcal_per_100g'] as num?)
              ?.toDouble();
          protein = (matchedFood['protein_g_per_100g'] as num?)?.toDouble();
          carbs = (matchedFood['carbs_g_per_100g'] as num?)?.toDouble();
          fat = (matchedFood['fat_g_per_100g'] as num?)?.toDouble();
        }
      } else {
        status = 'unmapped';
        errorMessage =
            "Class '${raw.className}' tidak terdaftar di database makanan.";
      }

      result.add(
        DetectionItem(
          foodId: foodId,
          foodName: foodName,
          yoloClass: raw.className,
          confidence: double.parse(raw.confidence.toStringAsFixed(4)),
          lowConfidence: raw.confidence < 0.30,
          classId: raw.classId,
          className: raw.className,
          boundingBox: raw.boundingBox,
          status: status,
          error: errorMessage,
          caloriesPer100g: calories,
          proteinPer100g: protein,
          carbsPer100g: carbs,
          fatPer100g: fat,
          hasNutritionData: hasNutrition && status == 'mapped',
        ),
      );
    }

    // Sort descending by confidence
    result.sort((a, b) => b.confidence.compareTo(a.confidence));
    return result;
  }
}
