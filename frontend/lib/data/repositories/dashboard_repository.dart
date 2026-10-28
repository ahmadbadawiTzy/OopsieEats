import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/core/nutrition_calculator.dart';
import 'package:nutriview/data/api_client.dart';
import 'package:nutriview/data/models/dashboard.dart';
import 'package:nutriview/data/models/meal.dart';

class DashboardRepository {
  final ApiClient _apiClient;
  final fb.FirebaseAuth? _customAuth;
  final FirebaseFirestore? _customFirestore;

  DashboardRepository([
    ApiClient? apiClient,
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  ]) : _apiClient = apiClient ?? ApiClient(),
       _customAuth = auth,
       _customFirestore = firestore;

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

  Map<String, dynamic>? _cachedUserData;
  String? _cachedUserUid;
  DateTime? _cachedUserTime;
  static const Duration _userTargetTtl = Duration(minutes: 15);

  void invalidateUserCache() {
    _cachedUserData = null;
    _cachedUserUid = null;
    _cachedUserTime = null;
  }

  Future<DailyDashboard> getDailyDashboard(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final uid = await _getUid();
    final db = _firestore;

    double consumedCalories = 0.0;
    double consumedProtein = 0.0;
    double consumedCarbs = 0.0;
    double consumedFat = 0.0;
    int mealCount = 0;

    double targetCalories = 2000.0;
    double targetProtein = 50.0;
    double targetCarbs = 250.0;
    double targetFat = 65.0;

    if (db != null) {
      // 1. Fetch meals for date
      final mealsSnapshot = await db
          .collection('users')
          .doc(uid)
          .collection('meals')
          .where('consumed_date', isEqualTo: dateStr)
          .get();

      mealCount = mealsSnapshot.docs.length;
      for (final doc in mealsSnapshot.docs) {
        final totals = doc.data()['totals'] as Map<String, dynamic>? ?? {};
        consumedCalories +=
            (totals['calories_kcal'] as num?)?.toDouble() ?? 0.0;
        consumedProtein += (totals['protein_g'] as num?)?.toDouble() ?? 0.0;
        consumedCarbs += (totals['carbs_g'] as num?)?.toDouble() ?? 0.0;
        consumedFat += (totals['fat_g'] as num?)?.toDouble() ?? 0.0;
      }

      // 2. Fetch user target / profile (with 15-min in-memory cache to prevent redundant reads on date switching)
      Map<String, dynamic>? userData;
      if (_cachedUserData != null &&
          _cachedUserUid == uid &&
          _cachedUserTime != null &&
          DateTime.now().difference(_cachedUserTime!) < _userTargetTtl) {
        userData = _cachedUserData;
      } else {
        final userDoc = await db.collection('users').doc(uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          userData = userDoc.data()!;
          _cachedUserData = userData;
          _cachedUserUid = uid;
          _cachedUserTime = DateTime.now();
        }
      }

      if (userData != null) {
        if (userData['daily_target'] != null) {
          final dt = userData['daily_target'] as Map<String, dynamic>;
          targetCalories =
              (dt['calories_kcal'] as num?)?.toDouble() ?? targetCalories;
          targetProtein =
              (dt['protein_g'] as num?)?.toDouble() ?? targetProtein;
          targetCarbs = (dt['carbs_g'] as num?)?.toDouble() ?? targetCarbs;
          targetFat = (dt['fat_g'] as num?)?.toDouble() ?? targetFat;
        } else if (userData['profile'] != null) {
          final p = userData['profile'] as Map<String, dynamic>;
          final calculated = NutritionCalculator.calculateDailyTarget(
            age: (p['age'] as num).toInt(),
            sex: p['sex'] as String,
            weightKg: (p['weight_kg'] as num).toDouble(),
            heightCm: (p['height_cm'] as num).toDouble(),
            activityLevel: p['activity_level'] as String,
            goal: p['goal'] as String,
          );
          targetCalories = calculated.caloriesKcal.toDouble();
          targetProtein = calculated.proteinG;
          targetCarbs = calculated.carbsG;
          targetFat = calculated.fatG;
        }
      }
    }

    final targetTotals = MealNutritionTotals(
      caloriesKcal: NutritionCalculator.roundHalfUp(targetCalories, 1),
      proteinG: NutritionCalculator.roundHalfUp(targetProtein, 1),
      carbsG: NutritionCalculator.roundHalfUp(targetCarbs, 1),
      fatG: NutritionCalculator.roundHalfUp(targetFat, 1),
    );

    final consumedTotals = MealNutritionTotals(
      caloriesKcal: NutritionCalculator.roundHalfUp(consumedCalories, 1),
      proteinG: NutritionCalculator.roundHalfUp(consumedProtein, 1),
      carbsG: NutritionCalculator.roundHalfUp(consumedCarbs, 1),
      fatG: NutritionCalculator.roundHalfUp(consumedFat, 1),
    );

    double calcPct(double consumed, double target) {
      if (target <= 0) return 0.0;
      return NutritionCalculator.roundHalfUp((consumed / target) * 100.0, 2);
    }

    final progress = DashboardProgress(
      calories: NutrientProgress(
        consumed: consumedTotals.caloriesKcal,
        target: targetTotals.caloriesKcal,
        percentage: calcPct(
          consumedTotals.caloriesKcal,
          targetTotals.caloriesKcal,
        ),
      ),
      protein: NutrientProgress(
        consumed: consumedTotals.proteinG,
        target: targetTotals.proteinG,
        percentage: calcPct(consumedTotals.proteinG, targetTotals.proteinG),
      ),
      carbs: NutrientProgress(
        consumed: consumedTotals.carbsG,
        target: targetTotals.carbsG,
        percentage: calcPct(consumedTotals.carbsG, targetTotals.carbsG),
      ),
      fat: NutrientProgress(
        consumed: consumedTotals.fatG,
        target: targetTotals.fatG,
        percentage: calcPct(consumedTotals.fatG, targetTotals.fatG),
      ),
    );

    return DailyDashboard(
      date: dateStr,
      mealCount: mealCount,
      target: targetTotals,
      consumed: consumedTotals,
      progress: progress,
    );
  }
}
