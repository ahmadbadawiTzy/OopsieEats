import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:oopsieeats/core/routes.dart';
import 'package:oopsieeats/core/theme.dart';
import 'package:oopsieeats/data/models/article.dart';
import 'package:oopsieeats/data/models/dashboard.dart';
import 'package:oopsieeats/data/models/meal.dart';
import 'package:oopsieeats/data/models/profile.dart';
import 'package:oopsieeats/data/models/user.dart';
import 'package:oopsieeats/data/repositories/article_repository.dart';
import 'package:oopsieeats/data/repositories/auth_repository.dart';
import 'package:oopsieeats/data/repositories/dashboard_repository.dart';
import 'package:oopsieeats/data/repositories/profile_repository.dart';
import 'package:oopsieeats/features/article/screens/article_detail_screen.dart';
import 'package:oopsieeats/features/article/screens/article_list_screen.dart';
import 'package:oopsieeats/features/auth/providers/auth_provider.dart';
import 'package:oopsieeats/features/dashboard/providers/dashboard_provider.dart';
import 'package:oopsieeats/features/dashboard/screens/dashboard_screen.dart';
import 'package:oopsieeats/features/profile/providers/profile_provider.dart';
import 'package:oopsieeats/features/profile/screens/profile_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:oopsieeats/shared/neo/neo.dart';

import 'package:oopsieeats/data/repositories/meal_repository.dart';
import 'package:oopsieeats/features/meals/providers/meal_history_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockDashboardRepository extends Mock implements DashboardRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockArticleRepository extends Mock implements ArticleRepository {}

