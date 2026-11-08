import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oopsieeats/core/error_handler.dart';
import 'package:oopsieeats/data/models/food.dart';
import 'package:oopsieeats/data/models/meal.dart';
import 'package:oopsieeats/data/repositories/food_repository.dart';
import 'package:oopsieeats/data/repositories/meal_repository.dart';
import 'package:oopsieeats/data/services/supabase_storage_service.dart';

class ConfirmedFoodItem {
  int? foodId;
  String foodName;
  double? portionGrams;
  String source; // 'detected', 'corrected', 'manual'
  double? detectionConfidence;
  bool lowConfidence;
  BoundingBox? boundingBox;
  String
  status; // 'mapped', 'unmapped', 'food_unavailable', 'nutrition_unavailable'
  String? error;

  // Real nutritional metrics per 100g
  double? caloriesPer100g;
  double? proteinPer100g;
  double? carbsPer100g;
  double? fatPer100g;
  bool hasNutritionData;

  ConfirmedFoodItem({
    this.foodId,
    required this.foodName,
    this.portionGrams,
    required this.source,
    this.detectionConfidence,
    this.lowConfidence = false,
    this.boundingBox,
    this.status = 'mapped',
    this.error,
    this.caloriesPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatPer100g,
    this.hasNutritionData = true,
  });

  bool get isUnmapped => foodId == null || status == 'unmapped';

  /// Estimates calories dynamically based on [portionGrams].
  double get estimatedCalories {
    final grams = portionGrams ?? 0.0;
    return ((caloriesPer100g ?? 0.0) * grams) / 100.0;
  }

  /// Estimates protein dynamically based on [portionGrams].
  double get estimatedProtein {
    final grams = portionGrams ?? 0.0;
    return ((proteinPer100g ?? 0.0) * grams) / 100.0;
  }

  /// Estimates carbs dynamically based on [portionGrams].
  double get estimatedCarbs {
    final grams = portionGrams ?? 0.0;
    return ((carbsPer100g ?? 0.0) * grams) / 100.0;
  }

  /// Estimates fat dynamically based on [portionGrams].
  double get estimatedFat {
    final grams = portionGrams ?? 0.0;
    return ((fatPer100g ?? 0.0) * grams) / 100.0;
  }
}

class ScanFlowProvider extends ChangeNotifier {
  final FoodRepository foodRepository;
  final MealRepository mealRepository;
  final SupabaseStorageService? storageService;
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  Uint8List? _imageBytes;
  bool _isProcessing = false;
  String? _errorMessage;
  List<ConfirmedFoodItem> _confirmedItems = [];
  List<DetectionItem> _rawDetections = [];
  String _mealType = 'lunch';
  MealRecord? _savedMealRecord;

  ScanFlowProvider({
    required this.foodRepository,
    required this.mealRepository,
    this.storageService,
  }) {
    _suggestDefaultMealType();
  }

  File? get imageFile => _imageFile;
  Uint8List? get imageBytes => _imageBytes;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  List<ConfirmedFoodItem> get confirmedItems => _confirmedItems;
  List<DetectionItem> get rawDetections => _rawDetections;
  String get mealType => _mealType;
  MealRecord? get savedMealRecord => _savedMealRecord;

  double get totalEstimatedCalories =>
      _confirmedItems.fold(0.0, (acc, item) => acc + item.estimatedCalories);

  double get totalEstimatedProtein =>
      _confirmedItems.fold(0.0, (acc, item) => acc + item.estimatedProtein);

  double get totalEstimatedCarbs =>
      _confirmedItems.fold(0.0, (acc, item) => acc + item.estimatedCarbs);

  double get totalEstimatedFat =>
      _confirmedItems.fold(0.0, (acc, item) => acc + item.estimatedFat);

