import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/data/models/food.dart';
import 'package:nutriview/data/models/meal.dart';
import 'package:nutriview/data/repositories/food_repository.dart';
import 'package:nutriview/data/repositories/meal_repository.dart';

class ConfirmedFoodItem {
  int foodId;
  String foodName;
  double? portionGrams;
  String source; // 'detected', 'corrected', 'manual'
  double? detectionConfidence;
  bool lowConfidence;

  ConfirmedFoodItem({
    required this.foodId,
    required this.foodName,
    this.portionGrams,
    required this.source,
    this.detectionConfidence,
    this.lowConfidence = false,
  });
}

class ScanFlowProvider extends ChangeNotifier {
  final FoodRepository foodRepository;
  final MealRepository mealRepository;
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  bool _isProcessing = false;
  String? _errorMessage;
  List<ConfirmedFoodItem> _confirmedItems = [];
  String _mealType = 'lunch';
  MealRecord? _savedMealRecord;

  ScanFlowProvider({
    required this.foodRepository,
    required this.mealRepository,
  }) {
    _suggestDefaultMealType();
  }

  File? get imageFile => _imageFile;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  List<ConfirmedFoodItem> get confirmedItems => _confirmedItems;
  String get mealType => _mealType;
  MealRecord? get savedMealRecord => _savedMealRecord;

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
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );

      if (picked == null) return false;

      _imageFile = File(picked.path);
      _isProcessing = true;
      _confirmedItems = [];
      notifyListeners();

      final detections = await foodRepository.detectFood(_imageFile!);
      _confirmedItems = detections.map((d) {
        return ConfirmedFoodItem(
          foodId: d.foodId,
          foodName: d.foodName,
          source: 'detected',
          detectionConfidence: d.confidence,
          lowConfidence: d.lowConfidence,
        );
      }).toList();

      return true;
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal memproses gambar.';
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
      );
      notifyListeners();
    }
  }

  void addManualItem(FoodItem newFood) {
    _confirmedItems.add(
      ConfirmedFoodItem(
        foodId: newFood.id,
        foodName: newFood.name,
        source: 'manual',
        detectionConfidence: null,
        lowConfidence: false,
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
      if (item.portionGrams == null ||
          item.portionGrams! <= 0 ||
          item.portionGrams! > 5000) {
        return false;
      }
    }
    return true;
  }

  Future<bool> submitMeal() async {
    if (!validatePortions()) {
      _errorMessage = 'Semua porsi makanan harus diisi antara 1 hingga 5000 gram.';
      notifyListeners();
      return false;
    }

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
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

      final now = DateTime.now();
      _savedMealRecord = await mealRepository.createMeal(
        mealType: _mealType,
        consumedAt: now,
        items: itemsPayload,
      );
      return true;
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
    _isProcessing = false;
    _errorMessage = null;
    _confirmedItems = [];
    _savedMealRecord = null;
    _suggestDefaultMealType();
    notifyListeners();
  }
}