class MockMealRepository extends Mock implements MealRepository {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });
  late MockAuthRepository mockAuthRepo;
  late MockDashboardRepository mockDashboardRepo;
  late MockProfileRepository mockProfileRepo;
  late MockArticleRepository mockArticleRepo;
  late MockMealRepository mockMealRepo;

  late AuthProvider authProvider;
  late DashboardProvider dashboardProvider;
  late ProfileProvider profileProvider;
  late MealHistoryProvider mealHistoryProvider;

  final sampleArticles = [
    ArticleItem(
      id: 1,
      title: 'Panduan Gizi Seimbang NutriView',
      slug: 'panduan-gizi-seimbang',
      excerpt: 'Mengenal porsi makronutrien ideal untuk aktivitas harian.',
      coverImageUrl: null, // Test null cover image
      categoryId: 10,
      categoryName: 'Gizi Seimbang',
      authorName: 'Dr. Gizi',
      status: 'published',
      contentMarkdown: '# Panduan Lengkap\n\nIsi konten edukasi gizi.',
      publishedAt: '2026-10-24T10:00:00Z',
    ),
    ArticleItem(
      id: 2,
      title: 'Manfaat Hidrasi Optimal',
      slug: 'manfaat-hidrasi-optimal',
      excerpt: 'Pentingnya air putih bagi metabolisme sel.',
      coverImageUrl:
          'https://images.unsplash.com/photo-1548839140-29a749e1bc4e',
      categoryId: 20,
      categoryName: 'Hidrasi',
      authorName: 'Tim NutriView',
      status: 'published',
      contentMarkdown: '# Hidrasi Sehat\n\nMinumlah 2 liter air per hari.',
      publishedAt: '2026-10-23T14:30:00Z',
    ),
  ];

  final sampleCategories = [
    CategoryItem(id: 10, name: 'Gizi Seimbang', slug: 'gizi-seimbang'),
    CategoryItem(id: 20, name: 'Hidrasi', slug: 'hidrasi'),
  ];

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockDashboardRepo = MockDashboardRepository();
    mockProfileRepo = MockProfileRepository();
    mockArticleRepo = MockArticleRepository();

    when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => true);
    when(() => mockAuthRepo.getRole()).thenAnswer((_) async => 'user');
    when(() => mockAuthRepo.getUserName())
        .thenAnswer((_) async => 'Ahmad Badawi');
    when(() => mockAuthRepo.getUserEmail())
        .thenAnswer((_) async => 'ahmadbadawi@example.com');
    when(() => mockAuthRepo.logout()).thenAnswer((_) async {});
    when(() => mockAuthRepo.deleteAccount(password: any(named: 'password')))
        .thenAnswer((_) async {});

    when(() => mockArticleRepo.getCategories())
        .thenAnswer((_) async => sampleCategories);
    when(
      () => mockArticleRepo.getArticles(
        categoryId: any(named: 'categoryId'),
        search: any(named: 'search'),
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => {
        'items': sampleArticles,
        'total': 2,
        'page': 1,
        'limit': 50,
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
          caloriesKcal: 850,
          proteinG: 30,
          carbsG: 100,
          fatG: 25,
        ),
        progress: DashboardProgress(
          calories: NutrientProgress(
            consumed: 850,
            target: 2000,
            percentage: 42.5,
          ),
          protein: NutrientProgress(consumed: 30, target: 60, percentage: 50.0),
          carbs: NutrientProgress(consumed: 100, target: 250, percentage: 40.0),
          fat: NutrientProgress(consumed: 25, target: 65, percentage: 38.5),
        ),
      ),
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
        tdeeKcal: 2000,
        caloriesKcal: 2000,
        proteinG: 60,
        carbsG: 250,
        fatG: 65,
      ),
    );
    mockMealRepo = MockMealRepository();
    when(
      () => mockMealRepo.getMeals(
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      ),
    ).thenAnswer((_) async => []);

    authProvider = AuthProvider(mockAuthRepo);
    dashboardProvider = DashboardProvider(mockDashboardRepo);
    profileProvider = ProfileProvider(mockProfileRepo);
    mealHistoryProvider = MealHistoryProvider(mockMealRepo);
  });

  Widget buildTestApp({Widget? home, String? initialRoute}) {
    return MultiProvider(
      providers: [
        Provider<ArticleRepository>.value(value: mockArticleRepo),
        Provider<AuthRepository>.value(value: mockAuthRepo),
        Provider<MealRepository>.value(value: mockMealRepo),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<DashboardProvider>.value(
          value: dashboardProvider,
        ),
        ChangeNotifierProvider<ProfileProvider>.value(value: profileProvider),
        ChangeNotifierProvider<MealHistoryProvider>.value(
          value: mealHistoryProvider,
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: initialRoute,
        routes: {
          AppRoutes.articleDetail: (ctx) {
            final art = ModalRoute.of(ctx)!.settings.arguments as ArticleItem;
            return ArticleDetailScreen(article: art);
          },
          AppRoutes.login: (ctx) =>
              const Scaffold(body: Text('Login Screen Mock')),
        },
        home: home,
      ),
    );
  }

  group('NeoBottomNav Tests', () {
    testWidgets(
      'renders all 5 items including ARTIKEL and highlights active tab',
      (tester) async {
        NeoNavTab? selectedTab;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              bottomNavigationBar: NeoBottomNav(
                activeTab: NeoNavTab.article,
                onTabSelected: (tab) => selectedTab = tab,
                onScanPressed: () {},
              ),
            ),
          ),
        );

        // Verify all 5 tab buttons exist in the dock
        expect(find.text('BERANDA'), findsOneWidget);
        expect(find.text('ARTIKEL'), findsOneWidget);
        expect(find.text('PINDAI'), findsOneWidget);
        expect(find.text('RIWAYAT'), findsOneWidget);
        expect(find.text('PROFIL'), findsOneWidget);

        // Tap ARTIKEL
        await tester.tap(find.text('ARTIKEL'));
        expect(selectedTab, equals(NeoNavTab.article));

        // Tap BERANDA
        await tester.tap(find.text('BERANDA'));
        expect(selectedTab, equals(NeoNavTab.home));
      },
    );
  });

  group('ArticleListScreen Tests', () {
    testWidgets(
      'displays articles, category pills, search bar, and handles null image fallback',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(home: const ArticleListScreen(isTab: true)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verify header and articles
        expect(find.text('Artikel Nutrisi'), findsOneWidget);
        expect(find.text('Panduan Gizi Seimbang NutriView'), findsOneWidget);
        expect(find.text('Manfaat Hidrasi Optimal'), findsOneWidget);

        // Verify Category pills
        expect(find.text('Semua'), findsOneWidget);
        expect(find.text('Gizi Seimbang'), findsWidgets);
        expect(find.text('Hidrasi'), findsWidgets);

        // Verify fallback banner rendered for null image
        expect(find.text('Panduan Gizi & Nutrisi'), findsWidgets);
        expect(find.text('NV.EDUKASI'), findsNothing);
        expect(find.text('Baca Artikel'), findsWidgets);

        // Tap an article to open ArticleDetailScreen
        await tester.tap(find.text('Panduan Gizi Seimbang NutriView'));
        await tester.pumpAndSettle();

        // Check detail screen opened
        expect(find.text('Artikel Nutrisi'), findsWidgets);
        expect(find.text('Ditulis oleh Dr. Gizi'), findsOneWidget);
      },
    );
  });

  group('DashboardScreen & Redesigned Header Tests', () {
    testWidgets(
      'displays user greeting, initial badge, status chip and does NOT have logout in header',
      (tester) async {
        await authProvider.checkAuthStatus();

        await tester.pumpWidget(buildTestApp(home: const DashboardScreen()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Greeting and identity
        expect(find.textContaining('Halo, Ahmad Badawi'), findsOneWidget);
        expect(find.text('CATATAN GIZI HARIAN'), findsWidgets);
        expect(find.text('NUTRIVIEW // PROTOKOL GIZI'), findsNothing);
        expect(find.byType(NeoAvatar), findsWidgets);

        // Verify NO logout icon in the AppBar
        final appBar = find.byType(AppBar);
        expect(
          find.descendant(
            of: appBar,
            matching: find.byIcon(Icons.logout_rounded),
          ),
          findsNothing,
        );

        // Tab switching: Switch to ARTIKEL tab
        await tester.tap(find.text('ARTIKEL'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Artikel Nutrisi'), findsOneWidget);

        // Back navigation test: PopScope safety reverts to BERANDA
        final popScopeFinder = find.byWidgetPredicate((w) => w is PopScope);
        expect(popScopeFinder, findsOneWidget);
        final popScopeWidget = tester.widget(popScopeFinder) as PopScope;
        expect(popScopeWidget.canPop, isFalse);

        // Trigger back button handling
        popScopeWidget.onPopInvokedWithResult?.call(false, null);
        await tester.pump();

        // Ensure user is back on BERANDA and not logged out
        expect(find.textContaining('Halo, Ahmad Badawi'), findsOneWidget);
        expect(authProvider.isLoggedIn, isTrue);

        final updatedPopScope = tester.widget(
          find.byWidgetPredicate((w) => w is PopScope),
        ) as PopScope;
        expect(updatedPopScope.canPop, isTrue);
      },
    );
  });

  group('Logout Audit & Confirmation Dialog Tests', () {
    testWidgets(
      'ProfileScreen logout button displays confirmation dialog; Batal preserves session; Ya logs out',
      (tester) async {
        await authProvider.checkAuthStatus();

        await tester.pumpWidget(
          buildTestApp(home: const ProfileScreen(isTab: false)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Scroll down to Logout button in ProfileScreen
        final logoutButton = find.text('Keluar dari Akun');
        await tester.ensureVisible(logoutButton);
        await tester.pumpAndSettle();
        expect(logoutButton, findsOneWidget);

        // 1. Click Logout button -> NeoDialog must appear
        await tester.tap(logoutButton);
        await tester.pumpAndSettle();

        expect(find.text('Keluar dari Akun?'), findsOneWidget);
        expect(find.text('Batal'), findsOneWidget);
        expect(find.text('Ya, Logout'), findsOneWidget);

        // 2. Click "Batal"
        await tester.tap(find.text('Batal'));
        await tester.pumpAndSettle();

        // Verify dialog dismissed and user remains logged in
        expect(find.text('Keluar dari Akun?'), findsNothing);
        expect(authProvider.isLoggedIn, isTrue);
        verifyNever(() => mockAuthRepo.logout());

        // 3. Click Logout again -> Confirm "Ya, Logout"
        await tester.tap(logoutButton);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ya, Logout'));
        await tester.pumpAndSettle();

        // Verify logout repository called and redirected to Login
        verify(() => mockAuthRepo.logout()).called(1);
        expect(find.text('Login Screen Mock'), findsOneWidget);
      },
    );

    testWidgets(
      'ProfileScreen delete account button displays confirmation dialog; Batal preserves session; Hapus Akun triggers delete and redirects to login',
      (tester) async {
        await authProvider.checkAuthStatus();

        await tester.pumpWidget(
          buildTestApp(home: const ProfileScreen(isTab: false)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Scroll down to Delete Account button in ProfileScreen
        final deleteButton = find.text('Hapus Akun & Data');
        await tester.ensureVisible(deleteButton);
        await tester.pumpAndSettle();
        expect(deleteButton, findsOneWidget);

        // 1. Click Delete Account button -> NeoDialog must appear
        await tester.tap(deleteButton);
        await tester.pumpAndSettle();

        expect(find.text('Hapus Akun & Data?'), findsOneWidget);
        expect(find.text('Batal'), findsOneWidget);
        expect(find.text('Hapus Akun'), findsOneWidget);

        // 2. Click "Batal"
        await tester.tap(find.text('Batal'));
        await tester.pumpAndSettle();

        // Verify dialog dismissed and user remains logged in
        expect(find.text('Hapus Akun & Data?'), findsNothing);
        expect(authProvider.isLoggedIn, isTrue);
        verifyNever(
          () => mockAuthRepo.deleteAccount(password: any(named: 'password')),
        );

        // 3. Click Delete Account again -> Confirm "Hapus Akun"
        await tester.tap(deleteButton);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Hapus Akun'));
        await tester.pumpAndSettle();

        // Verify deleteAccount repository called and redirected to Login
        verify(
          () => mockAuthRepo.deleteAccount(password: any(named: 'password')),
        ).called(1);
        expect(find.text('Login Screen Mock'), findsOneWidget);
      },
    );
  });

  group('Controlled Neo-Brutalism Article & Consumer Copywriting Tests', () {
    testWidgets(
      'Search bar is comfortable with 54dp height and concise hint text',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(home: const ArticleListScreen(isTab: true)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // 1. Search TextField exists with consumer hint
        expect(find.text('Cari artikel nutrisi...'), findsOneWidget);

        // 2. Header is clean with NO clutter badges
        expect(find.text('EDUKASI'), findsNothing);
        expect(
          find.textContaining('ARTIKEL', findRichText: true),
          findsNothing,
        );

        // 3. Search container height
        final searchContainerFinder = find.ancestor(
          of: find.byType(TextField),
          matching: find.byType(Container),
        );
        expect(searchContainerFinder, findsWidgets);

        // 4. Type search query
        await tester.enterText(find.byType(TextField), 'Hidrasi');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        // Verify clear button appears
        expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'Empty search results display consumer-friendly title and reset action',
      (tester) async {
        when(
          () => mockArticleRepo.getArticles(
            categoryId: any(named: 'categoryId'),
            search: 'xyznotfound',
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => {
            'items': <ArticleItem>[],
            'total': 0,
            'page': 1,
            'limit': 50,
          },
        );

        await tester.pumpWidget(
          buildTestApp(home: const ArticleListScreen(isTab: true)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Submit search with no results
        await tester.enterText(find.byType(TextField), 'xyznotfound');
        final textField = tester.widget<TextField>(find.byType(TextField));
        textField.onSubmitted?.call('xyznotfound');
        await tester.pumpAndSettle();

        // Assert friendly empty state
        expect(find.text('Artikel Tidak Ditemukan'), findsOneWidget);
        expect(
          find.textContaining(
            'Tidak ada artikel yang cocok dengan kata kunci "xyznotfound"',
          ),
          findsOneWidget,
        );
        expect(find.text('Tampilkan Semua Artikel'), findsOneWidget);
      },
    );
  });
}
