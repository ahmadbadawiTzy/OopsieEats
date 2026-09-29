import 'package:flutter_test/flutter_test.dart';
import 'package:nutriview/features/scanner/providers/scan_flow_provider.dart';
import 'package:nutriview/data/models/food.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutriview/data/repositories/food_repository.dart';
import 'package:nutriview/data/repositories/meal_repository.dart';

class MockFoodRepository extends Mock implements FoodRepository {}
class MockMealRepository extends Mock implements MealRepository {}

void main() {
  group('Portion Validation & ScanFlow Tests', () {
    String? validatePortion(String? val) {
      if (val == null || val.trim().isEmpty) {
        return 'Porsi wajib diisi.';
      }
      final num = double.tryParse(val.trim());
      if (num == null || num <= 0 || num > 5000) {
        return '1-5000 g';
      }
      return null;
    }

    test('Portion validator accepts valid range 0 < g <= 5000', () {
      expect(validatePortion('100'), isNull);
      expect(validatePortion('0.5'), isNull);
      expect(validatePortion('5000'), isNull);
      expect(validatePortion('250.75'), isNull);
    });

    test('Portion validator rejects empty, zero, negative, and over 5000g', () {
      expect(validatePortion(''), 'Porsi wajib diisi.');
      expect(validatePortion('   '), 'Porsi wajib diisi.');
      expect(validatePortion(null), 'Porsi wajib diisi.');
      expect(validatePortion('0'), '1-5000 g');
      expect(validatePortion('-10'), '1-5000 g');
      expect(validatePortion('5000.1'), '1-5000 g');
      expect(validatePortion('abc'), '1-5000 g');
    });

    test('ScanFlowProvider item confirmation, replace, remove, and portion validation', () {
      final mockFoodRepo = MockFoodRepository();
      final mockMealRepo = MockMealRepository();
      final provider = ScanFlowProvider(
        foodRepository: mockFoodRepo,
        mealRepository: mockMealRepo,
      );

      // Add manual items
      final food1 = FoodItem(
        id: 1,
        name: 'Nasi Putih',
        caloriesPer100g: 130.0,
        proteinPer100g: 2.4,
        carbsPer100g: 28.6,
        fatPer100g: 0.3,
      );
      final food2 = FoodItem(
        id: 2,
        name: 'Ayam Goreng',
        caloriesPer100g: 260.0,
        proteinPer100g: 24.6,
        carbsPer100g: 0.0,
        fatPer100g: 17.5,
      );

      provider.addManualItem(food1);
      provider.addManualItem(food2);

      expect(provider.confirmedItems.length, 2);
      expect(provider.confirmedItems[0].source, 'manual');
      expect(provider.confirmedItems[0].foodName, 'Nasi Putih');

      // Replace item 1 with Ikan Bandeng
      final replacementFood = FoodItem(
        id: 5,
        name: 'Ikan Bandeng',
        caloriesPer100g: 129.0,
        proteinPer100g: 20.0,
        carbsPer100g: 0.0,
        fatPer100g: 4.8,
      );
      provider.replaceItem(1, replacementFood);
      expect(provider.confirmedItems[1].foodName, 'Ikan Bandeng');
      expect(provider.confirmedItems[1].source, 'corrected');

      // Before setting portions, validatePortions is false
      expect(provider.validatePortions(), isFalse);

      // Set portions
      provider.updatePortion(0, 150.0);
      provider.updatePortion(1, 100.0);
      expect(provider.validatePortions(), isTrue);

      // Set invalid portion
      provider.updatePortion(1, 6000.0);
      expect(provider.validatePortions(), isFalse);

      // Reset to valid portion
      provider.updatePortion(1, 120.0);
      expect(provider.validatePortions(), isTrue);

      // Remove item
      provider.removeItem(0);
      expect(provider.confirmedItems.length, 1);
      expect(provider.confirmedItems[0].foodName, 'Ikan Bandeng');
      expect(provider.validatePortions(), isTrue);
    });
  });
}