  void _suggestDefaultMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      _mealType = 'breakfast';
    } else if (hour >= 11 && hour < 16) {
      _mealType = 'lunch';
    } else if (hour >= 16 && hour < 21) {
      _mealType = 'dinner';
    } else {
      _mealType = 'snack';
    }
  }

  void setMealType(String type) {
    _mealType = type;
    notifyListeners();
  }

  Future<bool> pickAndScanImage(ImageSource source) async {
    _errorMessage = null;
    try {
      XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );

      if (picked == null &&
          !kIsWeb &&
          defaultTargetPlatform == TargetPlatform.android) {
        final LostDataResponse lostData = await _picker.retrieveLostData();
        if (!lostData.isEmpty && lostData.file != null) {
          picked = lostData.file;
        }
      }

      if (picked == null) return false;

      final bytes = await picked.readAsBytes();
      _imageBytes = bytes;
      if (!kIsWeb) {
        _imageFile = File(picked.path);
      }
      _isProcessing = true;
      _confirmedItems = [];
      _rawDetections = [];
      notifyListeners();

      final detections = await foodRepository.detectFood(
        kIsWeb ? bytes : (_imageFile ?? bytes),
      );
      _rawDetections = detections;
      _confirmedItems = detections.map((d) {
        return ConfirmedFoodItem(
          foodId: d.foodId,
          foodName: d.displayName,
          portionGrams: 0.0,
          source: 'detected',
          detectionConfidence: d.confidence,
          lowConfidence: d.lowConfidence,
          boundingBox: d.boundingBox,
          status: d.status,
          error: d.error,
          caloriesPer100g: d.caloriesPer100g,
          proteinPer100g: d.proteinPer100g,
          carbsPer100g: d.carbsPer100g,
          fatPer100g: d.fatPer100g,
          hasNutritionData: d.hasNutritionData,
        );
      }).toList();

      return true;
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied') {
        _errorMessage = 'Akses kamera ditolak. Silakan izinkan akses kamera pada Pengaturan perangkat untuk memindai makanan.';
      } else {
        _errorMessage = 'Gagal mengakses kamera atau galeri: ${e.message}';
      }
      return false;
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal memproses gambar makanan. Silakan coba lagi.';
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _confirmedItems.length) {
      _confirmedItems.removeAt(index);
      notifyListeners();
    }
  }

  void replaceItem(int index, FoodItem newFood) {
    if (index >= 0 && index < _confirmedItems.length) {
      final old = _confirmedItems[index];
      _confirmedItems[index] = ConfirmedFoodItem(
        foodId: newFood.id,
        foodName: newFood.name,
        portionGrams: old.portionGrams,
        source: 'corrected',
        detectionConfidence: old.detectionConfidence,
        lowConfidence: false,
        boundingBox: old.boundingBox,
        status: 'mapped',
        error: null,
        caloriesPer100g: newFood.caloriesKcalPer100g,
        proteinPer100g: newFood.proteinGPer100g,
        carbsPer100g: newFood.carbsGPer100g,
        fatPer100g: newFood.fatGPer100g,
        hasNutritionData: newFood.hasNutritionData,
      );
      notifyListeners();
    }
  }

  void addManualItem(FoodItem newFood) {
    _confirmedItems.add(
      ConfirmedFoodItem(
        foodId: newFood.id,
        foodName: newFood.name,
        portionGrams: 0.0,
        source: 'manual',
        detectionConfidence: null,
        lowConfidence: false,
        status: 'mapped',
        caloriesPer100g: newFood.caloriesKcalPer100g,
        proteinPer100g: newFood.proteinGPer100g,
        carbsPer100g: newFood.carbsGPer100g,
        fatPer100g: newFood.fatGPer100g,
        hasNutritionData: newFood.hasNutritionData,
      ),
    );
    notifyListeners();
  }

  void updatePortion(int index, double grams) {
    if (index >= 0 && index < _confirmedItems.length) {
      _confirmedItems[index].portionGrams = grams;
      notifyListeners();
    }
  }

  bool validatePortions() {
    if (_confirmedItems.isEmpty) return false;
    for (final item in _confirmedItems) {
      if (item.foodId == null) return false;
      if (item.portionGrams == null ||
          item.portionGrams! <= 0 ||
          item.portionGrams! > 5000) {
        return false;
      }
    }
    return true;
  }

  Future<bool> submitMeal() async {
    if (_confirmedItems.any((i) => i.foodId == null)) {
      _errorMessage = 'Harap pilih atau ganti makanan yang belum terdaftar di database sebelum menyimpan.';
      notifyListeners();
      return false;
    }

    if (!validatePortions()) {
      _errorMessage =
          'Semua porsi makanan harus diisi antara 1 hingga 5000 gram.';
      notifyListeners();
      return false;
    }

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    MealImageMetadata? uploadedMetadata;
    try {
      final now = DateTime.now();
      final mealId = now.millisecondsSinceEpoch;

      // Recover image bytes from file if lost in low-memory conditions
      if (_imageBytes == null && _imageFile != null) {
        try {
          if (await _imageFile!.exists()) {
            _imageBytes = await _imageFile!.readAsBytes();
          }
        } catch (e) {
          debugPrint(
            'ScanFlowProvider: error reloading image bytes from file: $e',
          );
        }
      }

      // 1. Resilient image upload to Supabase Storage if image bytes exist
      if (_imageBytes != null && storageService != null) {
        String? uid;
        try {
          uid = fb.FirebaseAuth.instance.currentUser?.uid;
        } catch (_) {
          uid = null;
        }

        if (uid == null || uid.isEmpty) {
          try {
            uid = await mealRepository.getCurrentUserId();
          } catch (_) {
            uid = null;
          }
        }

        if (uid == null || uid.isEmpty) {
          _errorMessage = 'Sesi pengguna tidak valid. Silakan login kembali.';
          _isProcessing = false;
          notifyListeners();
          return false;
        }

        try {
          uploadedMetadata = await storageService!.uploadFoodImage(
            userId: uid,
            mealId: mealId,
            imageBytes: _imageBytes!,
          );
        } catch (storageErr) {
          debugPrint('SupabaseStorage upload failure: $storageErr');
          _errorMessage = 'Gagal mengunggah foto makanan ke penyimpanan cloud. Periksa koneksi internet Anda dan coba lagi.';
          _isProcessing = false;
          notifyListeners();
          return false;
        }
      }

      final itemsPayload = _confirmedItems.map((item) {
        final map = <String, dynamic>{
          'food_id': item.foodId,
          'portion_grams': item.portionGrams,
          'source': item.source,
        };
        if (item.source != 'manual' && item.detectionConfidence != null) {
          map['detection_confidence'] = item.detectionConfidence;
        }
        return map;
      }).toList();

      try {
        _savedMealRecord = await mealRepository.createMeal(
          mealType: _mealType,
          consumedAt: now,
          items: itemsPayload,
          imageMetadata: uploadedMetadata,
          customMealId: mealId,
        );
        return true;
      } catch (repoErr) {
        // Rollback uploaded image in Supabase to avoid orphaned storage files if Firestore save fails
        if (uploadedMetadata != null && storageService != null) {
          try {
            await storageService!.deleteFoodImage(uploadedMetadata.path);
          } catch (deleteErr) {
            debugPrint('Failed to rollback orphaned image: $deleteErr');
          }
        }
        rethrow;
      }
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal menyimpan catatan makan ke server.';
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void reset() {
    _imageFile = null;
    _imageBytes = null;
    _isProcessing = false;
    _errorMessage = null;
    _confirmedItems = [];
    _rawDetections = [];
    _savedMealRecord = null;
    _suggestDefaultMealType();
    notifyListeners();
  }

  @visibleForTesting
  void setImageBytesForTesting(Uint8List? bytes) {
    _imageBytes = bytes;
  }

  @visibleForTesting
  void setImageFileForTesting(File? file) {
    _imageFile = file;
  }
}
