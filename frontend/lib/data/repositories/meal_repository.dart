import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/core/nutrition_calculator.dart';
import 'package:nutriview/data/api_client.dart';
import 'package:nutriview/data/models/meal.dart';
import 'package:nutriview/data/repositories/food_repository.dart';

class MealRepository {
  final ApiClient _apiClient;
  final fb.FirebaseAuth? _customAuth;
  final FirebaseFirestore? _customFirestore;
  final FoodRepository _foodRepository;

  MealRepository([
    ApiClient? apiClient,
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FoodRepository? foodRepository,
  ]) : _apiClient = apiClient ?? ApiClient(),
       _customAuth = auth,
       _customFirestore = firestore,
       _foodRepository = foodRepository ?? FoodRepository(apiClient, firestore);

  fb.FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    if (Firebase.apps.isNotEmpty) return fb.FirebaseAuth.instance;
    return null;
  }

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    if (Firebase.apps.isNotEmpty) return FirebaseFirestore.instance;
    return null;
  }

  Future<String> _getUid() async {
    final user = _auth?.currentUser;
    if (user != null && user.uid.isNotEmpty) {
      return user.uid;
    }
    final token = await _apiClient.getToken();
    if (token != null && token.isNotEmpty) {
      return token;
    }
    throw ApiException(
      statusCode: 401,
      code: 'UNAUTHORIZED',
      message: 'Pengguna belum terautentikasi.',
    );
  }

  Future<MealRecord> createMeal({
    required String mealType,
    required DateTime consumedAt,
    required List<Map<String, dynamic>> items,
  }) async {
    final uid = await _getUid();
    final mealId = DateTime.now().millisecondsSinceEpoch;
    final consumedDate = DateFormat('yyyy-MM-dd').format(consumedAt);

    double totalCalories = 0.0;
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFat = 0.0;

    final List<Map<String, dynamic>> processedItems = [];

    for (var i = 0; i < items.length; i++) {
      final rawItem = items[i];
      final foodId = (rawItem['food_id'] as num).toInt();
      final portionGrams = (rawItem['portion_grams'] as num).toDouble();
      final confidence = (rawItem['detection_confidence'] as num?)?.toDouble();

      final foodDetail = await _foodRepository.getFoodDetail(foodId);
      final nutrition = NutritionCalculator.calculatePortionNutrition(
        portionGrams: portionGrams,
        caloriesPer100g: foodDetail.caloriesPer100g,
        proteinPer100g: foodDetail.proteinPer100g,
        carbsPer100g: foodDetail.carbsPer100g,
        fatPer100g: foodDetail.fatPer100g,
      );

      final itemCal = nutrition['calories_kcal']!;
      final itemPro = nutrition['protein_g']!;
      final itemCarb = nutrition['carbs_g']!;
      final itemFat = nutrition['fat_g']!;

      totalCalories += itemCal;
      totalProtein += itemPro;
      totalCarbs += itemCarb;
      totalFat += itemFat;

      processedItems.add({
        'id': i + 1,
        'food_id': foodId,
        'food_name': foodDetail.name,
        'portion_grams': portionGrams,
        'calories_kcal': itemCal,
        'protein_g': itemPro,
        'carbs_g': itemCarb,
        'fat_g': itemFat,
        'source': foodDetail.source,
        'detection_confidence': confidence,
      });
    }

    final totalsMap = {
      'calories_kcal': NutritionCalculator.roundHalfUp(totalCalories, 1),
      'protein_g': NutritionCalculator.roundHalfUp(totalProtein, 1),
      'carbs_g': NutritionCalculator.roundHalfUp(totalCarbs, 1),
      'fat_g': NutritionCalculator.roundHalfUp(totalFat, 1),
    };

    final mealData = {
      'id': mealId,
      'meal_type': mealType,
      'consumed_at': consumedAt.toIso8601String(),
      'consumed_date': consumedDate,
      'items': processedItems,
      'totals': totalsMap,
      'created_at': DateTime.now().toIso8601String(),
    };

    final db = _firestore;
    if (db != null) {
      await db
          .collection('users')
          .doc(uid)
          .collection('meals')
          .doc(mealId.toString())
          .set(mealData);
    }

    return MealRecord.fromJson(mealData);
  }

  Future<List<MealRecord>> getMeals({
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
    int pageSize = 20,
  }) async {
    final uid = await _getUid();
    final db = _firestore;
    if (db == null) return [];

    final snapshot = await db
        .collection('users')
        .doc(uid)
        .collection('meals')
        .get();

    final allMeals = snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      return MealRecord.fromJson(data);
    }).toList();

    // Filter by date range if provided
    var filtered = allMeals;
    final formatter = DateFormat('yyyy-MM-dd');

    if (dateFrom != null) {
      final fromStr = formatter.format(dateFrom);
      filtered = filtered
          .where((m) => m.consumedDate.compareTo(fromStr) >= 0)
          .toList();
    }
    if (dateTo != null) {
      final toStr = formatter.format(dateTo);
      filtered = filtered
          .where((m) => m.consumedDate.compareTo(toStr) <= 0)
          .toList();
    }

    // Sort descending by consumedAt
    filtered.sort((a, b) => b.consumedAt.compareTo(a.consumedAt));

    final startIndex = (page - 1) * pageSize;
    if (startIndex >= filtered.length) {
      return [];
    }
    return filtered.skip(startIndex).take(pageSize).toList();
  }

  Future<MealRecord> getMealDetail(int id) async {
    final uid = await _getUid();
    final db = _firestore;
    if (db == null) {
      throw ApiException(
        statusCode: 404,
        code: 'MEAL_NOT_FOUND',
        message: 'Data makanan tidak ditemukan.',
      );
    }

    final doc = await db
        .collection('users')
        .doc(uid)
        .collection('meals')
        .doc(id.toString())
        .get();

    if (!doc.exists || doc.data() == null) {
      // Try searching by id field
      final query = await db
          .collection('users')
          .doc(uid)
          .collection('meals')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw ApiException(
          statusCode: 404,
          code: 'MEAL_NOT_FOUND',
          message: 'Data makanan tidak ditemukan.',
        );
      }
      return MealRecord.fromJson(
        Map<String, dynamic>.from(query.docs.first.data()),
      );
    }

    return MealRecord.fromJson(Map<String, dynamic>.from(doc.data()!));
  }
}
