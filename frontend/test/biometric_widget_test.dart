import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/data/models/profile.dart';
import 'package:nutriview/data/models/user.dart';
import 'package:nutriview/data/repositories/auth_repository.dart';
import 'package:nutriview/data/repositories/dashboard_repository.dart';
import 'package:nutriview/data/repositories/meal_repository.dart';
import 'package:nutriview/data/repositories/profile_repository.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/features/auth/screens/login_screen.dart';
import 'package:nutriview/features/auth/widgets/biometric_enrollment_modal.dart';
import 'package:nutriview/features/dashboard/providers/dashboard_provider.dart';
import 'package:nutriview/features/meals/providers/meal_history_provider.dart';
import 'package:nutriview/features/profile/providers/profile_provider.dart';
import 'package:nutriview/features/profile/screens/profile_screen.dart';
import 'package:nutriview/shared/neo/neo_button.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockMealRepository extends Mock implements MealRepository {}

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Biometric UI Widget Tests - LoginScreen & States', () {
    late MockAuthRepository mockAuthRepo;
    late AuthProvider authProvider;

    setUp(() {
      mockAuthRepo = MockAuthRepository();
      when(() => mockAuthRepo.getSignInProviders()).thenReturn(['password']);
      when(() => mockAuthRepo.hasPasswordProvider()).thenReturn(true);
      when(() => mockAuthRepo.hasGoogleProvider()).thenReturn(false);
      when(() => mockAuthRepo.getPrimaryProviderId()).thenReturn('password');
      authProvider = AuthProvider(mockAuthRepo);
    });

    Widget wrapLogin(Widget child) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: child,
          routes: {
            AppRoutes.dashboard: (_) =>
                const Scaffold(body: Text('DASHBOARD_SCREEN')),
            AppRoutes.completeProfile: (_) =>
                const Scaffold(body: Text('COMPLETE_PROFILE_SCREEN')),
            AppRoutes.adminDashboard: (_) =>
                const Scaffold(body: Text('ADMIN_DASHBOARD_SCREEN')),
          },
        ),
      );
    }

    testWidgets(
      'renders Biometric Locked card with user greeting and password fallback when biometric is locked',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => true);
        when(() => mockAuthRepo.getRole()).thenAnswer((_) async => 'user');
        when(() => mockAuthRepo.getUserName())
            .thenAnswer((_) async => 'Budi Santoso');
        when(() => mockAuthRepo.getUserEmail())
            .thenAnswer((_) async => 'budi@nutriview.com');
        when(() => mockAuthRepo.isBiometricAvailable())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.getAvailableBiometrics())
            .thenAnswer((_) async => [BiometricType.fingerprint]);
        when(() => mockAuthRepo.isBiometricEnabled())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.hasPromptedBiometric())
            .thenAnswer((_) async => true);

        await authProvider.checkAuthStatus();
        expect(authProvider.isBiometricLocked, isTrue);

        await tester.pumpWidget(wrapLogin(const LoginScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Selamat Datang Kembali'), findsOneWidget);
        expect(find.text('Budi Santoso'), findsOneWidget);
        expect(
          find.widgetWithText(NeoButton, 'Buka dengan Sidik Jari'),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(NeoButton, 'Gunakan Kata Sandi'),
          findsOneWidget,
        );
        expect(find.byKey(const Key('switch_account_button')), findsOneWidget);
        // Verify normal login form and registration CTA are completely hidden
        expect(find.byType(TextFormField), findsNothing);
        expect(find.text('Belum punya akun? '), findsNothing);
        expect(find.text('Lanjutkan dengan Google'), findsNothing);
      },
    );

    testWidgets(
      'tapping Biometric Unlock button signs in and navigates to dashboard',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => true);
        when(() => mockAuthRepo.getRole()).thenAnswer((_) async => 'user');
        when(() => mockAuthRepo.getUserName())
            .thenAnswer((_) async => 'Budi Santoso');
        when(() => mockAuthRepo.getUserEmail())
            .thenAnswer((_) async => 'budi@nutriview.com');
        when(() => mockAuthRepo.isBiometricAvailable())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.getAvailableBiometrics())
            .thenAnswer((_) async => [BiometricType.fingerprint]);
        when(() => mockAuthRepo.isBiometricEnabled())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.hasPromptedBiometric())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.authenticateWithBiometrics()).thenAnswer(
          (_) async => User(
            id: 1,
            email: 'budi@nutriview.com',
            fullName: 'Budi Santoso',
            role: 'user',
            isProfileComplete: true,
          ),
        );

        await authProvider.checkAuthStatus();
        await tester.pumpWidget(wrapLogin(const LoginScreen()));
        await tester.pumpAndSettle();

        final bioBtn = find.widgetWithText(NeoButton, 'Buka dengan Sidik Jari');
        await tester.ensureVisible(bioBtn);
        await tester.tap(bioBtn);
        await tester.pumpAndSettle();

        expect(find.text('DASHBOARD_SCREEN'), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      },
    );

    testWidgets(
      'when lifecycleState is authenticated, LoginScreen renders transition card and never renders normal login form',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => true);
        when(() => mockAuthRepo.getRole()).thenAnswer((_) async => 'user');
        when(() => mockAuthRepo.getUserName())
            .thenAnswer((_) async => 'Budi Santoso');
        when(() => mockAuthRepo.getUserEmail())
            .thenAnswer((_) async => 'budi@nutriview.com');
        when(() => mockAuthRepo.isBiometricAvailable())
            .thenAnswer((_) async => false);

        authProvider.setCurrentUser(User(
          id: 1,
          email: 'budi@nutriview.com',
          fullName: 'Budi Santoso',
          role: 'user',
          isProfileComplete: true,
        ));

        await authProvider.checkAuthStatus();
        expect(authProvider.lifecycleState, AuthLifecycleState.authenticated);

        await tester.pumpWidget(wrapLogin(const LoginScreen()));
        // Pump one frame before post-frame callback navigates
        await tester.pump();

        // Must display authenticated transition card
        expect(
          find.byKey(const Key('authenticated_transition_card')),
          findsOneWidget,
        );
        expect(find.text('TERVERIFIKASI'), findsOneWidget);
        expect(find.text('Memuat Beranda...'), findsOneWidget);

        // Crucial regression verification: zero login form, zero textfields, zero registration
        expect(find.text('Masuk ke Akun'), findsNothing);
        expect(find.byType(TextFormField), findsNothing);
        expect(find.text('Belum punya akun? '), findsNothing);
        expect(find.text('Lanjutkan dengan Google'), findsNothing);

        // After post-frame settles, it routes to dashboard
        await tester.pumpAndSettle();
        expect(find.text('DASHBOARD_SCREEN'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping password fallback switches from biometricLocked to standard login form with return shortcut',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => true);
        when(() => mockAuthRepo.getRole()).thenAnswer((_) async => 'user');
        when(() => mockAuthRepo.getUserName())
            .thenAnswer((_) async => 'Budi Santoso');
        when(() => mockAuthRepo.getUserEmail())
            .thenAnswer((_) async => 'budi@nutriview.com');
        when(() => mockAuthRepo.isBiometricAvailable())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.getAvailableBiometrics())
            .thenAnswer((_) async => [BiometricType.fingerprint]);
        when(() => mockAuthRepo.isBiometricEnabled())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.hasPromptedBiometric())
            .thenAnswer((_) async => true);

        await authProvider.checkAuthStatus();
        await tester.pumpWidget(wrapLogin(const LoginScreen()));
        await tester.pumpAndSettle();

        final fallbackBtn = find.widgetWithText(
          NeoButton,
          'Gunakan Kata Sandi',
        );
        await tester.ensureVisible(fallbackBtn);
        await tester.tap(fallbackBtn);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('password_fallback_card')), findsOneWidget);
        expect(find.text('Buka dengan Kata Sandi'), findsOneWidget);
        expect(find.text('budi@nutriview.com'), findsOneWidget);
        expect(find.text('SESI AKTIF'), findsOneWidget);
        expect(find.byKey(const Key('fallback_password_field')), findsOneWidget);
        expect(
          find.byKey(const Key('verify_fallback_password_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('return_to_biometric_button')),
          findsOneWidget,
        );
        // Ensure no generic login or registration leak
        expect(find.text('Masuk ke Akun'), findsNothing);
        expect(find.text('Belum punya akun? '), findsNothing);
        expect(find.text('Lanjutkan dengan Google'), findsNothing);

        // Tapping return to biometric shortcut returns to locked view
        await tester.tap(find.byKey(const Key('return_to_biometric_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('biometric_locked_card')), findsOneWidget);
        expect(find.text('Selamat Datang Kembali'), findsOneWidget);
        expect(find.byType(TextFormField), findsNothing);
      },
    );

    testWidgets(
      'renders Google fallback button instead of password button when account is Google-only',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        when(() => mockAuthRepo.getSignInProviders()).thenReturn(['google.com']);
        when(() => mockAuthRepo.hasPasswordProvider()).thenReturn(false);
        when(() => mockAuthRepo.hasGoogleProvider()).thenReturn(true);
        when(() => mockAuthRepo.getPrimaryProviderId()).thenReturn('google.com');

        when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => true);
        when(() => mockAuthRepo.getRole()).thenAnswer((_) async => 'user');
        when(() => mockAuthRepo.getUserName())
            .thenAnswer((_) async => 'Google User');
        when(() => mockAuthRepo.getUserEmail())
            .thenAnswer((_) async => 'googleuser@gmail.com');
        when(() => mockAuthRepo.isBiometricAvailable())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.getAvailableBiometrics())
            .thenAnswer((_) async => [BiometricType.fingerprint]);
        when(() => mockAuthRepo.isBiometricEnabled())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.hasPromptedBiometric())
            .thenAnswer((_) async => true);

        await authProvider.checkAuthStatus();
        await tester.pumpWidget(wrapLogin(const LoginScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Selamat Datang Kembali'), findsOneWidget);
        expect(find.text('Google User'), findsOneWidget);

        // Crucial verification: Google fallback button rendered, password button NOT rendered!
        expect(
          find.byKey(const Key('google_fallback_button')),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(NeoButton, 'Masuk dengan Akun Google'),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('password_fallback_button')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'submitting valid password in password fallback unlocks session and navigates to dashboard',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => true);
        when(() => mockAuthRepo.getRole()).thenAnswer((_) async => 'user');
        when(() => mockAuthRepo.getUserName())
            .thenAnswer((_) async => 'Budi Santoso');
        when(() => mockAuthRepo.getUserEmail())
            .thenAnswer((_) async => 'budi@nutriview.com');
        when(() => mockAuthRepo.isBiometricAvailable())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.getAvailableBiometrics())
            .thenAnswer((_) async => [BiometricType.fingerprint]);
        when(() => mockAuthRepo.isBiometricEnabled())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.hasPromptedBiometric())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.verifyPasswordFallback('correct_password'))
            .thenAnswer(
          (_) async => User(
            id: 1,
            email: 'budi@nutriview.com',
            fullName: 'Budi Santoso',
            role: 'user',
            isProfileComplete: true,
          ),
        );

        await authProvider.checkAuthStatus();
        await tester.pumpWidget(wrapLogin(const LoginScreen()));
        await tester.pumpAndSettle();

        // Switch to password fallback
        final fallbackBtn = find.widgetWithText(
          NeoButton,
          'Gunakan Kata Sandi',
        );
        await tester.ensureVisible(fallbackBtn);
        await tester.tap(fallbackBtn);
        await tester.pumpAndSettle();

        // Enter password
        await tester.enterText(
          find.byKey(const Key('fallback_password_field')),
          'correct_password',
        );
        final verifyBtn = find.byKey(const Key('verify_fallback_password_button'));
        await tester.ensureVisible(verifyBtn);
        await tester.tap(verifyBtn);
        await tester.pumpAndSettle();

        expect(find.text('DASHBOARD_SCREEN'), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      },
    );

    testWidgets(
      'submitting wrong password in password fallback stays on card and displays error',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => true);
        when(() => mockAuthRepo.getRole()).thenAnswer((_) async => 'user');
        when(() => mockAuthRepo.getUserName())
            .thenAnswer((_) async => 'Budi Santoso');
        when(() => mockAuthRepo.getUserEmail())
            .thenAnswer((_) async => 'budi@nutriview.com');
        when(() => mockAuthRepo.isBiometricAvailable())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.getAvailableBiometrics())
            .thenAnswer((_) async => [BiometricType.fingerprint]);
        when(() => mockAuthRepo.isBiometricEnabled())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.hasPromptedBiometric())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.verifyPasswordFallback('wrong_pass')).thenThrow(
          ApiException(
            statusCode: 401,
            code: 'WRONG_PASSWORD',
            message: 'Kata sandi salah. Silakan coba lagi.',
          ),
        );

        await authProvider.checkAuthStatus();
        await tester.pumpWidget(wrapLogin(const LoginScreen()));
        await tester.pumpAndSettle();

        // Switch to password fallback
        final fallbackBtn = find.widgetWithText(
          NeoButton,
          'Gunakan Kata Sandi',
        );
        await tester.ensureVisible(fallbackBtn);
        await tester.tap(fallbackBtn);
        await tester.pumpAndSettle();

        // Enter wrong password
        await tester.enterText(
          find.byKey(const Key('fallback_password_field')),
          'wrong_pass',
        );
        final verifyBtn = find.byKey(const Key('verify_fallback_password_button'));
        await tester.ensureVisible(verifyBtn);
        await tester.tap(verifyBtn);
        await tester.pumpAndSettle();

        // Remains on fallback card and displays error
        expect(find.byKey(const Key('password_fallback_card')), findsOneWidget);
        expect(find.text('Kata sandi salah. Silakan coba lagi.'), findsOneWidget);
        expect(find.text('DASHBOARD_SCREEN'), findsNothing);
      },
    );

    testWidgets(
      'account switch dialog can be cancelled or confirmed safely clearing previous session',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => true);
        when(() => mockAuthRepo.getRole()).thenAnswer((_) async => 'user');
        when(() => mockAuthRepo.getUserName())
            .thenAnswer((_) async => 'Budi Santoso');
        when(() => mockAuthRepo.getUserEmail())
            .thenAnswer((_) async => 'budi@nutriview.com');
        when(() => mockAuthRepo.isBiometricAvailable())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.getAvailableBiometrics())
            .thenAnswer((_) async => [BiometricType.fingerprint]);
        when(() => mockAuthRepo.isBiometricEnabled())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.hasPromptedBiometric())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.logout()).thenAnswer((_) async {});

        await authProvider.checkAuthStatus();
        await tester.pumpWidget(wrapLogin(const LoginScreen()));
        await tester.pumpAndSettle();

        // Tap Ganti Akun -> Dialog appears
        await tester.tap(find.byKey(const Key('switch_account_button')));
        await tester.pumpAndSettle();

        expect(find.text('Ganti Akun?'), findsOneWidget);
        expect(find.text('Batal'), findsOneWidget);

        // Cancel -> Dialog closes, user remains in locked state
        await tester.tap(find.text('Batal'));
        await tester.pumpAndSettle();

        expect(find.text('Ganti Akun?'), findsNothing);
        expect(find.text('Selamat Datang Kembali'), findsOneWidget);
        verifyNever(() => mockAuthRepo.logout());

        // Tap Ganti Akun -> Confirm
        await tester.tap(find.byKey(const Key('switch_account_button')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ya, Ganti Akun'));
        await tester.pumpAndSettle();

        verify(() => mockAuthRepo.logout()).called(1);
        expect(find.text('Masuk ke Akun'), findsOneWidget);
        expect(find.byKey(const Key('return_to_biometric_card')), findsNothing);
      },
    );

    testWidgets(
      'renders clean standard login form on first launch without biometric button or dead ends',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => false);
        when(() => mockAuthRepo.isBiometricAvailable())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.getAvailableBiometrics())
            .thenAnswer((_) async => [BiometricType.fingerprint]);
        when(() => mockAuthRepo.isBiometricEnabled())
            .thenAnswer((_) async => false);
        when(() => mockAuthRepo.hasPromptedBiometric())
            .thenAnswer((_) async => false);

        await authProvider.checkAuthStatus();
        await tester.pumpWidget(wrapLogin(const LoginScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Masuk ke Akun'), findsOneWidget);
        expect(find.widgetWithText(NeoButton, 'Masuk'), findsOneWidget);
        expect(find.text('Buka dengan Sidik Jari'), findsNothing);
        expect(find.text('Selamat Datang Kembali'), findsNothing);
        expect(find.byKey(const Key('return_to_biometric_card')), findsNothing);
        expect(find.text('Belum punya akun? '), findsOneWidget);
      },
    );

    testWidgets(
      'failed or canceled biometric attempts keep user in locked state without loop or form leakage',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => true);
        when(() => mockAuthRepo.getRole()).thenAnswer((_) async => 'user');
        when(() => mockAuthRepo.getUserName())
            .thenAnswer((_) async => 'Budi Santoso');
        when(() => mockAuthRepo.getUserEmail())
            .thenAnswer((_) async => 'budi@nutriview.com');
        when(() => mockAuthRepo.isBiometricAvailable())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.getAvailableBiometrics())
            .thenAnswer((_) async => [BiometricType.fingerprint]);
        when(() => mockAuthRepo.isBiometricEnabled())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.hasPromptedBiometric())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepo.authenticateWithBiometrics()).thenThrow(
          ApiException(
            statusCode: 400,
            code: 'BIOMETRIC_CANCELLED',
            message: 'Cancelled by user',
          ),
        );

        await authProvider.checkAuthStatus();
        await tester.pumpWidget(wrapLogin(const LoginScreen()));
        await tester.pumpAndSettle();

        final bioBtn = find.widgetWithText(NeoButton, 'Buka dengan Sidik Jari');
        await tester.tap(bioBtn);
        await tester.pumpAndSettle();

        // Stays in locked view quietly without showing normal login form
        expect(find.text('Selamat Datang Kembali'), findsOneWidget);
        expect(find.byType(TextFormField), findsNothing);
      },
    );
  });

  group('Biometric UI Widget Tests - BiometricEnrollmentModal', () {
    late MockAuthRepository mockAuthRepo;
    late AuthProvider authProvider;

    setUp(() {
      mockAuthRepo = MockAuthRepository();
      authProvider = AuthProvider(mockAuthRepo);
    });

    Widget wrapModal(Widget child) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: child),
        ),
      );
    }

    testWidgets('renders enrollment modal title and options correctly', (
      tester,
    ) async {
      when(() => mockAuthRepo.isBiometricAvailable())
          .thenAnswer((_) async => true);
      when(() => mockAuthRepo.getAvailableBiometrics())
          .thenAnswer((_) async => [BiometricType.fingerprint]);
      when(() => mockAuthRepo.isBiometricEnabled())
          .thenAnswer((_) async => false);

      await authProvider.checkBiometricAvailability();

      await tester.pumpWidget(
        wrapModal(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => BiometricEnrollmentModal.show(ctx),
              child: const Text('OPEN_MODAL'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('OPEN_MODAL'));
      await tester.pumpAndSettle();

      expect(find.text('Aktifkan login biometrik'), findsOneWidget);
      expect(
        find.widgetWithText(NeoButton, 'Aktifkan Biometrik'),
        findsOneWidget,
      );
      expect(find.text('Nanti Saja'), findsOneWidget);
    });

    testWidgets('tapping Aktifkan Biometrik calls setBiometricEnabled(true)', (
      tester,
    ) async {
      when(() => mockAuthRepo.isBiometricAvailable())
          .thenAnswer((_) async => true);
      when(() => mockAuthRepo.getAvailableBiometrics())
          .thenAnswer((_) async => [BiometricType.fingerprint]);
      when(() => mockAuthRepo.isBiometricEnabled())
          .thenAnswer((_) async => false);
      when(() => mockAuthRepo.setBiometricEnabled(true))
          .thenAnswer((_) async {});

      await authProvider.checkBiometricAvailability();

      await tester.pumpWidget(
        wrapModal(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => BiometricEnrollmentModal.show(ctx),
              child: const Text('OPEN_MODAL'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('OPEN_MODAL'));
      await tester.pumpAndSettle();

      final enrollBtn = find.widgetWithText(NeoButton, 'Aktifkan Biometrik');
      await tester.tap(enrollBtn);
      await tester.pumpAndSettle();

      verify(() => mockAuthRepo.setBiometricEnabled(true)).called(1);
    });
  });

  group('Biometric UI Widget Tests - ProfileScreen', () {
    late MockAuthRepository mockAuthRepo;
    late MockProfileRepository mockProfileRepo;
    late MockMealRepository mockMealRepo;
    late MockDashboardRepository mockDashboardRepo;
    late AuthProvider authProvider;
    late ProfileProvider profileProvider;

    setUp(() {
      mockAuthRepo = MockAuthRepository();
      mockProfileRepo = MockProfileRepository();
      mockMealRepo = MockMealRepository();
      mockDashboardRepo = MockDashboardRepository();

      authProvider = AuthProvider(mockAuthRepo);
      profileProvider = ProfileProvider(mockProfileRepo);
    });

    Widget wrapProfile(Widget child) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<ProfileProvider>.value(value: profileProvider),
          ChangeNotifierProvider<MealHistoryProvider>(
            create: (_) => MealHistoryProvider(mockMealRepo),
          ),
          ChangeNotifierProvider<DashboardProvider>(
            create: (_) => DashboardProvider(mockDashboardRepo),
          ),
        ],
        child: MaterialApp(theme: AppTheme.lightTheme, home: child),
      );
    }

    testWidgets('renders biometric toggle switch in ProfileScreen settings', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testUser = User(
        id: 1,
        email: 'budi@nutriview.com',
        fullName: 'Budi Santoso',
        role: 'user',
        avatarPreset: 'apple_boy',
      );

      when(() => mockProfileRepo.getUser()).thenAnswer((_) async => testUser);
      when(() => mockProfileRepo.getDailyTarget()).thenAnswer(
        (_) async => DailyTarget(
          caloriesKcal: 2000,
          proteinG: 100,
          carbsG: 250,
          fatG: 65,
          bmrKcal: 1500,
          tdeeKcal: 2000,
        ),
      );

      when(() => mockAuthRepo.isBiometricAvailable())
          .thenAnswer((_) async => true);
      when(() => mockAuthRepo.getAvailableBiometrics())
          .thenAnswer((_) async => [BiometricType.fingerprint]);
      when(() => mockAuthRepo.isBiometricEnabled())
          .thenAnswer((_) async => false);
      when(() => mockAuthRepo.hasPromptedBiometric())
          .thenAnswer((_) async => true);

      await tester.pumpWidget(wrapProfile(const ProfileScreen()));
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      expect(find.text('Kunci Sidik Jari'), findsOneWidget);
    });

    testWidgets('toggling switch ON calls setBiometricEnabled(true)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testUser = User(
        id: 1,
        email: 'budi@nutriview.com',
        fullName: 'Budi Santoso',
        role: 'user',
        avatarPreset: 'apple_boy',
      );

      when(() => mockProfileRepo.getUser()).thenAnswer((_) async => testUser);
      when(() => mockProfileRepo.getDailyTarget()).thenAnswer(
        (_) async => DailyTarget(
          caloriesKcal: 2000,
          proteinG: 100,
          carbsG: 250,
          fatG: 65,
          bmrKcal: 1500,
          tdeeKcal: 2000,
        ),
      );

      when(() => mockAuthRepo.isBiometricAvailable())
          .thenAnswer((_) async => true);
      when(() => mockAuthRepo.getAvailableBiometrics())
          .thenAnswer((_) async => [BiometricType.fingerprint]);
      when(() => mockAuthRepo.isBiometricEnabled())
          .thenAnswer((_) async => false);
      when(() => mockAuthRepo.hasPromptedBiometric())
          .thenAnswer((_) async => true);
      when(() => mockAuthRepo.setBiometricEnabled(true))
          .thenAnswer((_) async {});

      await tester.pumpWidget(wrapProfile(const ProfileScreen()));
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      await tester.ensureVisible(switchFinder);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      verify(() => mockAuthRepo.setBiometricEnabled(true)).called(1);
    });
  });
}
