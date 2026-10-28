import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/data/models/article.dart';
import 'package:nutriview/data/models/dashboard.dart';
import 'package:nutriview/data/models/meal.dart';
import 'package:nutriview/data/models/user.dart';
import 'package:nutriview/data/repositories/article_repository.dart';
import 'package:nutriview/data/repositories/auth_repository.dart';
import 'package:nutriview/data/repositories/dashboard_repository.dart';
import 'package:nutriview/data/repositories/meal_repository.dart';
import 'package:nutriview/data/repositories/profile_repository.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/features/dashboard/providers/dashboard_provider.dart';
import 'package:nutriview/features/dashboard/screens/dashboard_screen.dart';
import 'package:nutriview/features/meals/providers/meal_history_provider.dart';
import 'package:nutriview/features/profile/providers/profile_provider.dart';
import 'package:nutriview/features/profile/screens/profile_screen.dart';
import 'package:nutriview/shared/neo/neo.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockMealRepository extends Mock implements MealRepository {}

class MockDashboardRepository extends Mock implements DashboardRepository {}

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('NeoAvatar Component Tests', () {
    testWidgets('renders game avatar character when photoUrl is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NeoAvatar(name: 'Ahmad Badawi', size: 40)),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
      expect(
        find.bySemanticsLabel(RegExp(r'Avatar Master Koki')),
        findsOneWidget,
      );
    });

    testWidgets(
      'renders specific game character when avatarPreset is specified',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: NeoAvatar(
                avatarPreset: 'runner_ace',
                name: 'Ahmad',
                size: 40,
              ),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel(RegExp(r'Avatar Pelari Tangguh')),
          findsOneWidget,
        );
      },
    );

    testWidgets('responds to tap callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoAvatar(
              name: 'Ahmad Badawi',
              size: 40,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NeoAvatar));
      expect(tapped, isTrue);
    });
  });

  group('Floating Bottom Navigation Dock Tests', () {
    testWidgets(
      'NeoBottomNav renders all 5 items with zero emojis and responsive layout',
      (tester) async {
        NeoNavTab currentTab = NeoNavTab.home;
        bool scanPressed = false;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                home: Scaffold(
                  bottomNavigationBar: NeoBottomNav(
                    activeTab: currentTab,
                    onTabSelected: (tab) => setState(() => currentTab = tab),
                    onScanPressed: () => scanPressed = true,
                  ),
                ),
              );
            },
          ),
        );

        // Verify all 5 text labels exist (Monospace uppercase)
        expect(find.text('BERANDA'), findsOneWidget);
        expect(find.text('ARTIKEL'), findsOneWidget);
        expect(find.text('PINDAI'), findsOneWidget);
        expect(find.text('RIWAYAT'), findsOneWidget);
        expect(find.text('PROFIL'), findsOneWidget);

        // Verify zero emojis in bottom navigation
        final allTextWidgets = tester.widgetList<Text>(find.byType(Text));
        for (final textWidget in allTextWidgets) {
          final text = textWidget.data ?? '';
          expect(
            text.contains(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true)),
            isFalse,
          );
        }

        // Tap ARTIKEL tab
        await tester.tap(find.text('ARTIKEL'));
        await tester.pumpAndSettle();
        expect(currentTab, NeoNavTab.article);

        // Tap PINDAI centerpiece
        await tester.tap(find.text('PINDAI'));
        expect(scanPressed, isTrue);
      },
    );
  });

  group('Top Navbar / Header Zero Emoji & Avatar Integration Tests', () {
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
          'items': <ArticleItem>[],
          'total': 0,
          'page': 1,
          'limit': 5,
        },
      );
      when(() => mockArticleRepo.getActiveAnnouncements())
          .thenAnswer((_) async => []);

      when(() => mockDashboardRepo.getDailyDashboard(any())).thenAnswer(
        (_) async => DailyDashboard(
          date: '2026-10-24',
          mealCount: 0,
          target: MealNutritionTotals(
            caloriesKcal: 2000,
            proteinG: 60,
            carbsG: 250,
            fatG: 65,
          ),
          consumed: MealNutritionTotals(
            caloriesKcal: 500,
            proteinG: 20,
            carbsG: 60,
            fatG: 15,
          ),
          progress: DashboardProgress(
            calories: NutrientProgress(
              consumed: 500,
              target: 2000,
              percentage: 25.0,
            ),
            protein: NutrientProgress(
              consumed: 20,
              target: 60,
              percentage: 33.3,
            ),
            carbs: NutrientProgress(
              consumed: 60,
              target: 250,
              percentage: 24.0,
            ),
            fat: NutrientProgress(consumed: 15, target: 65, percentage: 23.1),
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
          email: 'ahmadbadawi@example.com',
          fullName: 'Ahmad Badawi',
          role: 'user',
          photoUrl: null,
          avatarPreset: 'chef_pro',
        ),
      );
      when(() => mockProfileRepo.getDailyTarget()).thenAnswer(
        (_) async => DailyTarget(
          bmrKcal: 1600,
          tdeeKcal: 2000,
          caloriesKcal: 2000,
          proteinG: 60,
          carbsG: 250,
          fatG: 65,
        ),
      );
      when(
        () => mockProfileRepo.updateAvatar(
          photoUrl: any(named: 'photoUrl'),
          avatarPreset: any(named: 'avatarPreset'),
        ),
      ).thenAnswer((_) async {});
    });

    Widget buildApp({Widget? home}) {
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
          home: home ?? const DashboardScreen(),
        ),
      );
    }

    testWidgets(
      'Dashboard header renders clean greeting without emoji and displays NeoAvatar',
      (tester) async {
        await authProvider.checkAuthStatus();

        await tester.pumpWidget(buildApp());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Check text does NOT contain waving hand emoji
        expect(find.text('Halo, Ahmad Badawi'), findsOneWidget);
        expect(find.textContaining('👋'), findsNothing);

        // Check NutriView title renders in the AppBar
        final appBarFinder = find.byType(AppBar);
        expect(
          find.descendant(of: appBarFinder, matching: find.text('NutriView')),
          findsOneWidget,
        );

        // Check NeoAvatar renders in the Dashboard body
        expect(find.byType(NeoAvatar), findsWidgets);

        // Tapping NeoAvatar switches tab to Profile tab
        await tester.tap(find.byType(NeoAvatar).first);
        await tester.pumpAndSettle();

        // Verify Profile tab is now active and displays user profile and avatar button
        expect(find.text('Ahmad Badawi'), findsWidgets);
        expect(find.text('Pilih Karakter Avatar'), findsOneWidget);
      },
    );

    testWidgets(
      'ProfileScreen avatar section renders presets and handles game avatar modal selection',
      (tester) async {
        await authProvider.checkAuthStatus();
        await profileProvider.loadProfile();

        await tester.pumpWidget(
          buildApp(home: const ProfileScreen(isTab: true)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verify Profile Header and buttons are rendered
        expect(find.text('Ahmad Badawi'), findsWidgets);
        expect(find.text('Pilih Karakter Avatar'), findsOneWidget);
        expect(find.text('Isi Biodata'), findsOneWidget);

        // Tap Pilih Karakter Avatar to open modal
        await tester.tap(find.text('Pilih Karakter Avatar'));
        await tester.pumpAndSettle();

        // Verify modal opened with character catalog
        expect(find.text('Katalog Avatar Game'), findsOneWidget);
        expect(find.text('Pelari Tangguh'), findsWidgets);

        // Tap Pelari Tangguh character
        await tester.tap(find.text('Pelari Tangguh').first);
        await tester.pumpAndSettle();

        // Tap Gunakan Avatar Ini button
        await tester.tap(find.text('Gunakan Avatar Ini'));
        await tester.pumpAndSettle();

        // Verify updateAvatar was called with preset 'runner_ace'
        verify(
          () => mockProfileRepo.updateAvatar(
            photoUrl: null,
            avatarPreset: 'runner_ace',
          ),
        ).called(1);
      },
    );
  });
}
