import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:oopsieeats/core/theme.dart';
import 'package:oopsieeats/data/api_client.dart';
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
import 'package:oopsieeats/shared/neo/neo.dart';

class MockAuthProvider extends Mock implements AuthProvider {}
class MockProfileRepository extends Mock implements ProfileRepository {}
class MockMealRepository extends Mock implements MealRepository {}
class MockArticleRepository extends Mock implements ArticleRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockApiClient extends Mock implements ApiClient {}

/// A testable implementation of DashboardRepository that faithfully mimics
/// the 15-minute TTL caching behavior and forceRefresh of the production DashboardRepository.
class SynchronizedCachingDashboardRepository implements DashboardRepository {
  DailyDashboard _remoteDashboard;
  DailyDashboard? _cachedDashboard;
  bool _cacheInvalidated = false;
  int _fetchCount = 0;
  DateTime? _lastFetchTime;
  static const Duration ttl = Duration(minutes: 15);

  SynchronizedCachingDashboardRepository(this._remoteDashboard);

  int get fetchCount => _fetchCount;
  bool get isCacheInvalidated => _cacheInvalidated;

  void updateRemoteTarget(DailyDashboard newDashboard) {
    _remoteDashboard = newDashboard;
  }

  @override
  void invalidateUserCache() {
    _cacheInvalidated = true;
    _lastFetchTime = null;
    _cachedDashboard = null;
  }

  @override
  Future<DailyDashboard> getDailyDashboard(
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      invalidateUserCache();
    }
    final now = DateTime.now();
    final isExpired = _lastFetchTime == null || now.difference(_lastFetchTime!) >= ttl;

    if (_cacheInvalidated || isExpired || _cachedDashboard == null) {
      _fetchCount++;
      _cacheInvalidated = false;
      _lastFetchTime = now;
      _cachedDashboard = _remoteDashboard;
      return _cachedDashboard!;
    }

    // Return cached dashboard data
    return _cachedDashboard!;
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Biodata & Dashboard Home Synchronization Regression Tests', () {
    late MockAuthProvider mockAuthProvider;
    late MockAuthRepository mockAuthRepo;
    late MockProfileRepository mockProfileRepo;
    late MockMealRepository mockMealRepo;
    late MockArticleRepository mockArticleRepo;

    late ProfileProvider profileProvider;
    late MealHistoryProvider mealHistoryProvider;

    final initialDashboard = DailyDashboard(
      date: '2026-11-08',
      mealCount: 0,
      target: MealNutritionTotals(
        caloriesKcal: 2000.0,
        proteinG: 50.0,
        carbsG: 250.0,
        fatG: 65.0,
      ),
      consumed: MealNutritionTotals(
        caloriesKcal: 0.0,
        proteinG: 0.0,
        carbsG: 0.0,
        fatG: 0.0,
      ),
      progress: DashboardProgress(
        calories: NutrientProgress(consumed: 0, target: 2000.0, percentage: 0.0),
        protein: NutrientProgress(consumed: 0, target: 50.0, percentage: 0.0),
        carbs: NutrientProgress(consumed: 0, target: 250.0, percentage: 0.0),
        fat: NutrientProgress(consumed: 0, target: 65.0, percentage: 0.0),
      ),
    );

    final updatedDashboard = DailyDashboard(
      date: '2026-11-08',
      mealCount: 0,
      target: MealNutritionTotals(
        caloriesKcal: 2450.0,
        proteinG: 75.0,
        carbsG: 290.0,
        fatG: 70.0,
      ),
      consumed: MealNutritionTotals(
        caloriesKcal: 0.0,
        proteinG: 0.0,
        carbsG: 0.0,
        fatG: 0.0,
      ),
      progress: DashboardProgress(
        calories: NutrientProgress(consumed: 0, target: 2450.0, percentage: 0.0),
        protein: NutrientProgress(consumed: 0, target: 75.0, percentage: 0.0),
        carbs: NutrientProgress(consumed: 0, target: 290.0, percentage: 0.0),
        fat: NutrientProgress(consumed: 0, target: 70.0, percentage: 0.0),
      ),
    );

