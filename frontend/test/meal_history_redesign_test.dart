import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/data/models/meal.dart';
import 'package:nutriview/data/repositories/meal_repository.dart';
import 'package:nutriview/data/services/supabase_storage_service.dart';
import 'package:nutriview/features/meals/providers/meal_history_provider.dart';
import 'package:nutriview/features/meals/screens/meal_history_screen.dart';

class MockMealRepository extends Mock implements MealRepository {}
class MockSupabaseStorageService extends Mock implements SupabaseStorageService {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  late MockMealRepository mockMealRepo;
  late MockSupabaseStorageService mockStorageService;
  late MealHistoryProvider mealHistoryProvider;

  setUp(() {
    mockMealRepo = MockMealRepository();
    mockStorageService = MockSupabaseStorageService();
    mealHistoryProvider = MealHistoryProvider(mockMealRepo);

    when(() => mockStorageService.getSignedImageUrl(any()))
        .thenAnswer((_) async => null);
  });

  MealRecord createTestMeal({
    required int id,
    required String mealType,
    required String date,
    required String time,
    required String foodName,
    required double kcal,
    required double protein,
    required double carbs,
    required double fat,
  }) {
    return MealRecord(
      id: id,
      mealType: mealType,
      consumedAt: '$date $time:00',
      consumedDate: date,
      items: [
        MealItem(
          id: id * 10,
          foodId: 1,
          foodName: foodName,
          portionGrams: 150,
          caloriesKcal: kcal,
          proteinG: protein,
          carbsG: carbs,
          fatG: fat,
          source: 'detection',
        ),
      ],
      totals: MealNutritionTotals(
        caloriesKcal: kcal,
        proteinG: protein,
        carbsG: carbs,
        fatG: fat,
      ),
      createdAt: '$date $time:00',
      image: MealImageMetadata(
        provider: 'supabase',
        bucket: 'food-history-images',
        path: 'user_123/$id/food.jpg',
      ),
    );
  }

