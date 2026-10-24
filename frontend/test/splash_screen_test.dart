import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/data/repositories/auth_repository.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/features/splash/screens/splash_screen.dart';
import 'package:nutriview/features/splash/widgets/neo_splash_badge.dart';
import 'package:provider/provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthProvider authProvider;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authProvider = AuthProvider(mockAuthRepository);
  });

  Widget buildTestApp({
    required Widget child,
    bool disableAnimations = false,
    Map<String, WidgetBuilder>? routes,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: MediaQuery(
        data: MediaQueryData(
          size: const Size(400, 800),
          disableAnimations: disableAnimations,
        ),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: child,
          routes:
              routes ??
              {
                AppRoutes.dashboard: (_) =>
                    const Scaffold(body: Text('DASHBOARD_SCREEN')),
                AppRoutes.adminDashboard: (_) =>
                    const Scaffold(body: Text('ADMIN_DASHBOARD_SCREEN')),
                AppRoutes.login: (_) =>
                    const Scaffold(body: Text('LOGIN_SCREEN')),
              },
        ),
      ),
    );
  }

  group('NutriViewLogoMark Widget', () {
    testWidgets('renders Apple logo mark and custom painter correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: NutriViewLogoMark(size: 140, leafAngle: 0.05)),
          ),
        ),
      );

      expect(find.byType(NutriViewLogoMark), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(NutriViewLogoMark),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });
  });

  group('Consumer SplashScreen Navigation, Brand Copy & Animations', () {
    testWidgets(
      'renders consumer brand mark, wordmark, tagline and ZERO tech jargon',
      (tester) async {
        when(() => mockAuthRepository.isLoggedIn())
            .thenAnswer((_) async => false);

        await tester.pumpWidget(
          buildTestApp(
            child: const SplashScreen(
              minimumDuration: Duration(milliseconds: 1000),
            ),
          ),
        );

        // Initial frame pump
        await tester.pump();

        expect(find.byType(NutriViewLogoMark), findsOneWidget);
        expect(find.text('NutriView'), findsOneWidget);
        expect(find.text("Know what's on your plate."), findsOneWidget);

        // Strictly verify zero technical jargon
        expect(find.text('YOLO26N ENGINE'), findsNothing);
        expect(find.text('OPTIC // SCANNING'), findsNothing);
        expect(find.text('NV // PROTOKOL v1.0'), findsNothing);
        expect(find.text('TENSOR PIPELINE: ACTIVE'), findsNothing);
        expect(find.text('VERIFYING CREDENTIALS...'), findsNothing);

        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'navigates to AppRoutes.login when unauthenticated after sequence',
      (tester) async {
        when(() => mockAuthRepository.isLoggedIn())
            .thenAnswer((_) async => false);

        await tester.pumpWidget(
          buildTestApp(
            child: const SplashScreen(
              minimumDuration: Duration(milliseconds: 200),
            ),
          ),
        );

        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.text('LOGIN_SCREEN'), findsOneWidget);
      },
    );

    testWidgets(
      'navigates to AppRoutes.dashboard when standard user is authenticated',
      (tester) async {
        when(() => mockAuthRepository.isLoggedIn())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepository.getRole())
            .thenAnswer((_) async => 'user');
        when(() => mockAuthRepository.getUserName())
            .thenAnswer((_) async => 'Ahmad Badawi');
        when(() => mockAuthRepository.getUserEmail())
            .thenAnswer((_) async => 'ahmad@example.com');

        await tester.pumpWidget(
          buildTestApp(
            child: const SplashScreen(
              minimumDuration: Duration(milliseconds: 200),
            ),
          ),
        );

        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.text('DASHBOARD_SCREEN'), findsOneWidget);
      },
    );

    testWidgets(
      'navigates to AppRoutes.adminDashboard when admin user is authenticated',
      (tester) async {
        when(() => mockAuthRepository.isLoggedIn())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepository.getRole())
            .thenAnswer((_) async => 'super_admin');
        when(() => mockAuthRepository.getUserName())
            .thenAnswer((_) async => 'Admin NutriView');
        when(() => mockAuthRepository.getUserEmail())
            .thenAnswer((_) async => 'admin@nutriview.com');

        await tester.pumpWidget(
          buildTestApp(
            child: const SplashScreen(
              minimumDuration: Duration(milliseconds: 200),
            ),
          ),
        );

        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.text('ADMIN_DASHBOARD_SCREEN'), findsOneWidget);
      },
    );

    testWidgets('respects disableAnimations preference without hanging', (
      tester,
    ) async {
      when(() => mockAuthRepository.isLoggedIn())
          .thenAnswer((_) async => false);

      await tester.pumpWidget(
        buildTestApp(
          disableAnimations: true,
          child: const SplashScreen(
            minimumDuration: Duration(milliseconds: 1500),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('LOGIN_SCREEN'), findsOneWidget);
    });
  });
}
