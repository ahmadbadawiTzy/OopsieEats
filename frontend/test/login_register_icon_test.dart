import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/data/models/profile.dart';
import 'package:nutriview/data/models/user.dart';
import 'package:nutriview/data/repositories/auth_repository.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/features/auth/screens/login_screen.dart';
import 'package:nutriview/features/auth/screens/register_screen.dart';
import 'package:nutriview/features/splash/widgets/neo_splash_badge.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

/// Guards the authentication surface of the icon/design-system audit:
/// Login and Register must render exclusively from the [AppIcons] standard
/// while validation, the password toggle and post-login navigation keep
/// behaving exactly as before.
void main() {
  late MockAuthRepository mockAuthRepo;
  late AuthProvider authProvider;

  /// Every glyph the authentication screens are allowed to render.
  final allowedAuthIcons = <IconData>{
    AppIcons.email,
    AppIcons.lock,
    AppIcons.personOutline,
    AppIcons.visibility,
    AppIcons.visibilityOff,
    AppIcons.error,
    AppIcons.arrowForward,
    AppIcons.login,
    AppIcons.fingerprint,
    AppIcons.face,
  };

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    when(() => mockAuthRepo.isBiometricAvailable())
        .thenAnswer((_) async => false);
    when(() => mockAuthRepo.getAvailableBiometrics())
        .thenAnswer((_) async => []);
    when(() => mockAuthRepo.isBiometricEnabled())
        .thenAnswer((_) async => false);
    authProvider = AuthProvider(mockAuthRepo);
  });

  Widget wrap(Widget home) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: home,
        routes: {
          AppRoutes.dashboard: (_) =>
              const Scaffold(body: Text('DASHBOARD_ROUTE')),
          AppRoutes.completeProfile: (_) =>
              const Scaffold(body: Text('COMPLETE_PROFILE_ROUTE')),
          AppRoutes.profile: (_) => const Scaffold(body: Text('PROFILE_ROUTE')),
        },
      ),
    );
  }

  Set<IconData> renderedIcons(WidgetTester tester) => tester
      .widgetList<Icon>(find.byType(Icon))
      .map((icon) => icon.icon)
      .whereType<IconData>()
      .toSet();

  group('Login screen icon standard', () {
    testWidgets('renders only AppIcons glyphs, sized by role token', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const LoginScreen()));
      await tester.pump();

      final rendered = renderedIcons(tester);
      expect(rendered, isNotEmpty);
      expect(
        rendered.difference(allowedAuthIcons),
        isEmpty,
        reason:
            'Login must only draw icons from the NutriView standard, found: '
            '${rendered.difference(allowedAuthIcons)}',
      );

      // The exact glyphs that used to be off-standard on Login.
      expect(find.byIcon(Icons.email_outlined), findsNothing);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
      expect(find.byIcon(AppIcons.restaurantMenu), findsNothing);

      // Brand Logo Mark: must render the official NutriView Apple logo (matching splash & app icon)
      expect(find.byType(NutriViewLogoMark), findsOneWidget);

      // Standard field icons, all at the standard control size.
      expect(find.byIcon(AppIcons.email), findsOneWidget);
      expect(find.byIcon(AppIcons.lock), findsOneWidget);
      expect(find.byIcon(AppIcons.visibilityOff), findsOneWidget);

      expect(
        tester.widget<Icon>(find.byIcon(AppIcons.email)).size,
        AppIcons.sizeControl,
      );
      expect(
        tester.widget<Icon>(find.byIcon(AppIcons.lock)).size,
        AppIcons.sizeControl,
      );
    });

    testWidgets('password visibility toggle works and is labelled', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const LoginScreen()));
      await tester.pump();

      expect(find.byIcon(AppIcons.visibilityOff), findsOneWidget);
      expect(find.byIcon(AppIcons.visibility), findsNothing);
      expect(find.byTooltip('Tampilkan kata sandi'), findsOneWidget);

      await tester.ensureVisible(find.byIcon(AppIcons.visibilityOff));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AppIcons.visibilityOff));
      await tester.pump();

      expect(find.byIcon(AppIcons.visibility), findsOneWidget);
      expect(find.byIcon(AppIcons.visibilityOff), findsNothing);
      expect(find.byTooltip('Sembunyikan kata sandi'), findsOneWidget);
      expect(find.byTooltip('Tampilkan kata sandi'), findsNothing);
    });

    testWidgets('empty submit shows field validation and never calls the API', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const LoginScreen()));
      await tester.pump();

      await tester.ensureVisible(find.text('Masuk'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Masuk'));
      await tester.pump();

      expect(find.text('Email wajib diisi.'), findsOneWidget);
      expect(find.text('Kata sandi wajib diisi.'), findsOneWidget);
      verifyNever(
        () => mockAuthRepo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('valid credentials still sign in and route by role', (
      tester,
    ) async {
      when(
        () =>
            mockAuthRepo.login(email: 'badi@example.com', password: 'abc12345'),
      ).thenAnswer(
        (_) async => User(
          id: 1,
          email: 'badi@example.com',
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

      await tester.pumpWidget(wrap(const LoginScreen()));
      await tester.pump();

      await tester.enterText(
        find.byType(TextFormField).first,
        '  badi@example.com  ',
      );
      await tester.enterText(find.byType(TextFormField).last, 'abc12345');
      await tester.ensureVisible(find.text('Masuk'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      verify(
        () =>
            mockAuthRepo.login(email: 'badi@example.com', password: 'abc12345'),
      ).called(1);
      expect(find.text('DASHBOARD_ROUTE'), findsOneWidget);
    });

    testWidgets(
      'admin credentials sign in and MUST route directly to admin dashboard',
      (tester) async {
        when(
          () => mockAuthRepo.login(
            email: 'admin@example.com',
            password: 'adminPassword123',
          ),
        ).thenAnswer(
          (_) async => User(
            id: 99,
            email: 'admin@example.com',
            fullName: 'Admin NutriView',
            role: 'admin',
          ),
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const LoginScreen(),
              routes: {
                AppRoutes.dashboard: (_) =>
                    const Scaffold(body: Text('DASHBOARD_ROUTE')),
                AppRoutes.adminDashboard: (_) =>
                    const Scaffold(body: Text('ADMIN_DASHBOARD_ROUTE')),
              },
            ),
          ),
        );
        await tester.pump();

        await tester.enterText(
          find.byType(TextFormField).first,
          'admin@example.com',
        );
        await tester.enterText(
          find.byType(TextFormField).last,
          'adminPassword123',
        );
        await tester.ensureVisible(find.text('Masuk'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Masuk'));
        await tester.pumpAndSettle();

        verify(
          () => mockAuthRepo.login(
            email: 'admin@example.com',
            password: 'adminPassword123',
          ),
        ).called(1);
        expect(find.text('ADMIN_DASHBOARD_ROUTE'), findsOneWidget);
        expect(find.text('DASHBOARD_ROUTE'), findsNothing);
      },
    );
  });

  group('Register screen icon standard', () {
    testWidgets('shares the Login field icon system, nothing off-standard', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const RegisterScreen()));
      await tester.pump();

      final rendered = renderedIcons(tester);
      expect(
        rendered.difference(allowedAuthIcons),
        isEmpty,
        reason:
            'Register must only draw icons from the NutriView standard, found: '
            '${rendered.difference(allowedAuthIcons)}',
      );

      expect(find.byIcon(Icons.email_outlined), findsNothing);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

      // Identical email/password glyphs as Login -> one form system.
      expect(find.byIcon(AppIcons.email), findsOneWidget);
      expect(find.byIcon(AppIcons.lock), findsOneWidget);
      expect(find.byIcon(AppIcons.personOutline), findsOneWidget);

      expect(
        tester.widget<Icon>(find.byIcon(AppIcons.personOutline)).size,
        AppIcons.sizeControl,
      );
      expect(
        tester.widget<Icon>(find.byIcon(AppIcons.email)).size,
        AppIcons.sizeControl,
      );
      expect(
        tester.widget<Icon>(find.byIcon(AppIcons.lock)).size,
        AppIcons.sizeControl,
      );
    });

    testWidgets('password visibility toggle works on Register too', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const RegisterScreen()));
      await tester.pump();

      expect(find.byTooltip('Tampilkan kata sandi'), findsOneWidget);
      await tester.ensureVisible(find.byIcon(AppIcons.visibilityOff));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AppIcons.visibilityOff));
      await tester.pump();
      expect(find.byIcon(AppIcons.visibility), findsOneWidget);
      expect(find.byTooltip('Sembunyikan kata sandi'), findsOneWidget);
    });

    testWidgets('password rules are still enforced before any network call', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const RegisterScreen()));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, 'Ahmad Badawi');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'badi@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'short');

      await tester.ensureVisible(find.text('Daftar Akun'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Daftar Akun'));
      await tester.pump();

      expect(find.text('Kata sandi minimal 8 karakter.'), findsOneWidget);
      verifyZeroInteractions(mockAuthRepo);
    });
  });
}