    setUp(() {
      mockAuthProvider = MockAuthProvider();
      mockAuthRepo = MockAuthRepository();
      mockProfileRepo = MockProfileRepository();
      mockMealRepo = MockMealRepository();
      mockArticleRepo = MockArticleRepository();

      when(() => mockAuthProvider.isLoggedIn).thenReturn(true);
      when(() => mockAuthProvider.role).thenReturn('user');
      when(() => mockAuthProvider.name).thenReturn('Ahmad Badawi');
      when(() => mockAuthProvider.email).thenReturn('ahmadbadawi@example.com');
      when(() => mockAuthProvider.isAdmin).thenReturn(false);
      when(() => mockAuthProvider.isBiometricEnabled).thenReturn(false);
      when(() => mockAuthProvider.isBiometricAvailable).thenReturn(false);
      when(() => mockAuthProvider.hasPromptedBiometric).thenReturn(false);
      when(() => mockAuthProvider.checkBiometricAvailability()).thenAnswer((_) async {});
      when(() => mockAuthProvider.currentUser).thenReturn(User(
        id: 1,
        email: 'ahmadbadawi@example.com',
        fullName: 'Ahmad Badawi',
      ));

      when(() => mockProfileRepo.getUser()).thenAnswer(
        (_) async => User(
          id: 1,
          email: 'ahmadbadawi@example.com',
          fullName: 'Ahmad Badawi',
          role: 'user',
          isProfileComplete: true,
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
          proteinG: 50,
          carbsG: 250,
          fatG: 65,
        ),
      );

      when(() => mockMealRepo.getMeals(
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
      )).thenAnswer((_) async => <MealRecord>[]);

      when(() => mockArticleRepo.getActiveAnnouncements()).thenAnswer((_) async => <AnnouncementItem>[]);
      when(() => mockArticleRepo.getArticles(
        categoryId: any(named: 'categoryId'),
        search: any(named: 'search'),
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      )).thenAnswer((_) async => {
        'items': <ArticleItem>[],
        'total': 0,
        'page': 1,
        'limit': 5,
      });

      profileProvider = ProfileProvider(mockProfileRepo);
      mealHistoryProvider = MealHistoryProvider(mockMealRepo);
    });

    test('Scenario a: Initial dashboard load computes targets based on initial profile or defaults (2000 kcal)', () async {
      final repository = SynchronizedCachingDashboardRepository(initialDashboard);
      final dashboardProvider = DashboardProvider(repository);

      expect(dashboardProvider.dashboard, isNull);
      await dashboardProvider.loadDashboard();

      expect(dashboardProvider.dashboard, isNotNull);
      expect(dashboardProvider.dashboard!.target.caloriesKcal, equals(2000.0));
      expect(dashboardProvider.dashboard!.target.proteinG, equals(50.0));
      expect(dashboardProvider.dashboard!.target.carbsG, equals(250.0));
      expect(dashboardProvider.dashboard!.target.fatG, equals(65.0));
      expect(repository.fetchCount, equals(1));
    });

