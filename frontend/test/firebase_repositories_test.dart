import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:flutter_test/flutter_test.dart';
import 'package:oopsieeats/core/error_handler.dart';
import 'package:oopsieeats/core/nutrition_calculator.dart';
import 'package:oopsieeats/data/models/food.dart';
import 'package:oopsieeats/data/repositories/food_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NutritionCalculator Unit Tests', () {
    test(
      'calculateDailyTarget calculates Mifflin-St Jeor for male correctly',
      () {
        // Age 25, Male, 70kg, 175cm, moderate activity (1.55), maintain_weight
        // BMR = 10*70 + 6.25*175 - 5*25 + 5 = 700 + 1093.75 - 125 + 5 = 1673.75
        // TDEE = 1673.75 * 1.55 = 2594.3125
        // Target = 2594 kcal
        // Protein = 1.2 * 70 = 84g
        // Fat = 0.25 * 2594.3125 / 9 = 72.06g -> 72.1g
        // Carbs = (2594.3125 - 84*4 - 72.06*9) / 4 = 402.4g
        final target = NutritionCalculator.calculateDailyTarget(
          age: 25,
          sex: 'male',
          weightKg: 70.0,
          heightCm: 175.0,
          activityLevel: 'moderate',
          goal: 'maintain_weight',
        );

        expect(target.bmrKcal, 1673.8);
        expect(target.tdeeKcal, 2594.3);
        expect(target.caloriesKcal, 2594);
        expect(target.proteinG, 84.0);
        expect(target.fatG, 72.1);
        expect(target.carbsG > 300, isTrue);
      },
    );

    test('calculateDailyTarget respects female lower calorie bound', () {
      // Underweight or severe cut should not fall below 1200 kcal for female
      final target = NutritionCalculator.calculateDailyTarget(
        age: 60,
        sex: 'female',
        weightKg: 40.0,
        heightCm: 145.0,
        activityLevel: 'sedentary',
        goal: 'lose_weight',
      );

      expect(target.caloriesKcal >= 1200, isTrue);
    });

    test(
      'calculatePortionNutrition calculates exact macros for 150g portion',
      () {
        final macros = NutritionCalculator.calculatePortionNutrition(
          caloriesPer100g: 200.0,
          proteinPer100g: 10.0,
          carbsPer100g: 20.0,
          fatPer100g: 5.0,
          portionGrams: 150.0,
        );

        expect(macros['calories_kcal'], 300.0);
        expect(macros['protein_g'], 15.0);
        expect(macros['carbs_g'], 30.0);
        expect(macros['fat_g'], 7.5);
      },
    );

    test('validateAtwater rejects inconsistent macros over 30% difference', () {
      expect(
        () => NutritionCalculator.validateAtwater(
          calories: 500.0, // expected ~ 160 kcal
          protein: 10.0,
          carbs: 20.0,
          fat: 4.0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('validateAtwater accepts consistent macros within tolerance', () {
      expect(
        () => NutritionCalculator.validateAtwater(
          calories: 156.0,
          protein: 10.0,
          carbs: 20.0,
          fat: 4.0,
        ),
        returnsNormally,
      );
    });
  });

  group('FoodRepository Local & Seed Tests', () {
    late FoodRepository foodRepo;

    setUp(() {
      foodRepo = FoodRepository();
    });

    test('searchFoods returns seed food items when offline', () async {
      final foods = await foodRepo.searchFoods(query: 'Ayam');
      expect(foods, isNotEmpty);
      expect(foods.any((f) => f.name.contains('Ayam')), isTrue);
    });

    test('searchFoods respects pagination', () async {
      final page1 = await foodRepo.searchFoods(page: 1, pageSize: 5);
      expect(page1.length, 5);

      final page2 = await foodRepo.searchFoods(page: 2, pageSize: 5);
      expect(page2.length, 5);
      expect(page1.first.id != page2.first.id, isTrue);
    });

    test('getFoodDetail returns detail with valid nutrition', () async {
      final detail = await foodRepo.getFoodDetail(1); // Apel
      expect(detail.id, 1);
      expect(detail.name, 'Apel');
      expect(detail.caloriesPer100g, 52.0);
      expect(detail.source, isNotEmpty);
    });

    test('getFoodDetail throws ApiException on non-existent food', () async {
      expect(
        () => foodRepo.getFoodDetail(999999),
        throwsA(isA<ApiException>()),
      );
    });

    test(
      'detectFood runs on-device model and maps to food nutrition',
      () async {
        final tempDir = Directory.systemTemp.createTempSync('nutriview_test_');
        final testFile = File('${tempDir.path}/test_detect.jpg');

        final imgObj = img.Image(width: 100, height: 100);
        img.fill(imgObj, color: img.ColorRgb8(100, 150, 200));
        testFile.writeAsBytesSync(img.encodeJpg(imgObj));

        try {
          final detections = await foodRepo.detectFood(testFile);
          expect(detections, isA<List<DetectionItem>>());
          for (final d in detections) {
            expect([
              'mapped',
              'unmapped',
              'food_unavailable',
              'nutrition_unavailable',
            ], contains(d.status));
          }
        } finally {
          if (tempDir.existsSync()) {
            tempDir.deleteSync(recursive: true);
          }
        }
      },
    );
  });
}
