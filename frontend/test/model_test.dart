import 'package:flutter_test/flutter_test.dart';
import 'package:nutriview/data/models/food.dart';
import 'package:nutriview/data/models/meal.dart';
import 'package:nutriview/data/models/dashboard.dart';
import 'package:nutriview/data/models/profile.dart';

void main() {
  group('Model Serialization Tests', () {
    test('FoodItem model deserialization from json', () {
      final json = {
        'id': 1,
        'name': 'Nasi Putih',
        'calories_kcal_per_100g': 130.0,
        'protein_g_per_100g': 2.4,
        'carbs_g_per_100g': 28.6,
        'fat_g_per_100g': 0.3,
      };

      final food = FoodItem.fromJson(json);
      expect(food.id, 1);
      expect(food.name, 'Nasi Putih');
      expect(food.caloriesPer100g, 130.0);
      expect(food.proteinPer100g, 2.4);
    });

    test('FoodDetail model deserialization with source', () {
      final json = {
        'id': 2,
        'name': 'Ayam Goreng',
        'calories_kcal_per_100g': 260.0,
        'protein_g_per_100g': 24.6,
        'carbs_g_per_100g': 0.0,
        'fat_g_per_100g': 17.5,
        'source': 'TKPI 2020',
      };

      final detail = FoodDetail.fromJson(json);
      expect(detail.id, 2);
      expect(detail.name, 'Ayam Goreng');
      expect(detail.source, 'TKPI 2020');
    });

    test('DetectionItem deserialization', () {
      final json = {
        'food_id': 1,
        'food_name': 'Nasi Putih',
        'confidence': 0.88,
        'low_confidence': false,
      };

      final item = DetectionItem.fromJson(json);
      expect(item.foodId, 1);
      expect(item.foodName, 'Nasi Putih');
      expect(item.confidence, 0.88);
      expect(item.lowConfidence, false);
    });

    test('MealRecord model deserialization', () {
      final json = {
        'id': 10,
        'meal_type': 'lunch',
        'consumed_at': '2026-09-29T12:00:00Z',
        'consumed_date': '2026-09-29',
        'items': [
          {
            'id': 1,
            'food_id': 1,
            'food_name': 'Nasi Putih',
            'portion_grams': 150.0,
            'calories_kcal': 195.0,
            'protein_g': 3.6,
            'carbs_g': 42.9,
            'fat_g': 0.45,
            'source': 'manual',
            'detection_confidence': null,
          },
        ],
        'totals': {
          'calories_kcal': 195.0,
          'protein_g': 3.6,
          'carbs_g': 42.9,
          'fat_g': 0.45,
        },
        'created_at': '2026-09-29T12:05:00Z',
      };

      final meal = MealRecord.fromJson(json);
      expect(meal.id, 10);
      expect(meal.mealType, 'lunch');
      expect(meal.mealTypeLabel, 'Makan Siang');
      expect(meal.items.length, 1);
      expect(meal.items.first.foodName, 'Nasi Putih');
      expect(meal.items.first.portionGrams, 150.0);
      expect(meal.totals.caloriesKcal, 195.0);
    });

    test('DailyDashboard deserialization', () {
      final json = {
        'date': '2026-09-29',
        'meal_count': 2,
        'target': {
          'calories_kcal': 2200.0,
          'protein_g': 82.5,
          'carbs_g': 302.5,
          'fat_g': 61.1,
        },
        'consumed': {
          'calories_kcal': 1100.0,
          'protein_g': 45.0,
          'carbs_g': 150.0,
          'fat_g': 30.0,
        },
        'progress': {
          'calories_kcal': {
            'consumed': 1100.0,
            'target': 2200.0,
            'percentage': 50.0,
          },
          'protein_g': {'consumed': 45.0, 'target': 82.5, 'percentage': 54.5},
          'carbs_g': {'consumed': 150.0, 'target': 302.5, 'percentage': 49.6},
          'fat_g': {'consumed': 30.0, 'target': 61.1, 'percentage': 49.1},
        },
      };

      final dashboard = DailyDashboard.fromJson(json);
      expect(dashboard.date, '2026-09-29');
      expect(dashboard.mealCount, 2);
      expect(dashboard.target.caloriesKcal, 2200.0);
      expect(dashboard.progress.calories.percentage, 50.0);
    });

    test('DailyTarget model deserialization', () {
      final json = {
        'calories_kcal': 2558,
        'protein_g': 95.9,
        'carbs_g': 351.7,
        'fat_g': 71.1,
        'basis': {
          'bmr_kcal': 1650.0,
          'tdee_kcal': 2557.5,
          'formula': 'Mifflin-St Jeor',
        },
      };

      final target = DailyTarget.fromJson(json);
      expect(target.caloriesKcal, 2558);
      expect(target.proteinG, 95.9);
      expect(target.bmrKcal, 1650.0);
      expect(target.tdeeKcal, 2557.5);
    });

    test('UserProfile labels and serialization', () {
      final profile = UserProfile(
        age: 25,
        sex: 'male',
        weightKg: 70.0,
        heightCm: 175.0,
        activityLevel: 'moderate',
        goal: 'maintain_weight',
      );

      expect(profile.sexLabel, 'Laki-laki');
      expect(profile.activityLabel, contains('Sedang'));
      expect(profile.goalLabel, 'Mempertahankan berat badan');

      final json = profile.toJson();
      expect(json['age'], 25);
      expect(json['sex'], 'male');
    });
  });
}