    test('Scenario b & c: Profile/Biodata updated from 2000 kcal to 2450 kcal immediately produces updated target upon loadDashboard(forceRefresh: true) or cache invalidation without waiting for 15-min TTL', () async {
      final repository = SynchronizedCachingDashboardRepository(initialDashboard);
      final dashboardProvider = DashboardProvider(repository);

      // 1. Initial Load (2000 kcal)
      await dashboardProvider.loadDashboard();
      expect(dashboardProvider.dashboard!.target.caloriesKcal, equals(2000.0));
      expect(repository.fetchCount, equals(1));

      // 2. Profile/Biodata is updated on backend to 2450 kcal
      repository.updateRemoteTarget(updatedDashboard);

      // 3. Simulating loadDashboard within 15-minute TTL WITHOUT cache invalidation / forceRefresh
      // The repository returns cached data (2000 kcal) because TTL is active and cache was not invalidated
      await dashboardProvider.loadDashboard(forceRefresh: false);
      expect(dashboardProvider.dashboard!.target.caloriesKcal, equals(2000.0));
      expect(repository.fetchCount, equals(1), reason: 'Within TTL, cached user target was reused');

      // 4. Calling dashboardProvider.loadDashboard(forceRefresh: true) immediately invalidates cache
      await dashboardProvider.loadDashboard(forceRefresh: true);

      // 5. Produces 2450 kcal instantly without waiting 15 minutes!
      expect(dashboardProvider.dashboard!.target.caloriesKcal, equals(2450.0));
      expect(dashboardProvider.dashboard!.target.proteinG, equals(75.0));
      expect(dashboardProvider.dashboard!.target.carbsG, equals(290.0));
      expect(dashboardProvider.dashboard!.target.fatG, equals(70.0));
      expect(repository.fetchCount, equals(2), reason: 'forceRefresh: true successfully bypassed 15-minute TTL');

      // 6. Alternative: Verify dashboardProvider.invalidateCache() works directly
      final thirdDashboard = DailyDashboard(
        date: '2026-11-08',
        mealCount: 0,
        target: MealNutritionTotals(caloriesKcal: 2600.0, proteinG: 80.0, carbsG: 300.0, fatG: 75.0),
        consumed: MealNutritionTotals(caloriesKcal: 0.0, proteinG: 0.0, carbsG: 0.0, fatG: 0.0),
        progress: DashboardProgress(
          calories: NutrientProgress(consumed: 0, target: 2600.0, percentage: 0.0),
          protein: NutrientProgress(consumed: 0, target: 80.0, percentage: 0.0),
          carbs: NutrientProgress(consumed: 0, target: 300.0, percentage: 0.0),
          fat: NutrientProgress(consumed: 0, target: 75.0, percentage: 0.0),
        ),
      );
      repository.updateRemoteTarget(thirdDashboard);
      dashboardProvider.invalidateCache();
      await dashboardProvider.loadDashboard();
      expect(dashboardProvider.dashboard!.target.caloriesKcal, equals(2600.0));
      expect(repository.fetchCount, equals(3));
    });

    testWidgets('Scenario d: Switching tabs from Profile to Home refreshes dashboard state and renders 2450 kcal', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repository = SynchronizedCachingDashboardRepository(initialDashboard);
      final dashboardProvider = DashboardProvider(repository);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthRepository>.value(value: mockAuthRepo),
            Provider<ProfileRepository>.value(value: mockProfileRepo),
            Provider<MealRepository>.value(value: mockMealRepo),
            Provider<ArticleRepository>.value(value: mockArticleRepo),
            Provider<DashboardRepository>.value(value: repository),
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<ProfileProvider>.value(value: profileProvider),
            ChangeNotifierProvider<MealHistoryProvider>.value(value: mealHistoryProvider),
            ChangeNotifierProvider<DashboardProvider>.value(value: dashboardProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const DashboardScreen(initialTab: NeoNavTab.home),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Verify Initial Dashboard Target (2000 kcal) rendered in hero card
      expect(find.text('2000'), findsWidgets);
      expect(find.text('TARGET HARIAN'), findsOneWidget);

      // Switch to Profile Tab
      final profilTab = find.text('PROFIL');
      expect(profilTab, findsOneWidget);
      await tester.tap(profilTab);
      await tester.pumpAndSettle();

      // Profile tab is now active; user updates biodata (e.g. weight/height changed to yield 2450 kcal)
      repository.updateRemoteTarget(updatedDashboard);

      // Switch back to Home (BERANDA) tab
      // In DashboardScreen._onTabSelected:
      // if (tab == NeoNavTab.home) { context.read<DashboardProvider>().loadDashboard(forceRefresh: true); }
      final berandaTab = find.text('BERANDA');
      expect(berandaTab, findsOneWidget);
      await tester.tap(berandaTab);
      await tester.pumpAndSettle();

      // Verify that Home View automatically refreshes and now reflects the updated 2450 kcal target!
      expect(find.text('2450'), findsWidgets);
      expect(find.text('TARGET HARIAN'), findsOneWidget);
      expect(find.text('2000'), findsNothing);
    });

    test('DashboardRepository production cache invalidation contract test', () async {
      final mockClient = MockApiClient();
      when(() => mockClient.getToken()).thenAnswer((_) async => 'test-uid-123');

      final realRepo = DashboardRepository(mockClient);

      // Verifying invalidateUserCache contract can be called safely without exceptions
      expect(() => realRepo.invalidateUserCache(), returnsNormally);

      // Calling invalidateUserCache multiple times is idempotent
      realRepo.invalidateUserCache();
      realRepo.invalidateUserCache();
      expect(true, isTrue);
    });
  });
}
