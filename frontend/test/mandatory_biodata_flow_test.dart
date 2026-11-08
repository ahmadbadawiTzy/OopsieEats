import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:oopsieeats/core/routes.dart';
import 'package:oopsieeats/core/theme.dart';
import 'package:oopsieeats/data/models/dashboard.dart';
import 'package:oopsieeats/data/models/meal.dart';
import 'package:oopsieeats/data/models/profile.dart';
import 'package:oopsieeats/data/models/user.dart';
import 'package:oopsieeats/data/repositories/auth_repository.dart';
import 'package:oopsieeats/data/repositories/profile_repository.dart';
import 'package:oopsieeats/data/repositories/dashboard_repository.dart';
import 'package:oopsieeats/features/auth/providers/auth_provider.dart';
import 'package:oopsieeats/features/auth/screens/complete_profile_screen.dart';
import 'package:oopsieeats/features/dashboard/providers/dashboard_provider.dart';
import 'package:oopsieeats/features/profile/providers/profile_provider.dart';
import 'package:oopsieeats/shared/neo/neo_button.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(UserProfile(
      age: 25,
      sex: 'male',
      weightKg: 70,
      heightCm: 175,
      activityLevel: 'moderate',
      goal: 'maintain',
      profession: 'Umum',
    ));
    registerFallbackValue(DateTime.now());
  });

  group('1. User Model & Profile Completion Logic', () {
    test('User defaults isProfileComplete to false when not provided', () {
      final user = User(
        id: 1,
        email: 'test@nutriview.id',
        fullName: 'Test User',
      );
      expect(user.isProfileComplete, isFalse);
      expect(user.hasCompleteProfile, isFalse);
    });

    test('User.fromJson deserializes is_profile_complete boolean correctly', () {
      final jsonComplete = {
        'id': 1,
        'email': 'user@nutriview.id',
        'full_name': 'Complete User',
        'is_profile_complete': true,
      };
      final userComplete = User.fromJson(jsonComplete);
      expect(userComplete.isProfileComplete, isTrue);

      final jsonIncomplete = {
        'id': 2,
        'email': 'new@nutriview.id',
        'full_name': 'Incomplete User',
        'is_profile_complete': false,
      };
      final userIncomplete = User.fromJson(jsonIncomplete);
      expect(userIncomplete.isProfileComplete, isFalse);
    });

    test('User.fromJson computes isProfileComplete via physical metrics fallback when key is missing', () {
      // Legacy document without is_profile_complete flag, but with complete profile
      final jsonLegacyComplete = {
        'id': 3,
        'email': 'legacy@nutriview.id',
        'full_name': 'Legacy User',
        'profile': {
          'age': 28,
          'sex': 'male',
          'height_cm': 175.0,
          'weight_kg': 70.0,
          'activity_level': 'moderate',
          'goal': 'maintain',
        },
      };
      final user = User.fromJson(jsonLegacyComplete);
      expect(user.isProfileComplete, isTrue);

      // Legacy document with empty profile metrics
      final jsonLegacyIncomplete = {
        'id': 4,
        'email': 'legacy_incomplete@nutriview.id',
        'full_name': 'Incomplete Legacy',
        'profile': {
          'age': 0,
          'sex': '',
          'height_cm': 0.0,
          'weight_kg': 0.0,
          'activity_level': '',
          'goal': '',
        },
      };
      final userIncomplete = User.fromJson(jsonLegacyIncomplete);
      expect(userIncomplete.isProfileComplete, isFalse);
    });

    test('User.copyWith properly updates isProfileComplete', () {
      final user = User(
        id: 1,
        email: 'user@nutriview.id',
        fullName: 'Original User',
        isProfileComplete: false,
      );

      final updated = user.copyWith(isProfileComplete: true);
      expect(updated.isProfileComplete, isTrue);
      expect(updated.fullName, 'Original User');
    });
  });

  group('2. ProfileProvider Profile Completion State Evaluation', () {
    late MockProfileRepository mockProfileRepo;
    late ProfileProvider profileProvider;

    setUp(() {
      mockProfileRepo = MockProfileRepository();
      profileProvider = ProfileProvider(mockProfileRepo);
    });

    test('isProfileComplete returns false when user is not loaded', () {
      expect(profileProvider.isProfileComplete, isFalse);
    });

    test('isProfileComplete evaluates required physical biodata thresholds', () async {
      // When profile has partial/invalid measurements
      when(() => mockProfileRepo.getUser()).thenAnswer((_) async => User(
        id: 1,
        email: 'test@nutriview.id',
        fullName: 'Partial User',
        profile: UserProfile(
          age: 0,
          sex: '',
          weightKg: 10, // below 20kg threshold
          heightCm: 40, // below 50cm threshold
          activityLevel: '',
          goal: 'maintain',
        ),
      ));
      when(() => mockProfileRepo.getDailyTarget()).thenAnswer((_) async => DailyTarget(
        caloriesKcal: 2000,
        proteinG: 75,
        carbsG: 250,
        fatG: 50,
        bmrKcal: 1500,
        tdeeKcal: 2000,
      ));

      await profileProvider.loadProfile();
      expect(profileProvider.isProfileComplete, isFalse);

      // When profile meets all physical thresholds
      when(() => mockProfileRepo.getUser()).thenAnswer((_) async => User(
        id: 1,
        email: 'test@nutriview.id',
        fullName: 'Valid User',
        profile: UserProfile(
          age: 26,
          sex: 'female',
          weightKg: 55,
          heightCm: 162,
          activityLevel: 'light',
          goal: 'maintain',
        ),
      ));

      await profileProvider.loadProfile();
      expect(profileProvider.isProfileComplete, isTrue);
    });
  });

  group('3. Global Route Guard & Mandatory Onboarding Interception', () {
    late MockAuthRepository mockAuthRepo;
    late AuthProvider authProvider;

    setUp(() {
      mockAuthRepo = MockAuthRepository();
      when(() => mockAuthRepo.isBiometricAvailable()).thenAnswer((_) async => false);
      when(() => mockAuthRepo.getAvailableBiometrics()).thenAnswer((_) async => []);
      when(() => mockAuthRepo.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockAuthRepo.hasPromptedBiometric()).thenAnswer((_) async => false);
      authProvider = AuthProvider(mockAuthRepo);
    });

    Widget createGuardedApp({required String initialRoute}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: MaterialApp(
          initialRoute: initialRoute,
          onGenerateRoute: (settings) {
            final auth = authProvider;

            final isProtectedFeature = settings.name == AppRoutes.dashboard ||
                settings.name == AppRoutes.articles ||
                settings.name == AppRoutes.profile ||
                settings.name == AppRoutes.scanner ||
                settings.name == AppRoutes.detectionConfirm ||
                settings.name == AppRoutes.portionInput ||
                settings.name == AppRoutes.mealResult ||
                settings.name == AppRoutes.mealHistory ||
                settings.name == AppRoutes.mealDetail;

            if (auth.isLoggedIn &&
                !auth.isAdmin &&
                !auth.isProfileComplete &&
                isProtectedFeature) {
              return MaterialPageRoute(
                settings: const RouteSettings(name: AppRoutes.completeProfile),
                builder: (_) => const Scaffold(body: Text('GUARDED_COMPLETE_PROFILE_SCREEN')),
              );
            }

            switch (settings.name) {
              case AppRoutes.dashboard:
                return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('DASHBOARD_SCREEN')));
              case AppRoutes.scanner:
                return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('SCANNER_SCREEN')));
              case AppRoutes.mealHistory:
                return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('MEAL_HISTORY_SCREEN')));
              case AppRoutes.completeProfile:
                return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('COMPLETE_PROFILE_SCREEN')));
              case AppRoutes.adminDashboard:
                return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('ADMIN_DASHBOARD_SCREEN')));
              default:
                return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('UNKNOWN_SCREEN')));
            }
          },
        ),
      );
    }

    testWidgets('intercepts access to Dashboard when authenticated user profile is incomplete', (tester) async {
      authProvider.setCurrentUser(User(
        id: 10,
        email: 'incomplete@nutriview.id',
        fullName: 'Incomplete User',
        role: 'user',
        isProfileComplete: false,
      ));

      await tester.pumpWidget(createGuardedApp(initialRoute: AppRoutes.dashboard));
      await tester.pumpAndSettle();

      expect(find.text('GUARDED_COMPLETE_PROFILE_SCREEN'), findsOneWidget);
      expect(find.text('DASHBOARD_SCREEN'), findsNothing);
    });

    testWidgets('intercepts access to Scanner when user profile is incomplete', (tester) async {
      authProvider.setCurrentUser(User(
        id: 11,
        email: 'scanner_user@nutriview.id',
        fullName: 'Scanner Test User',
        role: 'user',
        isProfileComplete: false,
      ));

      await tester.pumpWidget(createGuardedApp(initialRoute: AppRoutes.scanner));
      await tester.pumpAndSettle();

      expect(find.text('GUARDED_COMPLETE_PROFILE_SCREEN'), findsOneWidget);
      expect(find.text('SCANNER_SCREEN'), findsNothing);
    });

    testWidgets('allows access to Dashboard when user profile is complete', (tester) async {
      authProvider.setCurrentUser(User(
        id: 12,
        email: 'complete@nutriview.id',
        fullName: 'Complete Test User',
        role: 'user',
        isProfileComplete: true,
      ));

      await tester.pumpWidget(createGuardedApp(initialRoute: AppRoutes.dashboard));
      await tester.pumpAndSettle();

      expect(find.text('DASHBOARD_SCREEN'), findsOneWidget);
      expect(find.text('GUARDED_COMPLETE_PROFILE_SCREEN'), findsNothing);
    });

    testWidgets('allows admin users access to admin screens regardless of biodata', (tester) async {
      authProvider.setCurrentUser(User(
        id: 1,
        email: 'admin@nutriview.id',
        fullName: 'Admin User',
        role: 'admin',
        isProfileComplete: false,
      ));

      await tester.pumpWidget(createGuardedApp(initialRoute: AppRoutes.adminDashboard));
      await tester.pumpAndSettle();

      expect(find.text('ADMIN_DASHBOARD_SCREEN'), findsOneWidget);
    });
  });

  group('4. CompleteProfileScreen UI & Backstack Guard', () {
    late MockAuthRepository mockAuthRepo;
    late MockProfileRepository mockProfileRepo;
    late MockDashboardRepository mockDashboardRepo;
    late AuthProvider authProvider;
    late ProfileProvider profileProvider;
    late DashboardProvider dashboardProvider;

    setUp(() {
      mockAuthRepo = MockAuthRepository();
      mockProfileRepo = MockProfileRepository();
      mockDashboardRepo = MockDashboardRepository();

      when(() => mockAuthRepo.isBiometricAvailable()).thenAnswer((_) async => false);
      when(() => mockAuthRepo.getAvailableBiometrics()).thenAnswer((_) async => []);
      when(() => mockAuthRepo.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockAuthRepo.hasPromptedBiometric()).thenAnswer((_) async => false);

      authProvider = AuthProvider(mockAuthRepo);
      profileProvider = ProfileProvider(mockProfileRepo);
      dashboardProvider = DashboardProvider(mockDashboardRepo);

      authProvider.setCurrentUser(User(
        id: 99,
        email: 'newuser@nutriview.id',
        fullName: 'Budi Santoso',
        role: 'user',
        isProfileComplete: false,
      ));
    });

    Widget wrapCompleteProfileScreen() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<ProfileProvider>.value(value: profileProvider),
          ChangeNotifierProvider<DashboardProvider>.value(value: dashboardProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CompleteProfileScreen(),
          routes: {
            AppRoutes.dashboard: (_) => const Scaffold(body: Text('DASHBOARD_SCREEN')),
            AppRoutes.login: (_) => const Scaffold(body: Text('LOGIN_SCREEN')),
          },
        ),
      );
    }

    testWidgets('renders all mandatory fields, badges, and zero emojis', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapCompleteProfileScreen());
      await tester.pumpAndSettle();

      // Header and description
      expect(find.text('Lengkapi Profil Fisik'), findsOneWidget);
      expect(find.text('Satu Langkah Terakhir!'), findsOneWidget);
      expect(
        find.text(
          'Profil ini wajib dilengkapi sebelum masuk ke dashboard agar analisis gizi tidak bias atau kosong.',
        ),
        findsOneWidget,
      );

      // Pre-filled name and email display
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Akun: newuser@nutriview.id'), findsOneWidget);

      // Section labels
      expect(find.text('Jenis Kelamin'), findsOneWidget);
      expect(find.text('Tanggal Lahir'), findsOneWidget);
      expect(find.text('Tinggi Badan (cm)'), findsOneWidget);
      expect(find.text('Berat Badan (kg)'), findsOneWidget);
      expect(find.text('Tingkat Aktivitas Fisik'), findsOneWidget);
      expect(find.text('Target Gizi & Berat Badan'), findsOneWidget);

      // Save button
      expect(find.widgetWithText(NeoButton, 'Simpan & Lanjutkan'), findsOneWidget);

      // Back navigation lock: PopScope with canPop: false
      final popScopeFinder = find.byWidgetPredicate(
        (widget) => widget is PopScope && widget.canPop == false,
      );
      expect(popScopeFinder, findsOneWidget);
    });

    testWidgets('validation fails on invalid height or weight values', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapCompleteProfileScreen());
      await tester.pumpAndSettle();

      // Enter invalid height
      final textFields = find.byType(TextFormField);
      // Index 0: name, Index 1: height, Index 2: weight
      await tester.enterText(textFields.at(1), '10'); // below 100cm
      await tester.enterText(textFields.at(2), '5');  // below 30kg

      final submitBtn = find.widgetWithText(NeoButton, 'Simpan & Lanjutkan');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Validation errors should appear
      expect(find.text('100 - 250 cm'), findsOneWidget);
      expect(find.text('30 - 300 kg'), findsOneWidget);

      // Repository saveBiodata should not be called
      verifyNever(() => mockProfileRepo.saveBiodata(
        fullName: any(named: 'fullName'),
        profile: any(named: 'profile'),
      ));
    });

    testWidgets('successful profile completion saves biodata, updates auth state, and navigates to dashboard', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final savedProfile = UserProfile(
        age: 25,
        birthDate: DateTime(2001, 1, 1),
        sex: 'male',
        weightKg: 68,
        heightCm: 172,
        activityLevel: 'moderate',
        goal: 'maintain',
        profession: 'Umum',
      );

      when(() => mockProfileRepo.saveBiodata(
        fullName: any(named: 'fullName'),
        profile: any(named: 'profile'),
      )).thenAnswer((_) async => savedProfile);

      when(() => mockProfileRepo.getUser()).thenAnswer((_) async => User(
        id: 99,
        email: 'newuser@nutriview.id',
        fullName: 'Budi Santoso',
        role: 'user',
        isProfileComplete: true,
        profile: savedProfile,
      ));

      when(() => mockProfileRepo.getDailyTarget()).thenAnswer((_) async => DailyTarget(
        caloriesKcal: 2100,
        proteinG: 80,
        carbsG: 260,
        fatG: 55,
        bmrKcal: 1550,
        tdeeKcal: 2100,
      ));

      when(() => mockDashboardRepo.getDailyDashboard(any()))
          .thenAnswer((_) async => DailyDashboard(
            date: '2026-11-07',
            mealCount: 0,
            target: MealNutritionTotals(caloriesKcal: 2100, proteinG: 80, carbsG: 260, fatG: 55),
            consumed: MealNutritionTotals(caloriesKcal: 0, proteinG: 0, carbsG: 0, fatG: 0),
            progress: DashboardProgress(
              calories: NutrientProgress(consumed: 0, target: 2100, percentage: 0),
              protein: NutrientProgress(consumed: 0, target: 80, percentage: 0),
              carbs: NutrientProgress(consumed: 0, target: 260, percentage: 0),
              fat: NutrientProgress(consumed: 0, target: 55, percentage: 0),
            ),
          ));

      await tester.pumpWidget(wrapCompleteProfileScreen());
      await tester.pumpAndSettle();

      // Pick birth date by finding the date card tap target
      final datePickerCard = find.text('Pilih tanggal lahir');
      await tester.ensureVisible(datePickerCard);
      await tester.tap(datePickerCard);
      await tester.pumpAndSettle();

      // Tap 'PILIH' on DatePicker dialog
      final pilihBtn = find.text('PILIH');
      expect(pilihBtn, findsOneWidget);
      await tester.tap(pilihBtn);
      await tester.pumpAndSettle();

      // Enter valid height & weight
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(1), '172');
      await tester.enterText(textFields.at(2), '68');

      // Tap submit button
      final submitBtn = find.widgetWithText(NeoButton, 'Simpan & Lanjutkan');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Verify repository was called with correct data
      verify(() => mockProfileRepo.saveBiodata(
        fullName: 'Budi Santoso',
        profile: any(named: 'profile'),
      )).called(1);

      // Verify AuthProvider synchronized isProfileComplete
      expect(authProvider.isProfileComplete, isTrue);

      // Verify navigated to Dashboard
      expect(find.text('DASHBOARD_SCREEN'), findsOneWidget);
      expect(find.byType(CompleteProfileScreen), findsNothing);
    });
  });
}
