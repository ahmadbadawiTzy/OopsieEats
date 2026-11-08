import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:oopsieeats/core/theme.dart';
import 'package:oopsieeats/data/models/article.dart';
import 'package:oopsieeats/data/models/dashboard.dart';
import 'package:oopsieeats/data/models/meal.dart';
import 'package:oopsieeats/data/models/profile.dart';
import 'package:oopsieeats/data/models/user.dart';
import 'package:oopsieeats/data/repositories/article_repository.dart';
import 'package:oopsieeats/data/repositories/auth_repository.dart';
import 'package:oopsieeats/data/repositories/dashboard_repository.dart';
import 'package:oopsieeats/data/repositories/meal_repository.dart';
import 'package:oopsieeats/data/repositories/profile_repository.dart';
import 'package:oopsieeats/features/auth/providers/auth_provider.dart';
import 'package:oopsieeats/features/dashboard/providers/dashboard_provider.dart';
import 'package:oopsieeats/features/dashboard/screens/dashboard_screen.dart';
import 'package:oopsieeats/features/meals/providers/meal_history_provider.dart';
import 'package:oopsieeats/features/profile/providers/profile_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockProfileRepository extends Mock implements ProfileRepository {}
class MockMealRepository extends Mock implements MealRepository {}
class MockDashboardRepository extends Mock implements DashboardRepository {}
class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('DashboardScreen Responsive & Accessibility Tests', () {
    late MockAuthRepository mockAuthRepo;
    late MockProfileRepository mockProfileRepo;
    late MockMealRepository mockMealRepo;
    late MockDashboardRepository mockDashboardRepo;
    late MockArticleRepository mockArticleRepo;

    late AuthProvider authProvider;
    late ProfileProvider profileProvider;
    late DashboardProvider dashboardProvider;
    late MealHistoryProvider mealHistoryProvider;

    setUp(() {
      FlutterError.onError = (details) {
        debugPrint('FLUTTER_ERROR_DETAILS: ${details.exceptionAsString()}\n${details.context}');
      };
      mockAuthRepo = MockAuthRepository();
      mockProfileRepo = MockProfileRepository();
      mockMealRepo = MockMealRepository();
      mockDashboardRepo = MockDashboardRepository();
      mockArticleRepo = MockArticleRepository();

      authProvider = AuthProvider(mockAuthRepo);
      profileProvider = ProfileProvider(mockProfileRepo);
      dashboardProvider = DashboardProvider(mockDashboardRepo);
      mealHistoryProvider = MealHistoryProvider(mockMealRepo);

      when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => true);
      when(() => mockAuthRepo.getRole()).thenAnswer((_) async => 'user');
      when(() => mockAuthRepo.getUserName()).thenAnswer((_) async => 'Ahmad Badawi');
      when(() => mockAuthRepo.getUserEmail()).thenAnswer((_) async => 'ahmad@example.com');
      when(() => mockAuthRepo.logout()).thenAnswer((_) async {});

      when(() => mockArticleRepo.getCategories()).thenAnswer((_) async => []);
      when(
        () => mockArticleRepo.getArticles(
          categoryId: any(named: 'categoryId'),
          search: any(named: 'search'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => {
          'items': <ArticleItem>[],
          'total': 0,
          'page': 1,
          'limit': 5,
        },
      );
      when(() => mockArticleRepo.getActiveAnnouncements()).thenAnswer((_) async => []);

      when(() => mockDashboardRepo.getDailyDashboard(any())).thenAnswer(
        (_) async => DailyDashboard(
          date: '2026-10-24',
          mealCount: 0,
          target: MealNutritionTotals(
            caloriesKcal: 2000,
            proteinG: 65,
            carbsG: 250,
            fatG: 60,
          ),
          consumed: MealNutritionTotals(
            caloriesKcal: 0,
            proteinG: 0,
            carbsG: 0,
            fatG: 0,
          ),
          progress: DashboardProgress(
            calories: NutrientProgress(consumed: 0, target: 2000, percentage: 0),
            protein: NutrientProgress(consumed: 0, target: 65, percentage: 0),
            carbs: NutrientProgress(consumed: 0, target: 250, percentage: 0),
            fat: NutrientProgress(consumed: 0, target: 60, percentage: 0),
          ),
        ),
      );

      when(
        () => mockMealRepo.getMeals(
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => []);

      when(() => mockProfileRepo.getUser()).thenAnswer(
        (_) async => User(
          id: 1,
          email: 'ahmad@example.com',
          fullName: 'Ahmad Badawi',
          role: 'user',
          profile: UserProfile(
            age: 25,
            sex: 'male',
            weightKg: 70,
            heightCm: 175,
            activityLevel: 'moderate',
            goal: 'maintain_weight',
          ),
        ),
      );
      when(() => mockProfileRepo.getDailyTarget()).thenAnswer(
        (_) async => DailyTarget(
          bmrKcal: 1600,
          tdeeKcal: 2000,
          caloriesKcal: 2000,
          proteinG: 65,
          carbsG: 250,
          fatG: 60,
        ),
      );
    });

    Widget buildApp({double textScale = 1.0}) {
      return MultiProvider(
        providers: [
          Provider<MealRepository>.value(value: mockMealRepo),
          Provider<ArticleRepository>.value(value: mockArticleRepo),
          Provider<DashboardRepository>.value(value: mockDashboardRepo),
          Provider<ProfileRepository>.value(value: mockProfileRepo),
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<ProfileProvider>.value(value: profileProvider),
          ChangeNotifierProvider<DashboardProvider>.value(value: dashboardProvider),
          ChangeNotifierProvider<MealHistoryProvider>.value(value: mealHistoryProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(textScale),
              ),
              child: child!,
            );
          },
          home: DashboardHomeView(onNavigateToTab: (_) {}),
        ),
      );
    }

    testWidgets('renders cleanly on small screen (320x568) without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await authProvider.checkAuthStatus();
      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.text('Halo, Ahmad Badawi'), findsOneWidget);
      expect(find.text('Scan Makanan'), findsOneWidget);
    });

    testWidgets('renders cleanly on standard modern screen (390x844) without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await authProvider.checkAuthStatus();
      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final err = tester.takeException();
      if (err is FlutterError) {
        debugPrint(err.diagnostics.map((d) => d.toStringDeep()).join('\n'));
      }
      expect(err, isNull);
      expect(find.text('Halo, Ahmad Badawi'), findsOneWidget);
      expect(find.text('Scan Makanan'), findsOneWidget);
      expect(find.text('BELUM ADA ASUPAN MAKAN'), findsOneWidget);
    });

    testWidgets('renders cleanly on large screen (412x915) without overflow', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await authProvider.checkAuthStatus();
      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.text('Halo, Ahmad Badawi'), findsOneWidget);
      expect(find.text('Scan Makanan'), findsOneWidget);
    });

    testWidgets('renders cleanly with 1.4x system font scaling without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await authProvider.checkAuthStatus();
      await tester.pumpWidget(buildApp(textScale: 1.4));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.text('Halo, Ahmad Badawi'), findsOneWidget);
      expect(find.text('Scan Makanan'), findsOneWidget);
    });

    testWidgets('renders error state and retries successfully', (tester) async {
      when(() => mockDashboardRepo.getDailyDashboard(any()))
          .thenThrow(Exception('Koneksi terputus'));

      await authProvider.checkAuthStatus();
      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Gagal memuat dashboard harian.'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });
  });
}
