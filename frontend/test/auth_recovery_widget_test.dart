import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/data/repositories/auth_repository.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/features/auth/screens/login_screen.dart';
import 'package:nutriview/features/auth/widgets/forgot_password_modal.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late AuthProvider authProvider;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    authProvider = AuthProvider(mockAuthRepo);
  });

  Widget wrapWidget(Widget widget) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: widget,
        routes: {
          AppRoutes.login: (_) => const Scaffold(body: Text('LOGIN_SCREEN')),
          AppRoutes.register: (_) =>
              const Scaffold(body: Text('REGISTER_SCREEN')),
          AppRoutes.dashboard: (_) =>
              const Scaffold(body: Text('DASHBOARD_SCREEN')),
        },
      ),
    );
  }

  group('LoginScreen - Remember Me & Forgot Password Integration', () {
    testWidgets('renders Remember Me checkbox and Forgot Password link', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrapWidget(const LoginScreen()));

      expect(find.byKey(const Key('remember_me_checkbox')), findsOneWidget);
      expect(find.text('Ingat Saya'), findsOneWidget);
      expect(find.byKey(const Key('forgot_password_link')), findsOneWidget);
      expect(find.text('Lupa Password?'), findsOneWidget);
    });

    testWidgets('tapping Remember Me checkbox toggles its state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrapWidget(const LoginScreen()));

      final checkboxFinder = find.byKey(const Key('remember_me_checkbox'));
      expect(checkboxFinder, findsOneWidget);

      // Tap to toggle off
      await tester.tap(checkboxFinder);
      await tester.pump();

      // Tap again to toggle on
      await tester.tap(checkboxFinder);
      await tester.pump();

      expect(checkboxFinder, findsOneWidget);
    });

    testWidgets('tapping Forgot Password link opens ForgotPasswordModal', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrapWidget(const LoginScreen()));

      await tester.tap(find.byKey(const Key('forgot_password_link')));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordModal), findsOneWidget);
      expect(find.text('Lupa Kata Sandi'), findsOneWidget);
      expect(find.text('Kirim Instruksi Pemulihan'), findsOneWidget);
    });
  });

  group('ForgotPasswordModal UI & Validation', () {
    testWidgets('validates empty email input', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWidget(const Scaffold(body: ForgotPasswordModal())),
      );

      final submitBtn = find.text('Kirim Instruksi Pemulihan');
      await tester.tap(submitBtn);
      await tester.pump();

      expect(find.text('Email wajib diisi.'), findsOneWidget);
      verifyNever(() => mockAuthRepo.sendPasswordResetEmail(any()));
    });

    testWidgets('validates invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWidget(const Scaffold(body: ForgotPasswordModal())),
      );

      final emailField = find.byType(TextField);
      await tester.enterText(emailField, 'not-an-email');

      final submitBtn = find.text('Kirim Instruksi Pemulihan');
      await tester.tap(submitBtn);
      await tester.pump();

      expect(find.text('Format email tidak valid.'), findsOneWidget);
      verifyNever(() => mockAuthRepo.sendPasswordResetEmail(any()));
    });

    testWidgets(
      'successful submission displays anti-enumeration success banner',
      (WidgetTester tester) async {
        when(() => mockAuthRepo.sendPasswordResetEmail(any()))
            .thenAnswer((_) async {});

        await tester.pumpWidget(
          wrapWidget(const Scaffold(body: ForgotPasswordModal())),
        );

        final emailField = find.byType(TextField);
        await tester.enterText(emailField, 'user@example.com');

        final submitBtn = find.text('Kirim Instruksi Pemulihan');
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        verify(() => mockAuthRepo.sendPasswordResetEmail('user@example.com'))
            .called(1);

        expect(find.text('Instruksi Terkirim'), findsOneWidget);
        expect(
          find.textContaining(
            'Jika email tersebut terhubung dengan akun yang valid',
          ),
          findsOneWidget,
        );
        expect(find.text('Kembali ke Login'), findsOneWidget);
      },
    );

    testWidgets('displays error banner when repository throws error', (
      WidgetTester tester,
    ) async {
      when(() => mockAuthRepo.sendPasswordResetEmail(any())).thenThrow(
        ApiException(
          statusCode: 503,
          code: 'NETWORK_ERROR',
          message: 'Koneksi internet bermasalah.',
        ),
      );

      await tester.pumpWidget(
        wrapWidget(const Scaffold(body: ForgotPasswordModal())),
      );

      final emailField = find.byType(TextField);
      await tester.enterText(emailField, 'user@example.com');

      final submitBtn = find.text('Kirim Instruksi Pemulihan');
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Instruksi Terkirim'), findsNothing);
      expect(
        find.textContaining('Koneksi internet bermasalah'),
        findsOneWidget,
      );
    });

    testWidgets('close icon dismisses the modal', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWidget(
          Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () => ForgotPasswordModal.show(ctx),
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordModal), findsOneWidget);

      final closeBtn = find.byTooltip('Tutup');
      expect(closeBtn, findsOneWidget);
      await tester.tap(closeBtn);
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordModal), findsNothing);
    });
  });
}