  Widget buildTestableWidget({
    required Widget child,
    Size screenSize = const Size(390, 844),
    double textScaleFactor = 1.0,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MealHistoryProvider>.value(value: mealHistoryProvider),
        Provider<MealRepository>.value(value: mockMealRepo),
        Provider<SupabaseStorageService>.value(value: mockStorageService),
      ],
      child: MaterialApp(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => Scaffold(body: Center(child: Text('Route: ${settings.name}'))),
          );
        },
        home: MediaQuery(
          data: MediaQueryData(
            size: screenSize,
            textScaler: TextScaler.linear(textScaleFactor),
          ),
          child: child,
        ),
      ),
    );
  }

  group('MealHistoryScreen Controlled Neo-Brutalism Redesign Tests', () {
    testWidgets('renders empty state with bold Neo-Brutalist card and scan CTA', (tester) async {
      when(() => mockMealRepo.getMeals(
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      )).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestableWidget(child: const MealHistoryScreen(isTab: true)));
      await tester.pumpAndSettle();

      expect(find.text('RIWAYAT MAKAN'), findsOneWidget);
      expect(find.text('BELUM ADA CATATAN MAKAN'), findsOneWidget);
      expect(find.text('SCAN SEKARANG'), findsOneWidget);
    });

    testWidgets('renders loading indicator when fetching meals', (tester) async {
      final completer = Completer<List<MealRecord>>();
      when(() => mockMealRepo.getMeals(
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      )).thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildTestableWidget(child: const MealHistoryScreen(isTab: true)));
      await tester.pump();

      expect(find.text('Memuat riwayat makan...'), findsOneWidget);

      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('renders date headers, food dishes, meal types, and macro pills correctly', (tester) async {
      final todayStr = '2026-11-07';
      final yesterdayStr = '2026-11-06';

      final meals = [
        createTestMeal(
          id: 1,
          mealType: 'breakfast',
          date: todayStr,
          time: '08:30',
          foodName: 'Oatmeal Pisang & Susu Kedelai',
          kcal: 350,
          protein: 15.5,
          carbs: 55.0,
          fat: 6.2,
        ),
        createTestMeal(
          id: 2,
          mealType: 'lunch',
          date: todayStr,
          time: '12:45',
          foodName: 'Nasi Merah Dada Ayam & Sayur Bayam',
          kcal: 520,
          protein: 42.0,
          carbs: 60.5,
          fat: 8.0,
        ),
        createTestMeal(
          id: 3,
          mealType: 'dinner',
          date: yesterdayStr,
          time: '19:15',
          foodName: 'Ikan Bakar Sambal Matah',
          kcal: 410,
          protein: 36.0,
          carbs: 20.0,
          fat: 14.5,
        ),
      ];

      when(() => mockMealRepo.getMeals(
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      )).thenAnswer((_) async => meals);

      await tester.pumpWidget(buildTestableWidget(child: const MealHistoryScreen(isTab: true)));
      await tester.pumpAndSettle();

      // Verify food titles are visible (fixing the previous design bug where food was missing)
      expect(find.text('Oatmeal Pisang & Susu Kedelai'), findsOneWidget);
      expect(find.text('Nasi Merah Dada Ayam & Sayur Bayam'), findsOneWidget);
      expect(find.text('Ikan Bakar Sambal Matah'), findsOneWidget);

      // Verify meal type labels
      expect(find.text('SARAPAN'), findsOneWidget);
      expect(find.text('MAKAN SIANG'), findsOneWidget);
      expect(find.text('MAKAN MALAM'), findsOneWidget);

      // Verify macro stat pills
      expect(find.text('350 kkal'), findsOneWidget);
      expect(find.text('P: 15.5g'), findsOneWidget);
      expect(find.text('C: 55.0g'), findsOneWidget);
      expect(find.text('F: 6.2g'), findsOneWidget);

      // Verify daily total calorie badge for today (350 + 520 = 870 KKAL)
      expect(find.text('870 KKAL'), findsOneWidget);
      // Verify daily total for yesterday (410 KKAL)
      expect(find.text('410 KKAL'), findsOneWidget);
    });

    testWidgets('tapping meal card routes to AppRoutes.mealDetail with mealId', (tester) async {
      final meal = createTestMeal(
        id: 99,
        mealType: 'lunch',
        date: '2026-11-07',
        time: '12:00',
        foodName: 'Soto Ayam Madura',
        kcal: 480,
        protein: 28.0,
        carbs: 45.0,
        fat: 12.0,
      );

      when(() => mockMealRepo.getMeals(
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      )).thenAnswer((_) async => [meal]);

      await tester.pumpWidget(buildTestableWidget(child: const MealHistoryScreen(isTab: true)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Soto Ayam Madura'));
      await tester.pumpAndSettle();

      expect(find.text('Route: ${AppRoutes.mealDetail}'), findsOneWidget);
    });

    testWidgets('renders active date filter banner when filterDate is set and handles reset', (tester) async {
      when(() => mockMealRepo.getMeals(
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      )).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestableWidget(child: const MealHistoryScreen(isTab: true)));
      await tester.pumpAndSettle();

      // Trigger load with a specific date
      await mealHistoryProvider.loadMeals(date: DateTime(2026, 11, 5));
      await tester.pumpAndSettle();

      expect(find.textContaining('FILTER: 5 NOVEMBER 2026'), findsOneWidget);
      expect(find.text('RESET'), findsOneWidget);

      // Tap reset
      await tester.tap(find.text('RESET'));
      await tester.pumpAndSettle();

      expect(mealHistoryProvider.filterDate, isNull);
    });

    testWidgets('Responsive & Overflow Guard: Zero RenderFlex overflow on narrow 320px screen', (tester) async {
      final narrowMeal = createTestMeal(
        id: 101,
        mealType: 'lunch',
        date: '2026-11-07',
        time: '13:45',
        foodName: 'Gado-Gado Komplit Bumbu Kacang Ekstra Lontong & Kerupuk Udang',
        kcal: 685,
        protein: 22.4,
        carbs: 85.0,
        fat: 24.8,
      );

      when(() => mockMealRepo.getMeals(
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      )).thenAnswer((_) async => [narrowMeal]);

      // Render on extreme narrow screen (320px width - e.g. iPhone SE 1st gen / KaiOS / small screen)
      await tester.pumpWidget(
        buildTestableWidget(
          child: const MealHistoryScreen(isTab: true),
          screenSize: const Size(320, 568),
          textScaleFactor: 1.0,
        ),
      );
      await tester.pumpAndSettle();

      // Verify no exceptions thrown during layout
      expect(tester.takeException(), isNull);
      expect(find.text('SARAPAN').evaluate().isNotEmpty || find.text('MAKAN SIANG').evaluate().isNotEmpty, isTrue);
    });

    testWidgets('Responsive & Overflow Guard: Zero RenderFlex overflow with 1.4x font scale on 360px screen', (tester) async {
      final meal = createTestMeal(
        id: 102,
        mealType: 'breakfast',
        date: '2026-11-07',
        time: '07:15',
        foodName: 'Bubur Ayam Spesial Telur Asin & Cakwe',
        kcal: 420,
        protein: 18.0,
        carbs: 62.0,
        fat: 9.5,
      );

      when(() => mockMealRepo.getMeals(
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      )).thenAnswer((_) async => [meal]);

      await tester.pumpWidget(
        buildTestableWidget(
          child: const MealHistoryScreen(isTab: true),
          screenSize: const Size(360, 640),
          textScaleFactor: 1.4,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
