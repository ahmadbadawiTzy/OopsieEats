import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/data/models/article.dart';
import 'package:nutriview/data/models/dashboard.dart';
import 'package:nutriview/data/models/meal.dart';
import 'package:nutriview/data/models/profile.dart';
import 'package:nutriview/data/models/user.dart';
import 'package:nutriview/data/repositories/article_repository.dart';
import 'package:nutriview/data/repositories/auth_repository.dart';
import 'package:nutriview/data/repositories/dashboard_repository.dart';
import 'package:nutriview/data/repositories/meal_repository.dart';
import 'package:nutriview/data/repositories/profile_repository.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/features/dashboard/providers/dashboard_provider.dart';
import 'package:nutriview/features/dashboard/screens/dashboard_screen.dart';
import 'package:nutriview/features/dashboard/widgets/daily_calorie_hero_card.dart';
import 'package:nutriview/features/dashboard/widgets/dashboard_hero_section.dart';
import 'package:nutriview/features/dashboard/widgets/latest_articles_section.dart';
import 'package:nutriview/features/dashboard/widgets/macro_bento_grid.dart';
import 'package:nutriview/features/dashboard/widgets/scan_cta_card.dart';
import 'package:nutriview/shared/neo/neo.dart';
import 'package:nutriview/features/dashboard/widgets/todays_intake_section.dart';
import 'package:nutriview/features/meals/providers/meal_history_provider.dart';
import 'package:nutriview/features/profile/providers/profile_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockMealRepository extends Mock implements MealRepository {}

