import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutriview/data/models/meal.dart';
import 'package:nutriview/data/repositories/food_repository.dart';
import 'package:nutriview/data/repositories/meal_repository.dart';
import 'package:nutriview/data/services/supabase_storage_service.dart';
import 'package:nutriview/features/scanner/providers/scan_flow_provider.dart';

class MockFoodRepository extends Mock implements FoodRepository {}
class MockMealRepository extends Mock implements MealRepository {}
class MockSupabaseStorageService extends Mock implements SupabaseStorageService {}

void main() {
  late MockFoodRepository mockFoodRepo;
  late MockMealRepository mockMealRepo;
  late MockSupabaseStorageService mockStorageService;
  late ScanFlowProvider provider;

  setUp(() {
    mockFoodRepo = MockFoodRepository();
    mockMealRepo = MockMealRepository();
    mockStorageService = MockSupabaseStorageService();

    when(() => mockMealRepo.getCurrentUserId()).thenAnswer((_) async => 'test-user-uuid-12345');

    provider = ScanFlowProvider(
      foodRepository: mockFoodRepo,
      mealRepository: mockMealRepo,
      storageService: mockStorageService,
    );

    // Setup valid confirmed food item
    provider.confirmedItems.add(
      ConfirmedFoodItem(
        foodId: 42,
        foodName: 'Sate Ayam',
        portionGrams: 150.0,
        source: 'detected',
      ),
    );
  });

  group('Meal Photo Persistence & Error Handling Tests', () {
    test('Successful camera photo upload persists image metadata to Firestore record', () async {
      final dummyBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      provider.setImageBytesForTesting(dummyBytes);

      final dummyMetadata = MealImageMetadata(
        provider: 'supabase',
        bucket: 'food-history-images',
        path: 'test-user-uuid-12345/123456789/food_123456789.jpg',
        width: 1280,
        height: 720,
      );

      when(
        () => mockStorageService.uploadFoodImage(
          userId: any(named: 'userId'),
          mealId: any(named: 'mealId'),
          imageBytes: dummyBytes,
        ),
      ).thenAnswer((_) async => dummyMetadata);

      final dummyMeal = MealRecord(
        id: 999,
        mealType: 'lunch',
        consumedAt: DateTime.now().toIso8601String(),
        consumedDate: '2026-11-07',
        createdAt: DateTime.now().toIso8601String(),
        items: [],
        totals: MealNutritionTotals(caloriesKcal: 350, proteinG: 25, carbsG: 10, fatG: 15),
        image: dummyMetadata,
      );

      when(
        () => mockMealRepo.createMeal(
          mealType: any(named: 'mealType'),
          consumedAt: any(named: 'consumedAt'),
          items: any(named: 'items'),
          imageMetadata: dummyMetadata,
          customMealId: any(named: 'customMealId'),
        ),
      ).thenAnswer((_) async => dummyMeal);

      final result = await provider.submitMeal();

      expect(result, isTrue);
      expect(provider.savedMealRecord?.image?.path, dummyMetadata.path);
      verify(
        () => mockStorageService.uploadFoodImage(
          userId: 'test-user-uuid-12345',
          mealId: any(named: 'mealId'),
          imageBytes: dummyBytes,
        ),
      ).called(1);
    });

    test('Storage upload failure is transparently reported and meal is NOT saved without photo', () async {
      final dummyBytes = Uint8List.fromList([9, 8, 7]);
      provider.setImageBytesForTesting(dummyBytes);

      when(
        () => mockStorageService.uploadFoodImage(
          userId: any(named: 'userId'),
          mealId: any(named: 'mealId'),
          imageBytes: dummyBytes,
        ),
      ).thenThrow(Exception('Supabase connection timed out'));

      final result = await provider.submitMeal();

      expect(result, isFalse);
      expect(provider.errorMessage, contains('Gagal mengunggah foto makanan'));
      // Verify Firestore createMeal was NOT called
      verifyNever(
        () => mockMealRepo.createMeal(
          mealType: any(named: 'mealType'),
          consumedAt: any(named: 'consumedAt'),
          items: any(named: 'items'),
          imageMetadata: any(named: 'imageMetadata'),
          customMealId: any(named: 'customMealId'),
        ),
      );
    });

    test('Firestore failure after storage upload triggers rollback to prevent orphaned images', () async {
      final dummyBytes = Uint8List.fromList([10, 20, 30]);
      provider.setImageBytesForTesting(dummyBytes);

      final dummyMetadata = MealImageMetadata(
        provider: 'supabase',
        bucket: 'food-history-images',
        path: 'test-user-uuid-12345/999/food_999.jpg',
      );

      when(
        () => mockStorageService.uploadFoodImage(
          userId: any(named: 'userId'),
          mealId: any(named: 'mealId'),
          imageBytes: dummyBytes,
        ),
      ).thenAnswer((_) async => dummyMetadata);

      when(
        () => mockMealRepo.createMeal(
          mealType: any(named: 'mealType'),
          consumedAt: any(named: 'consumedAt'),
          items: any(named: 'items'),
          imageMetadata: dummyMetadata,
          customMealId: any(named: 'customMealId'),
        ),
      ).thenThrow(Exception('Firestore write rejected'));

      when(() => mockStorageService.deleteFoodImage(dummyMetadata.path))
          .thenAnswer((_) async {});

      final result = await provider.submitMeal();

      expect(result, isFalse);
      // Verify rollback delete was called
      verify(() => mockStorageService.deleteFoodImage(dummyMetadata.path)).called(1);
    });

    test('ScanFlowProvider reset completely flushes imageBytes and imageFile from memory', () {
      provider.setImageBytesForTesting(Uint8List.fromList([1, 2, 3]));
      expect(provider.imageBytes, isNotNull);

      provider.reset();

      expect(provider.imageBytes, isNull);
      expect(provider.imageFile, isNull);
      expect(provider.confirmedItems, isEmpty);
    });
  });
}
