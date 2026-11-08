import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:oopsieeats/core/error_handler.dart';
import 'package:oopsieeats/core/routes.dart';
import 'package:oopsieeats/core/theme.dart';
import 'package:oopsieeats/data/models/user.dart';
import 'package:oopsieeats/data/repositories/auth_repository.dart';
import 'package:oopsieeats/features/auth/providers/auth_provider.dart';
import 'package:oopsieeats/features/auth/screens/register_screen.dart';
import 'package:oopsieeats/shared/neo/neo_button.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late AuthProvider authProvider;

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

  Widget wrapRegister(Widget screen) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: screen,
        routes: {
          AppRoutes.login: (_) => const Scaffold(body: Text('LOGIN_SCREEN')),
          AppRoutes.completeProfile: (_) =>
              const Scaffold(body: Text('COMPLETE_PROFILE_SCREEN')),
        },
      ),
    );
  }

  void setStandardScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
  }

  group('RegisterScreen Redesign UI & Validation Tests', () {
    testWidgets(
      '1. renders brand header, fields, password helper, and submit button',
      (tester) async {
        setStandardScreen(tester);
        await tester.pumpWidget(wrapRegister(const RegisterScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Mulai Perjalanan Gizi Anda'), findsOneWidget);
        expect(
          find.text('Daftar untuk memantau asupan gizi harian secara mudah'),
          findsOneWidget,
        );
        expect(find.text('Data Akun'), findsOneWidget);
        expect(find.text('Nama Lengkap'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Kata Sandi'), findsOneWidget);
        expect(
          find.text('Minimal 8 karakter dengan kombinasi huruf dan angka.'),
          findsOneWidget,
        );
        expect(find.widgetWithText(NeoButton, 'Daftar Akun'), findsOneWidget);
        expect(find.text('Sudah memiliki akun? '), findsOneWidget);
        expect(find.text('Masuk'), findsOneWidget);
      },
    );

    testWidgets(
      '2. empty submit triggers field validation and does not call repository',
      (tester) async {
        setStandardScreen(tester);
        await tester.pumpWidget(wrapRegister(const RegisterScreen()));
        await tester.pumpAndSettle();

        final btn = find.widgetWithText(NeoButton, 'Daftar Akun');
        await tester.ensureVisible(btn);
        await tester.tap(btn);
        await tester.pump();

        expect(find.text('Nama lengkap wajib diisi.'), findsOneWidget);
        expect(find.text('Email wajib diisi.'), findsOneWidget);
        expect(find.text('Kata sandi wajib diisi.'), findsOneWidget);

        verifyZeroInteractions(mockAuthRepo);
      },
    );

    testWidgets('3. name minimum length validation triggers when < 2 chars', (
      tester,
    ) async {
      setStandardScreen(tester);
      await tester.pumpWidget(wrapRegister(const RegisterScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'A');
      final btn = find.widgetWithText(NeoButton, 'Daftar Akun');
      await tester.ensureVisible(btn);
      await tester.tap(btn);
      await tester.pump();

      expect(find.text('Nama lengkap minimal 2 karakter.'), findsOneWidget);
      verifyZeroInteractions(mockAuthRepo);
    });

    testWidgets('4. invalid email format triggers validation message', (
      tester,
    ) async {
      setStandardScreen(tester);
      await tester.pumpWidget(wrapRegister(const RegisterScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Ahmad Badawi');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'invalid-email-address',
      );
      final btn = find.widgetWithText(NeoButton, 'Daftar Akun');
      await tester.ensureVisible(btn);
      await tester.tap(btn);
      await tester.pump();

      expect(find.text('Format email tidak valid.'), findsOneWidget);
      verifyZeroInteractions(mockAuthRepo);
    });

    testWidgets(
      '5. password validation enforces minimum 8 chars and alphanumeric mix',
      (tester) async {
        setStandardScreen(tester);
        await tester.pumpWidget(wrapRegister(const RegisterScreen()));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextFormField).first,
          'Ahmad Badawi',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'ahmad@example.com',
        );

        final btn = find.widgetWithText(NeoButton, 'Daftar Akun');
        await tester.ensureVisible(btn);

        // Too short
        await tester.enterText(find.byType(TextFormField).last, 'pass');
        await tester.tap(btn);
        await tester.pump();
        expect(find.text('Kata sandi minimal 8 karakter.'), findsOneWidget);

        // 8 chars but only letters
        await tester.enterText(find.byType(TextFormField).last, 'password');
        await tester.tap(btn);
        await tester.pump();
        expect(
          find.text('Kata sandi harus mengandung kombinasi huruf dan angka.'),
          findsOneWidget,
        );

        // 8 chars but only digits
        await tester.enterText(find.byType(TextFormField).last, '12345678');
        await tester.tap(btn);
        await tester.pump();
        expect(
          find.text('Kata sandi harus mengandung kombinasi huruf dan angka.'),
          findsOneWidget,
        );

        verifyZeroInteractions(mockAuthRepo);
      },
    );

    testWidgets(
      '6. password visibility toggle updates obscure state and tooltip',
      (tester) async {
        setStandardScreen(tester);
        await tester.pumpWidget(wrapRegister(const RegisterScreen()));
        await tester.pumpAndSettle();

        expect(find.byTooltip('Tampilkan kata sandi'), findsOneWidget);

        await tester.tap(find.byTooltip('Tampilkan kata sandi'));
        await tester.pump();

        expect(find.byTooltip('Sembunyikan kata sandi'), findsOneWidget);
      },
    );

    testWidgets(
      '7. valid registration calls repository and routes to profile onboarding',
      (tester) async {
        setStandardScreen(tester);
        when(
          () => mockAuthRepo.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            fullName: any(named: 'fullName'),
          ),
        ).thenAnswer(
          (_) async => User(
            id: 1,
            email: 'ahmad@example.com',
            fullName: 'Ahmad Badawi',
            role: 'user',
          ),
        );

        when(
          () => mockAuthRepo.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer(
          (_) async => User(
            id: 1,
            email: 'ahmad@example.com',
            fullName: 'Ahmad Badawi',
            role: 'user',
          ),
        );

        await tester.pumpWidget(wrapRegister(const RegisterScreen()));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextFormField).first,
          'Ahmad Badawi',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'ahmad@example.com',
        );
        await tester.enterText(find.byType(TextFormField).last, 'Secret123');

        final btn = find.widgetWithText(NeoButton, 'Daftar Akun');
        await tester.ensureVisible(btn);
        await tester.tap(btn);
        await tester.pumpAndSettle();

        verify(
          () => mockAuthRepo.register(
            email: 'ahmad@example.com',
            password: 'Secret123',
            fullName: 'Ahmad Badawi',
          ),
        ).called(1);

        expect(find.text('COMPLETE_PROFILE_SCREEN'), findsOneWidget);
        expect(find.byType(RegisterScreen), findsNothing);
      },
    );

    testWidgets('8. duplicate submission is prevented while loading', (
      tester,
    ) async {
      setStandardScreen(tester);
      when(
        () => mockAuthRepo.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
          fullName: any(named: 'fullName'),
        ),
      ).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 200));
        return User(
          id: 1,
          email: 'ahmad@example.com',
          fullName: 'Ahmad Badawi',
          role: 'user',
        );
      });

      when(
        () => mockAuthRepo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => User(
          id: 1,
          email: 'ahmad@example.com',
          fullName: 'Ahmad Badawi',
          role: 'user',
        ),
      );

      await tester.pumpWidget(wrapRegister(const RegisterScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Ahmad Badawi');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'ahmad@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'Secret123');

      final btn = find.widgetWithText(NeoButton, 'Daftar Akun');
      await tester.ensureVisible(btn);

      // First tap
      await tester.tap(btn);
      await tester.pump(); // Start async call

      // Second tap while loading
      await tester.tap(find.byType(NeoButton));
      await tester.pump();

      await tester.pumpAndSettle();

      // Only registered once
      verify(
        () => mockAuthRepo.register(
          email: 'ahmad@example.com',
          password: 'Secret123',
          fullName: 'Ahmad Badawi',
        ),
      ).called(1);
    });

    testWidgets(
      '9. registration error displays error banner and preserves entered text',
      (tester) async {
        setStandardScreen(tester);
        when(
          () => mockAuthRepo.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            fullName: any(named: 'fullName'),
          ),
        ).thenThrow(
          ApiException(
            statusCode: 400,
            code: 'EMAIL_ALREADY_REGISTERED',
            message:
                'Email sudah terdaftar. Silakan gunakan email lain atau login.',
          ),
        );

        await tester.pumpWidget(wrapRegister(const RegisterScreen()));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextFormField).first,
          'Ahmad Badawi',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'existing@example.com',
        );
        await tester.enterText(find.byType(TextFormField).last, 'Secret123');

        final btn = find.widgetWithText(NeoButton, 'Daftar Akun');
        await tester.ensureVisible(btn);
        await tester.tap(btn);
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Email sudah terdaftar. Silakan gunakan email lain atau login.',
          ),
          findsOneWidget,
        );

        // Verify entered input values are preserved safely
        expect(find.text('Ahmad Badawi'), findsOneWidget);
        expect(find.text('existing@example.com'), findsOneWidget);
      },
    );

    testWidgets('10. tapping Masuk navigates back to Login screen', (
      tester,
    ) async {
      setStandardScreen(tester);
      await tester.pumpWidget(wrapRegister(const RegisterScreen()));
      await tester.pumpAndSettle();

      final masukBtn = find.text('Masuk');
      await tester.ensureVisible(masukBtn);
      await tester.tap(masukBtn);
      await tester.pumpAndSettle();

      expect(find.text('LOGIN_SCREEN'), findsOneWidget);
    });

    testWidgets(
      '11. responsive: small phone (320x568) with keyboard inset does not overflow',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(wrapRegister(const RegisterScreen()));
        await tester.pumpAndSettle();

        // Simulate keyboard open by giving viewInsets
        tester.view.viewInsets = const FakeViewPadding(bottom: 250);
        addTearDown(() => tester.view.resetViewInsets());

        await tester.pump();

        // Must render without any RenderFlex overflow exceptions
        expect(tester.takeException(), isNull);
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      },
    );
  });
}