class MockDashboardRepository extends Mock implements DashboardRepository {}

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Customer-First Neo-Brutalism Dashboard Components Unit & Widget Tests', () {
    testWidgets(
      'DashboardHeroSection renders personal greeting, subtext, and handles avatar tap',
      (tester) async {
        bool tapped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DashboardHeroSection(
                userName: 'Ahmad Badawi',
                onAvatarTap: () => tapped = true,
              ),
            ),
          ),
        );

        expect(find.text('Halo, Ahmad Badawi'), findsOneWidget);
        expect(
          find.text('Yuk, pahami asupanmu dan bangun kebiasaan makan yang lebih seimbang.'),
          findsOneWidget,
        );

        await tester.tap(find.byType(DashboardHeroSection));
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'DashboardHeroSection falls back gracefully when userName is empty or email',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DashboardHeroSection(userName: ''),
            ),
          ),
        );
        expect(find.text('Halo, Sobat Sehat'), findsOneWidget);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DashboardHeroSection(userName: 'budi123@gmail.com'),
            ),
          ),
        );
        expect(find.text('Halo, Budi'), findsOneWidget);
      },
    );

    testWidgets(
      'DailyCalorieHeroCard renders target, consumed, and remaining calories correctly',
      (tester) async {
        final progress = NutrientProgress(
          consumed: 1340,
          target: 2200,
          percentage: 60.9,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DailyCalorieHeroCard(
                progress: progress,
                onCompleteProfile: () {},
              ),
            ),
          ),
        );

        expect(find.text('Ringkasan Hari Ini'), findsOneWidget);
        expect(find.text('TARGET HARIAN'), findsOneWidget);
        expect(find.text('2200'), findsOneWidget);
        expect(find.text('SUDAH MASUK'), findsOneWidget);
        expect(find.text('1340'), findsOneWidget);
        expect(find.text('SISA TARGET'), findsOneWidget);
        expect(find.text('860'), findsOneWidget);
        expect(find.text('60.9%'), findsOneWidget);
        expect(find.text('SEDANG BERJALAN'), findsOneWidget);
      },
    );

    testWidgets('DailyCalorieHeroCard handles exceeded intake cleanly', (
      tester,
    ) async {
      final progress = NutrientProgress(
        consumed: 2500,
        target: 2000,
        percentage: 125.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyCalorieHeroCard(
              progress: progress,
              onCompleteProfile: () {},
            ),
          ),
        ),
      );

      expect(find.text('MELEBIHI TARGET'), findsOneWidget);
      expect(find.text('KELEBIHAN'), findsOneWidget);
      expect(find.text('+500'), findsOneWidget);
      expect(find.text('125.0%'), findsOneWidget);
    });

    testWidgets(
      'DailyCalorieHeroCard renders incomplete profile empty state with CTA',
      (tester) async {
        bool tapped = false;
        final progress = NutrientProgress(
          consumed: 0,
          target: 0,
          percentage: 0,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DailyCalorieHeroCard(
                progress: progress,
                isProfileIncomplete: true,
                onCompleteProfile: () => tapped = true,
              ),
            ),
          ),
        );

        expect(find.text('TARGET BELUM DIATUR'), findsOneWidget);
        expect(find.text('LENGKAPI PROFIL SEKARANG'), findsOneWidget);

        await tester.tap(find.text('LENGKAPI PROFIL SEKARANG'));
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'ScanCtaCard renders Scan Makanan and responds to tap',
      (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScanCtaCard(onScanPressed: () => tapped = true),
            ),
          ),
        );

        expect(find.text('Scan Makanan'), findsOneWidget);
        expect(
          find.text('Pindai makananmu untuk mencatat kalori dan nutrisi otomatis.'),
          findsOneWidget,
        );
        expect(find.text('YOLO26N'), findsNothing);
        expect(find.text('AI Powered'), findsNothing);

        await tester.tap(find.text('Scan Makanan'));
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'MacroBentoGrid renders Protein, Karbohidrat, Lemak and activity count',
      (tester) async {
        bool historyTapped = false;
        final progress = DashboardProgress(
          calories: NutrientProgress(
            consumed: 1500,
            target: 2000,
            percentage: 75,
          ),
          protein: NutrientProgress(
            consumed: 75.5,
            target: 100,
            percentage: 75.5,
          ),
          carbs: NutrientProgress(
            consumed: 180.2,
            target: 250,
            percentage: 72.1,
          ),
          fat: NutrientProgress(consumed: 45.0, target: 65, percentage: 69.2),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MacroBentoGrid(
                progress: progress,
                mealCount: 3,
                onViewHistory: () => historyTapped = true,
              ),
            ),
          ),
        );

        expect(find.text('Keseimbangan Nutrisi'), findsOneWidget);
        expect(find.text('Protein'), findsOneWidget);
        expect(find.text('75.5g'), findsOneWidget);
        expect(find.text('Karbohidrat'), findsOneWidget);
        expect(find.text('180.2g'), findsOneWidget);
        expect(find.text('Lemak'), findsOneWidget);
        expect(find.text('45.0g'), findsOneWidget);
        expect(find.text('3 KALI'), findsOneWidget);

        await tester.tap(find.text('RIWAYAT'));
        expect(historyTapped, isTrue);
      },
    );

    testWidgets(
      'TodaysIntakeSection renders empty state with scan CTA when no meals exist',
      (tester) async {
        bool scanTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TodaysIntakeSection(
                meals: const [],
                isLoading: false,
                onRetry: () {},
                onScanPressed: () => scanTapped = true,
                onMealTapped: (_) {},
                onViewAllHistory: () {},
              ),
            ),
          ),
        );

        expect(find.text('BELUM ADA ASUPAN MAKAN'), findsOneWidget);
        expect(find.text('CATAT MAKANAN SEKARANG'), findsOneWidget);

        await tester.tap(find.text('CATAT MAKANAN SEKARANG'));
        expect(scanTapped, isTrue);
      },
    );

    testWidgets(
      'TodaysIntakeSection renders populated meals and handles meal tap',
      (tester) async {
        int? tappedMealId;

        final sampleMeal = MealRecord(
          id: 991,
          mealType: 'lunch',
          consumedAt: '2026-10-24T12:30:00Z',
          consumedDate: '2026-10-24',
          items: [
            MealItem(
              id: 1,
              foodId: 10,
              foodName: 'Nasi Putih',
              portionGrams: 150,
              caloriesKcal: 195,
              proteinG: 4,
              carbsG: 43,
              fatG: 0.5,
              source: 'tkpi',
            ),
          ],
          totals: MealNutritionTotals(
            caloriesKcal: 195,
            proteinG: 4,
            carbsG: 43,
            fatG: 0.5,
          ),
          createdAt: '2026-10-24T12:30:00Z',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TodaysIntakeSection(
                meals: [sampleMeal],
                isLoading: false,
                onRetry: () {},
                onScanPressed: () {},
                onMealTapped: (id) => tappedMealId = id,
                onViewAllHistory: () {},
              ),
            ),
          ),
        );

        expect(find.text('Makanan Hari Ini'), findsOneWidget);
        expect(find.text('MAKAN SIANG'), findsOneWidget);
        expect(find.text('Nasi Putih'), findsOneWidget);
        expect(find.text('+195 kkal'), findsOneWidget);

        await tester.tap(find.text('Nasi Putih'));
        expect(tappedMealId, 991);
      },
    );

    testWidgets(
      'LatestArticlesSection renders articles with fallback banner and view all action',
      (tester) async {
        bool viewAllTapped = false;
        ArticleItem? tappedArticle;

        final sampleArt = ArticleItem(
          id: 1,
          title: 'Nutrisi Harian untuk Energi Maksimal',
          slug: 'nutrisi-harian',
          excerpt: 'Ringkasan panduan gizi harian',
          status: 'published',
          categoryId: 10,
          categoryName: 'Gizi Seimbang',
          authorName: 'Tim NutriView',
          contentMarkdown: '# Isi',
          coverImageUrl: null,
          publishedAt: '2026-10-24',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LatestArticlesSection(
                articles: [sampleArt],
                onArticleTapped: (art) => tappedArticle = art,
                onViewAllArticles: () => viewAllTapped = true,
              ),
            ),
          ),
        );

        expect(find.text('Tips Nutrisi'), findsOneWidget);
        expect(
          find.text('Nutrisi Harian untuk Energi Maksimal'),
          findsOneWidget,
        );
        expect(find.text('NV.EDUKASI'), findsOneWidget);
        expect(find.text('LIHAT SEMUA'), findsOneWidget);

        await tester.tap(find.text('LIHAT SEMUA'));
        expect(viewAllTapped, isTrue);

        await tester.tap(find.text('Nutrisi Harian untuk Energi Maksimal'));
        expect(tappedArticle?.id, 1);
      },
    );
  });

  group('Customer-First Neo-Brutalism DashboardScreen Full Integration Tests', () {
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
      when(() => mockAuthRepo.getUserName())
          .thenAnswer((_) async => 'Ahmad Badawi');
      when(() => mockAuthRepo.getUserEmail())
          .thenAnswer((_) async => 'ahmadbadawi@example.com');
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
          'items': <ArticleItem>[
            ArticleItem(
              id: 1,
              title: 'Tips Sarapan Tinggi Protein',
              slug: 'tips-sarapan',
              contentMarkdown: 'Isi',
              excerpt: 'Ringkasan',
              status: 'published',
              categoryId: 10,
              categoryName: 'Gizi Seimbang',
              authorName: 'NutriView',
              coverImageUrl: null,
              publishedAt: '2026-10-24',
            ),
          ],
          'total': 1,
          'page': 1,
          'limit': 5,
        },
      );
      when(() => mockArticleRepo.getActiveAnnouncements())
          .thenAnswer((_) async => []);

      when(() => mockDashboardRepo.getDailyDashboard(any())).thenAnswer(
        (_) async => DailyDashboard(
          date: '2026-10-24',
          mealCount: 1,
          target: MealNutritionTotals(
            caloriesKcal: 2200,
            proteinG: 70,
            carbsG: 260,
            fatG: 65,
          ),
          consumed: MealNutritionTotals(
            caloriesKcal: 1100,
            proteinG: 35,
            carbsG: 130,
            fatG: 30,
          ),
          progress: DashboardProgress(
            calories: NutrientProgress(
              consumed: 1100,
              target: 2200,
              percentage: 50.0,
            ),
            protein: NutrientProgress(
              consumed: 35,
              target: 70,
              percentage: 50.0,
            ),
            carbs: NutrientProgress(
              consumed: 130,
              target: 260,
              percentage: 50.0,
            ),
            fat: NutrientProgress(consumed: 30, target: 65, percentage: 46.2),
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
      ).thenAnswer(
        (_) async => [
          MealRecord(
            id: 501,
            mealType: 'breakfast',
            consumedAt: '2026-10-24T07:30:00Z',
            consumedDate: '2026-10-24',
            items: [
              MealItem(
                id: 1,
                foodId: 5,
                foodName: 'Oatmeal & Pisang',
                portionGrams: 200,
                caloriesKcal: 320,
                proteinG: 10,
                carbsG: 58,
                fatG: 4,
                source: 'tkpi',
              ),
            ],
            totals: MealNutritionTotals(
              caloriesKcal: 320,
              proteinG: 10,
              carbsG: 58,
              fatG: 4,
            ),
            createdAt: '2026-10-24T07:30:00Z',
          ),
        ],
      );

      when(() => mockProfileRepo.getUser()).thenAnswer(
        (_) async => User(
          id: 1,
          email: 'ahmadbadawi@example.com',
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
          tdeeKcal: 2200,
          caloriesKcal: 2200,
          proteinG: 70,
          carbsG: 260,
          fatG: 65,
        ),
      );
    });

    Widget buildApp() {
      return MultiProvider(
        providers: [
          Provider<MealRepository>.value(value: mockMealRepo),
          Provider<ArticleRepository>.value(value: mockArticleRepo),
          Provider<DashboardRepository>.value(value: mockDashboardRepo),
          Provider<ProfileRepository>.value(value: mockProfileRepo),
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<ProfileProvider>.value(value: profileProvider),
          ChangeNotifierProvider<DashboardProvider>.value(
            value: dashboardProvider,
          ),
          ChangeNotifierProvider<MealHistoryProvider>.value(
            value: mealHistoryProvider,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DashboardScreen(),
        ),
      );
    }

    testWidgets(
      'DashboardScreen renders all Customer-First Neo-Brutalism sections with real data',
      (tester) async {
        await authProvider.checkAuthStatus();

        await tester.pumpWidget(buildApp());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // 1. Header & Identity: Clean Greeting and Avatar
        expect(find.text('Halo, Ahmad Badawi'), findsOneWidget);
        expect(find.byType(NeoAvatar), findsWidgets);
        expect(
          find.text('Yuk, pahami asupanmu dan bangun kebiasaan makan yang lebih seimbang.'),
          findsOneWidget,
        );

        // 2. Primary Scan CTA Card
        expect(find.text('Scan Makanan'), findsOneWidget);

        // 3. Daily Calorie Hero Bento Card
        expect(find.text('Ringkasan Hari Ini'), findsOneWidget);
        expect(find.text('2200'), findsOneWidget);
        expect(
          find.text('1100'),
          findsWidgets,
        ); // Both consumed and remaining are 1100

        // 4. Macro Bento Grid
        expect(find.text('Keseimbangan Nutrisi'), findsOneWidget);
        expect(find.text('Protein'), findsOneWidget);
        expect(find.text('Karbohidrat'), findsOneWidget);
        expect(find.text('Lemak'), findsOneWidget);

        // 5. Today's Intake Section
        expect(find.text('Makanan Hari Ini'), findsOneWidget);
        expect(find.text('Oatmeal & Pisang'), findsOneWidget);
        expect(find.text('+320 kkal'), findsOneWidget);

        // 6. Nutrition Field Notes Section
        expect(find.text('Tips Nutrisi'), findsOneWidget);
        expect(find.text('Tips Sarapan Tinggi Protein'), findsOneWidget);

        // 7. Medical Methodology Disclaimer
        expect(find.textContaining('Mifflin-St Jeor'), findsOneWidget);
      },
    );
  });
}
