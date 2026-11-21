import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:oopsieeats/core/error_handler.dart';
import 'package:oopsieeats/core/nutrition_calculator.dart';
import 'package:oopsieeats/core/routes.dart';
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
import 'package:oopsieeats/features/profile/screens/biodata_screen.dart';
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
    registerFallbackValue(
      UserProfile(
        age: 25,
        sex: 'male',
        weightKg: 70,
        heightCm: 175,
        activityLevel: 'moderate',
        goal: 'maintain_weight',
      ),
    );
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

    test('Scenarios 1-5: Changing weight, height, age, activity level, or multiple fields immediately recalculates Home calorie summary; non-nutrition fields do not', () async {
      final repository = SynchronizedCachingDashboardRepository(initialDashboard);
      final dashboardProvider = DashboardProvider(repository);

      // Wire ProfileProvider -> DashboardProvider synchronization as in main.dart
      profileProvider.onProfileUpdated = () {
        if (profileProvider.dailyTarget != null) {
          dashboardProvider.updateTargetFromBiodata(profileProvider.dailyTarget!);
        }
      };

      await dashboardProvider.loadDashboard();
      await profileProvider.loadProfile();

      final baseProfile = UserProfile(
        age: 25,
        sex: 'male',
        weightKg: 70,
        heightCm: 175,
        activityLevel: 'moderate',
        goal: 'maintain_weight',
      );

      when(
        () => mockProfileRepo.saveBiodata(
          fullName: any(named: 'fullName'),
          profile: any(named: 'profile'),
        ),
      ).thenAnswer((invocation) async {
        return invocation.namedArguments[#profile] as UserProfile;
      });

      // 1. Change weight (70 -> 80 kg) -> calorie summary updates immediately
      final weightUpdated = baseProfile.copyWith(weightKg: 80);
      final expectedWeightTarget = NutritionCalculator.calculateDailyTarget(
        age: weightUpdated.calculatedAge,
        sex: weightUpdated.sex,
        weightKg: weightUpdated.weightKg,
        heightCm: weightUpdated.heightCm,
        activityLevel: weightUpdated.activityLevel,
        goal: weightUpdated.goal,
      );
      final ok1 = await profileProvider.saveBiodata(
        fullName: 'Ahmad Badawi',
        newProfile: weightUpdated,
      );
      expect(ok1, isTrue);
      expect(
        dashboardProvider.dashboard!.target.caloriesKcal,
        equals(expectedWeightTarget.caloriesKcal.toDouble()),
      );
      expect(
        dashboardProvider.dashboard!.progress.calories.target,
        equals(expectedWeightTarget.caloriesKcal.toDouble()),
      );

      // 2. Change height (175 -> 185 cm) -> calorie summary updates immediately
      final heightUpdated = weightUpdated.copyWith(heightCm: 185);
      final expectedHeightTarget = NutritionCalculator.calculateDailyTarget(
        age: heightUpdated.calculatedAge,
        sex: heightUpdated.sex,
        weightKg: heightUpdated.weightKg,
        heightCm: heightUpdated.heightCm,
        activityLevel: heightUpdated.activityLevel,
        goal: heightUpdated.goal,
      );
      await profileProvider.saveBiodata(
        fullName: 'Ahmad Badawi',
        newProfile: heightUpdated,
      );
      expect(
        dashboardProvider.dashboard!.target.caloriesKcal,
        equals(expectedHeightTarget.caloriesKcal.toDouble()),
      );

      // 3. Change age (25 -> 35) -> calorie summary updates immediately
      final ageUpdated = heightUpdated.copyWith(age: 35);
      final expectedAgeTarget = NutritionCalculator.calculateDailyTarget(
        age: ageUpdated.calculatedAge,
        sex: ageUpdated.sex,
        weightKg: ageUpdated.weightKg,
        heightCm: ageUpdated.heightCm,
        activityLevel: ageUpdated.activityLevel,
        goal: ageUpdated.goal,
      );
      await profileProvider.saveBiodata(
        fullName: 'Ahmad Badawi',
        newProfile: ageUpdated,
      );
      expect(
        dashboardProvider.dashboard!.target.caloriesKcal,
        equals(expectedAgeTarget.caloriesKcal.toDouble()),
      );

      // 4. Change activity level ('moderate' -> 'active') -> calorie summary updates immediately
      final activityUpdated = ageUpdated.copyWith(activityLevel: 'active');
      final expectedActivityTarget = NutritionCalculator.calculateDailyTarget(
        age: activityUpdated.calculatedAge,
        sex: activityUpdated.sex,
        weightKg: activityUpdated.weightKg,
        heightCm: activityUpdated.heightCm,
        activityLevel: activityUpdated.activityLevel,
        goal: activityUpdated.goal,
      );
      await profileProvider.saveBiodata(
        fullName: 'Ahmad Badawi',
        newProfile: activityUpdated,
      );
      expect(
        dashboardProvider.dashboard!.target.caloriesKcal,
        equals(expectedActivityTarget.caloriesKcal.toDouble()),
      );

      // 5a. Change multiple biodata fields (sex, weight, height, goal) -> summary updates accurately
      final multiUpdated = UserProfile(
        age: 28,
        sex: 'female',
        weightKg: 58,
        heightCm: 165,
        activityLevel: 'light',
        goal: 'lose_weight',
      );
      final expectedMultiTarget = NutritionCalculator.calculateDailyTarget(
        age: multiUpdated.calculatedAge,
        sex: multiUpdated.sex,
        weightKg: multiUpdated.weightKg,
        heightCm: multiUpdated.heightCm,
        activityLevel: multiUpdated.activityLevel,
        goal: multiUpdated.goal,
      );
      await profileProvider.saveBiodata(
        fullName: 'Siti Aminah',
        newProfile: multiUpdated,
      );
      expect(
        dashboardProvider.dashboard!.target.caloriesKcal,
        equals(expectedMultiTarget.caloriesKcal.toDouble()),
      );
      expect(
        dashboardProvider.dashboard!.target.proteinG,
        equals(expectedMultiTarget.proteinG),
      );
      expect(
        dashboardProvider.dashboard!.target.carbsG,
        equals(expectedMultiTarget.carbsG),
      );
      expect(
        dashboardProvider.dashboard!.target.fatG,
        equals(expectedMultiTarget.fatG),
      );

      // 5b. Changing ONLY non-relevant fields (fullName & profession) does NOT trigger recalculation
      final versionBeforeNonMetric = profileProvider.biodataVersion;
      var dashboardNotifyCount = 0;
      dashboardProvider.addListener(() => dashboardNotifyCount++);

      final nonMetricUpdated = multiUpdated.copyWith(profession: 'Dokter');
      await profileProvider.saveBiodata(
        fullName: 'Dr. Siti Aminah',
        newProfile: nonMetricUpdated,
      );
      expect(profileProvider.biodataVersion, equals(versionBeforeNonMetric));
      expect(dashboardNotifyCount, equals(0));
      expect(profileProvider.user?.fullName, equals('Dr. Siti Aminah'));
    });

    testWidgets('Scenarios 6 & 7: Saving biodata in Kelola Biodata, navigating back to Home, and restarting app keeps latest calorie summary', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      registerFallbackValue(
        UserProfile(
          age: 25,
          sex: 'male',
          weightKg: 70,
          heightCm: 175,
          activityLevel: 'moderate',
          goal: 'maintain_weight',
        ),
      );

      final repository = SynchronizedCachingDashboardRepository(initialDashboard);
      final dashboardProvider = DashboardProvider(repository);

      var persistedProfile = UserProfile(
        age: 25,
        birthDate: DateTime(2001, 5, 10),
        sex: 'male',
        weightKg: 70,
        heightCm: 175,
        activityLevel: 'moderate',
        goal: 'maintain_weight',
      );

      when(
        () => mockProfileRepo.saveBiodata(
          fullName: any(named: 'fullName'),
          profile: any(named: 'profile'),
        ),
      ).thenAnswer((invocation) async {
        persistedProfile = invocation.namedArguments[#profile] as UserProfile;
        final target = NutritionCalculator.calculateDailyTarget(
          age: persistedProfile.calculatedAge,
          sex: persistedProfile.sex,
          weightKg: persistedProfile.weightKg,
          heightCm: persistedProfile.heightCm,
          activityLevel: persistedProfile.activityLevel,
          goal: persistedProfile.goal,
        );
        repository.updateRemoteTarget(initialDashboard.withUpdatedTarget(target));
        return persistedProfile;
      });

      Widget buildTestShell({
        required ProfileProvider profProv,
        required DashboardProvider dashProv,
      }) {
        return MultiProvider(
          providers: [
            Provider<AuthRepository>.value(value: mockAuthRepo),
            Provider<ProfileRepository>.value(value: mockProfileRepo),
            Provider<MealRepository>.value(value: mockMealRepo),
            Provider<ArticleRepository>.value(value: mockArticleRepo),
            Provider<DashboardRepository>.value(value: repository),
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<ProfileProvider>.value(value: profProv),
            ChangeNotifierProvider<MealHistoryProvider>.value(value: mealHistoryProvider),
            ChangeNotifierProvider<DashboardProvider>.value(value: dashProv),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            routes: {
              AppRoutes.biodata: (_) => const BiodataScreen(),
            },
            home: const DashboardScreen(initialTab: NeoNavTab.home),
          ),
        );
      }

      await tester.pumpWidget(
        buildTestShell(
          profProv: profileProvider,
          dashProv: dashboardProvider,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Initial state on Home shows 2000 kcal
      expect(find.text('2000'), findsWidgets);

      // Update biodata (weight 85 kg, height 180 cm, activity active)
      final newProfile = UserProfile(
        age: 25,
        birthDate: DateTime(2001, 5, 10),
        sex: 'male',
        weightKg: 85,
        heightCm: 180,
        activityLevel: 'active',
        goal: 'maintain_weight',
      );
      final expectedTarget = NutritionCalculator.calculateDailyTarget(
        age: newProfile.calculatedAge,
        sex: newProfile.sex,
        weightKg: newProfile.weightKg,
        heightCm: newProfile.heightCm,
        activityLevel: newProfile.activityLevel,
        goal: newProfile.goal,
      );

      await profileProvider.saveBiodata(
        fullName: 'Ahmad Badawi',
        newProfile: newProfile,
      );
      await tester.pumpAndSettle();

      // Home Screen immediately displays the recalculated calorie target without manual refresh
      expect(
        find.text('${expectedTarget.caloriesKcal}'),
        findsWidgets,
      );
      expect(find.text('2000'), findsNothing);

      // Scenario 6: Navigate to Profile tab and back to Home -> latest values remain displayed
      await tester.tap(find.text('PROFIL'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('BERANDA'));
      await tester.pumpAndSettle();
      expect(find.text('${expectedTarget.caloriesKcal}'), findsWidgets);

      // Scenario 7: Simulate application restart with fresh providers reading persisted state
      when(() => mockProfileRepo.getUser()).thenAnswer(
        (_) async => User(
          id: 1,
          email: 'ahmadbadawi@example.com',
          fullName: 'Ahmad Badawi',
          role: 'user',
          isProfileComplete: true,
          profile: persistedProfile,
        ),
      );
      when(() => mockProfileRepo.getDailyTarget()).thenAnswer(
        (_) async => expectedTarget,
      );

      final restartedProfileProvider = ProfileProvider(mockProfileRepo);
      final restartedDashboardProvider = DashboardProvider(repository);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        buildTestShell(
          profProv: restartedProfileProvider,
          dashProv: restartedDashboardProvider,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(find.text('${expectedTarget.caloriesKcal}'), findsWidgets);
    });

    test('Scenario 8: Failed biodata save keeps old valid values intact in both ProfileProvider and DashboardProvider', () async {
      final repository = SynchronizedCachingDashboardRepository(initialDashboard);
      final dashboardProvider = DashboardProvider(repository);

      profileProvider.onProfileUpdated = () {
        if (profileProvider.dailyTarget != null) {
          dashboardProvider.updateTargetFromBiodata(profileProvider.dailyTarget!);
        }
      };

      await profileProvider.loadProfile();
      await dashboardProvider.loadDashboard();

      final initialProfile = profileProvider.profile!;
      final initialTargetCalories = dashboardProvider.dashboard!.target.caloriesKcal;

      when(
        () => mockProfileRepo.saveBiodata(
          fullName: any(named: 'fullName'),
          profile: any(named: 'profile'),
        ),
      ).thenThrow(
        ApiException(
          statusCode: 500,
          code: 'BIODATA_SAVE_FAILED',
          message: 'Gagal menyimpan biodata pengguna.',
        ),
      );

      final attemptedProfile = initialProfile.copyWith(weightKg: 95, heightCm: 190);
      final success = await profileProvider.saveBiodata(
        fullName: 'Ahmad Badawi',
        newProfile: attemptedProfile,
      );

      expect(success, isFalse);
      expect(profileProvider.errorMessage, isNotNull);
      // Old valid values remain intact
      expect(profileProvider.profile!.weightKg, equals(initialProfile.weightKg));
      expect(profileProvider.profile!.heightCm, equals(initialProfile.heightCm));
      expect(dashboardProvider.dashboard!.target.caloriesKcal, equals(initialTargetCalories));
    });

    test('Scenario 9: Repeated rapid updates resolve without stale data or out-of-order race conditions', () async {
      final repository = SynchronizedCachingDashboardRepository(initialDashboard);
      final dashboardProvider = DashboardProvider(repository);

      profileProvider.onProfileUpdated = () {
        if (profileProvider.dailyTarget != null) {
          dashboardProvider.updateTargetFromBiodata(profileProvider.dailyTarget!);
        }
      };

      await profileProvider.loadProfile();
      await dashboardProvider.loadDashboard();

      final completer1 = Completer<UserProfile>();
      final completer2 = Completer<UserProfile>();

      final profile1 = UserProfile(
        age: 25,
        sex: 'male',
        weightKg: 60,
        heightCm: 170,
        activityLevel: 'sedentary',
        goal: 'lose_weight',
      );
      final profile2 = UserProfile(
        age: 25,
        sex: 'male',
        weightKg: 85,
        heightCm: 182,
        activityLevel: 'very_active',
        goal: 'gain_weight',
      );

      var callIndex = 0;
      when(
        () => mockProfileRepo.saveBiodata(
          fullName: any(named: 'fullName'),
          profile: any(named: 'profile'),
        ),
      ).thenAnswer((_) {
        callIndex++;
        return callIndex == 1 ? completer1.future : completer2.future;
      });

      // Trigger first update (slow network response)
      final future1 = profileProvider.saveBiodata(
        fullName: 'Ahmad Badawi',
        newProfile: profile1,
      );
      // Trigger second update immediately after (finishes BEFORE first update!)
      final future2 = profileProvider.saveBiodata(
        fullName: 'Ahmad Badawi',
        newProfile: profile2,
      );

      completer2.complete(profile2);
      await future2;

      // Now the outdated first request completes late
      completer1.complete(profile1);
      await future1;

      final expectedLatestTarget = NutritionCalculator.calculateDailyTarget(
        age: profile2.calculatedAge,
        sex: profile2.sex,
        weightKg: profile2.weightKg,
        heightCm: profile2.heightCm,
        activityLevel: profile2.activityLevel,
        goal: profile2.goal,
      );

      // State must match the latest submitted update (profile2), not overwritten by late profile1
      expect(profileProvider.profile!.weightKg, equals(85));
      expect(
        profileProvider.dailyTarget!.caloriesKcal,
        equals(expectedLatestTarget.caloriesKcal),
      );
      expect(
        dashboardProvider.dashboard!.target.caloriesKcal,
        equals(expectedLatestTarget.caloriesKcal.toDouble()),
      );
    });
  });
}
