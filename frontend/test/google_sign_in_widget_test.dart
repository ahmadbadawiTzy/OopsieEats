import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/data/models/user.dart';
import 'package:nutriview/data/repositories/auth_repository.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/features/auth/screens/login_screen.dart';
import 'package:nutriview/shared/neo/neo_button.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late AuthProvider authProvider;

  setUp(() {
    mockRepository = MockAuthRepository();
    authProvider = AuthProvider(mockRepository);
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
        routes: {
          AppRoutes.dashboard: (_) =>
              const Scaffold(body: Text('DASHBOARD_SCREEN')),
          AppRoutes.completeProfile: (_) =>
              const Scaffold(body: Text('COMPLETE_PROFILE_SCREEN')),
          AppRoutes.adminDashboard: (_) =>
              const Scaffold(body: Text('ADMIN_DASHBOARD_SCREEN')),
          AppRoutes.register: (_) =>
              const Scaffold(body: Text('REGISTER_SCREEN')),
        },
      ),
    );
  }

  group('Google Sign-In Widget & UI Tests', () {
    testWidgets(
      'renders Google Sign-In button with exact text, official logo, and divider',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Check for 'Masuk' button
        expect(find.widgetWithText(NeoButton, 'Masuk'), findsOneWidget);

        // Check for divider with 'ATAU' text
        expect(find.text('ATAU'), findsOneWidget);
        expect(find.byType(Divider), findsNWidgets(2));

        // Check for 'Lanjutkan dengan Google' button
        final googleBtnFinder = find.widgetWithText(
          NeoButton,
          'Lanjutkan dengan Google',
        );
        expect(googleBtnFinder, findsOneWidget);

        // Verify NeoButton properties
        final neoBtn = tester.widget<NeoButton>(googleBtnFinder);
        expect(neoBtn.variant, equals(NeoButtonVariant.secondary));
        expect(neoBtn.prefixWidget, isNotNull);

        // Verify prefixWidget is Image.asset with official google_logo.png
        final imageFinder = find.descendant(
          of: googleBtnFinder,
          matching: find.byType(Image),
        );
        expect(imageFinder, findsOneWidget);
        final imageWidget = tester.widget<Image>(imageFinder);
        expect(imageWidget.image, isA<AssetImage>());
        final assetImage = imageWidget.image as AssetImage;
        expect(assetImage.assetName, equals('assets/images/google_logo.png'));
        expect(imageWidget.width, equals(AppIcons.sizeControl));
        expect(imageWidget.height, equals(AppIcons.sizeControl));
      },
    );

    testWidgets(
      'shows loading state on Google button and disables double submission',
      (tester) async {
        final completer = Completer<User?>();
        when(
          () => mockRepository.loginWithGoogle(),
        ).thenAnswer((_) => completer.future);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Tap Google Sign-In button
        final googleBtn = find.byType(NeoButton).last;
        await tester.ensureVisible(googleBtn);
        await tester.tap(googleBtn);
        await tester.pump();

        // Verify provider enters loading state
        expect(authProvider.isGoogleLoading, isTrue);
        expect(authProvider.isLoading, isTrue);

        // Verify loading indicator is shown inside button
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Verify pressing again does nothing while loading
        await tester.tap(googleBtn);
        await tester.pump();
        verify(
          () => mockRepository.loginWithGoogle(),
        ).called(1);

        // Complete the future
        completer.complete(null);
        await tester.pumpAndSettle();

        expect(authProvider.isGoogleLoading, isFalse);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets('successful user login with complete profile routes to dashboard', (tester) async {
      final fakeUser = User(
        id: 101,
        email: 'user@gmail.com',
        fullName: 'Budi Santoso',
        role: 'user',
        isActive: true,
        isProfileComplete: true,
      );

      when(
        () => mockRepository.loginWithGoogle(),
      ).thenAnswer((_) async => fakeUser);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final googleBtnFinder = find.widgetWithText(
        NeoButton,
        'Lanjutkan dengan Google',
      );
      await tester.ensureVisible(googleBtnFinder);
      await tester.tap(googleBtnFinder);
      await tester.pumpAndSettle();

      expect(find.text('DASHBOARD_SCREEN'), findsOneWidget);
    });

    testWidgets('successful user login with incomplete profile routes to complete profile screen', (tester) async {
      final fakeUser = User(
        id: 102,
        email: 'newuser@gmail.com',
        fullName: 'New User',
        role: 'user',
        isActive: true,
        isProfileComplete: false,
      );

      when(
        () => mockRepository.loginWithGoogle(),
      ).thenAnswer((_) async => fakeUser);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final googleBtnFinder = find.widgetWithText(
        NeoButton,
        'Lanjutkan dengan Google',
      );
      await tester.ensureVisible(googleBtnFinder);
      await tester.tap(googleBtnFinder);
      await tester.pumpAndSettle();

      expect(find.text('COMPLETE_PROFILE_SCREEN'), findsOneWidget);
    });

    testWidgets('successful admin login routes to admin dashboard', (
      tester,
    ) async {
      final fakeAdmin = User(
        id: 1,
        email: 'admin@nutriview.id',
        fullName: 'Administrator',
        role: 'admin',
        isActive: true,
      );

      when(
        () => mockRepository.loginWithGoogle(),
      ).thenAnswer((_) async => fakeAdmin);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final googleBtnFinder = find.widgetWithText(
        NeoButton,
        'Lanjutkan dengan Google',
      );
      await tester.ensureVisible(googleBtnFinder);
      await tester.tap(googleBtnFinder);
      await tester.pumpAndSettle();

      expect(find.text('ADMIN_DASHBOARD_SCREEN'), findsOneWidget);
    });

    testWidgets(
      'user cancellation does not navigate and displays no error banner',
      (tester) async {
        when(
          () => mockRepository.loginWithGoogle(),
        ).thenAnswer((_) async => null);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        final googleBtnFinder = find.widgetWithText(
          NeoButton,
          'Lanjutkan dengan Google',
        );
        await tester.ensureVisible(googleBtnFinder);
        await tester.tap(googleBtnFinder);
        await tester.pumpAndSettle();

        // Remains on login screen
        expect(
          find.widgetWithText(NeoButton, 'Lanjutkan dengan Google'),
          findsOneWidget,
        );
        // No error banner
        expect(authProvider.errorMessage, isNull);
        expect(find.byIcon(AppIcons.error), findsNothing);
      },
    );

    testWidgets(
      'error in Google sign in shows error banner with Indonesian message',
      (tester) async {
        when(
          () => mockRepository.loginWithGoogle(),
        ).thenThrow(
          ApiException(
            statusCode: 503,
            code: 'NETWORK_ERROR',
            message:
                'Koneksi jaringan bermasalah. Periksa koneksi internet Anda.',
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        final googleBtnFinder = find.widgetWithText(
          NeoButton,
          'Lanjutkan dengan Google',
        );
        await tester.ensureVisible(googleBtnFinder);
        await tester.tap(googleBtnFinder);
        await tester.pumpAndSettle();

        // Error message is displayed in UI
        expect(
          find.text(
            'Koneksi jaringan bermasalah. Periksa koneksi internet Anda.',
          ),
          findsOneWidget,
        );
        expect(find.byIcon(AppIcons.error), findsOneWidget);
      },
    );
  });
}
