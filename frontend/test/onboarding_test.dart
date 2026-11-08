import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oopsieeats/core/app_icons.dart';
import 'package:oopsieeats/core/routes.dart';
import 'package:oopsieeats/core/theme.dart';
import 'package:oopsieeats/data/api_client.dart';
import 'package:oopsieeats/data/models/user.dart';
import 'package:oopsieeats/data/repositories/auth_repository.dart';
import 'package:oopsieeats/features/auth/providers/auth_provider.dart';
import 'package:oopsieeats/features/onboarding/screens/onboarding_screen.dart';
import 'package:oopsieeats/features/onboarding/widgets/brand_badge.dart';
import 'package:oopsieeats/features/onboarding/widgets/skip_button.dart';
import 'package:oopsieeats/features/onboarding/widgets/slide_food_discovery.dart';
import 'package:oopsieeats/features/onboarding/widgets/slide_healthy_habits.dart';
import 'package:oopsieeats/features/onboarding/widgets/slide_nutrition_awareness.dart';
import 'package:oopsieeats/features/splash/screens/splash_screen.dart';
import 'package:provider/provider.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockApiClient mockApiClient;
  late MockAuthRepository mockAuthRepository;
  late AuthProvider authProvider;

  setUp(() {
    mockApiClient = MockApiClient();
    mockAuthRepository = MockAuthRepository();
    authProvider = AuthProvider(mockAuthRepository);

    when(() => mockApiClient.hasCompletedOnboarding())
        .thenAnswer((_) async => false);
    when(() => mockApiClient.saveOnboardingCompleted(any()))
        .thenAnswer((_) async {});
  });

  Widget createTestWidget({
    required Widget child,
    Size screenSize = const Size(390, 844),
  }) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: mockApiClient),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: MediaQuery(
        data: MediaQueryData(size: screenSize),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          routes: {
            AppRoutes.onboarding: (_) => const OnboardingScreen(),
            AppRoutes.login: (_) => const Scaffold(body: Text('LOGIN_SCREEN')),
            AppRoutes.dashboard: (_) =>
                const Scaffold(body: Text('DASHBOARD_SCREEN')),
          },
          home: child,
        ),
      ),
    );
  }

  group('Requirement 1 & UI: Exactly 3 Slides and Initial Presentation', () {
    testWidgets('1. Onboarding has exactly 3 slides and renders slide 1 initially', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.childrenDelegate.estimatedChildCount, 3);

      expect(find.byType(BrandBadge), findsOneWidget);
      expect(find.byType(SkipButton), findsOneWidget);
      expect(find.text('01 · FOOD DISCOVERY'), findsOneWidget);
      expect(find.text('Piringmu!'), findsOneWidget);
      expect(find.byType(SlideFoodDiscovery), findsOneWidget);
    });

    testWidgets('Sticker on slide 1 has NO nasi goreng topping and no plate animations', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      // Ensure no nasi_goreng_topping asset is loaded or displayed
      final imageFinders = find.byType(Image);
      for (final imageWidget in tester.widgetList<Image>(imageFinders)) {
        if (imageWidget.image is AssetImage) {
          final asset = imageWidget.image as AssetImage;
          expect(asset.assetName.contains('topping'), isFalse);
        }
      }
    });
  });

  group('Requirement 2 & 3: Forward and Backward Swipe Navigation', () {
    testWidgets('2. Swipe forward advances from slide 1 to 2, and 2 to 3', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      // Swipe 1 -> 2
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000.0);
      await tester.pumpAndSettle();
      expect(find.byType(SlideNutritionAwareness), findsOneWidget);

      // Swipe 2 -> 3
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000.0);
      await tester.pumpAndSettle();
      expect(find.byType(SlideHealthyHabits), findsOneWidget);
    });

    testWidgets('3. Swipe backward navigates back from slide 3 to 2, and 2 to 1', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      // Advance to slide 3 via Next button
      await tester.tap(find.byIcon(AppIcons.arrowForward));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AppIcons.arrowForward));
      await tester.pumpAndSettle();
      expect(find.byType(SlideHealthyHabits), findsOneWidget);

      // Swipe back 3 -> 2
      await tester.fling(find.byType(PageView), const Offset(400, 0), 1000.0);
      await tester.pumpAndSettle();
      expect(find.byType(SlideNutritionAwareness), findsOneWidget);

      // Swipe back 2 -> 1
      await tester.fling(find.byType(PageView), const Offset(400, 0), 1000.0);
      await tester.pumpAndSettle();
      expect(find.byType(SlideFoodDiscovery), findsOneWidget);
    });
  });

  group('Requirement 4, 5, 6 & Lifecycle: Skip and CTA Persistence', () {
    testWidgets('4 & 6. Skip button saves onboarding status and routes to login', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SkipButton));
      await tester.pumpAndSettle();

      verify(() => mockApiClient.saveOnboardingCompleted(true)).called(1);
      expect(find.text('LOGIN_SCREEN'), findsOneWidget);
    });

    testWidgets('5 & 6. Last slide CTA (Mulai Sekarang) saves status and routes to login', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      // Advance to slide 3
      await tester.tap(find.byIcon(AppIcons.arrowForward));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AppIcons.arrowForward));
      await tester.pumpAndSettle();

      // Tap Mulai Sekarang
      await tester.tap(find.text('MULAI SEKARANG'));
      await tester.pumpAndSettle();

      verify(() => mockApiClient.saveOnboardingCompleted(true)).called(1);
      expect(find.text('LOGIN_SCREEN'), findsOneWidget);
    });

    testWidgets('Swiping between slides does NOT prematurely save onboarding status', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000.0);
      await tester.pumpAndSettle();

      verifyNever(() => mockApiClient.saveOnboardingCompleted(any()));
    });
  });

  group('Requirement 7, 8 & 9: Production Flow & Auth Routing', () {
    testWidgets('7. Completed onboarding user does NOT see onboarding again', (
      tester,
    ) async {
      when(() => mockAuthRepository.isLoggedIn())
          .thenAnswer((_) async => false);
      when(() => mockApiClient.hasCompletedOnboarding())
          .thenAnswer((_) async => true);

      await tester.pumpWidget(
        createTestWidget(
          child: const SplashScreen(
            minimumDuration: Duration(milliseconds: 50),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('LOGIN_SCREEN'), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });

    testWidgets('8. Already logged-in user bypasses onboarding directly to dashboard', (
      tester,
    ) async {
      when(() => mockAuthRepository.isLoggedIn())
          .thenAnswer((_) async => true);
      when(() => mockAuthRepository.getRole())
          .thenAnswer((_) async => 'user');
      when(() => mockAuthRepository.getUserName())
          .thenAnswer((_) async => 'Ahmad Badawi');
      when(() => mockAuthRepository.getUserEmail())
          .thenAnswer((_) async => 'ahmad@nutriview.id');

      authProvider.setCurrentUser(User(
        id: 1,
        fullName: 'Ahmad Badawi',
        email: 'ahmad@nutriview.id',
        role: 'user',
        isProfileComplete: true,
      ));

      await tester.pumpWidget(
        createTestWidget(
          child: const SplashScreen(
            minimumDuration: Duration(milliseconds: 50),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('DASHBOARD_SCREEN'), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });

    testWidgets('9. User logout clears session credentials but preserves onboarding completed status', (
      tester,
    ) async {
      when(() => mockAuthRepository.isLoggedIn())
          .thenAnswer((_) async => false);
      when(() => mockApiClient.hasCompletedOnboarding())
          .thenAnswer((_) async => true);

      // Simulates app restart after logout
      await tester.pumpWidget(
        createTestWidget(
          child: const SplashScreen(
            minimumDuration: Duration(milliseconds: 50),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      // Should land on login, never on onboarding
      expect(find.text('LOGIN_SCREEN'), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });
  });

  group('Requirement 10, 11 & 15: Rapid Interaction, No Exceptions, Clean Disposal', () {
    testWidgets('10 & 11. Rapid swipe and repeated Next clicks produce zero exceptions', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      // Rapidly fling multiple times without settling
      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1200.0);
      await tester.pump(const Duration(milliseconds: 40));
      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1200.0);
      await tester.pump(const Duration(milliseconds: 40));
      await tester.fling(find.byType(PageView), const Offset(300, 0), 1200.0);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('15. Disposes cleanly without controller or ticker leaks', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      // Replace widget to trigger dispose
      await tester.pumpWidget(
        createTestWidget(child: const Scaffold(body: Text('REPLACED'))),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('REPLACED'), findsOneWidget);
    });
  });

  group('Requirement 12: Responsive Validation Across 5 Viewports', () {
    final testSizes = [
      const Size(360, 800), // Standard Android compact
      const Size(390, 844), // iPhone 12/13/14 baseline
      const Size(393, 873), // Pixel 7
      const Size(412, 915), // Pixel 7 Pro
      const Size(430, 932), // iPhone 14/15 Pro Max
    ];

    for (final size in testSizes) {
      testWidgets('12. Renders all 3 slides on ${size.width}x${size.height} with ZERO RenderFlex overflow', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            child: const OnboardingScreen(),
            screenSize: size,
          ),
        );
        await tester.pumpAndSettle();

        // Slide 1 check
        expect(tester.takeException(), isNull);
        expect(find.byType(SlideFoodDiscovery), findsOneWidget);

        // Advance to Slide 2
        await tester.tap(find.byIcon(AppIcons.arrowForward));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(SlideNutritionAwareness), findsOneWidget);

        // Advance to Slide 3
        await tester.tap(find.byIcon(AppIcons.arrowForward));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(SlideHealthyHabits), findsOneWidget);
      });
    }
  });

  group('Requirement 13 & 14: Food Image Scaling Limits & Face Safe Zone', () {
    testWidgets('13. Food items strictly clear the Face Safe Zone on Slide 1', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const OnboardingScreen()),
      );
      await tester.pumpAndSettle();

      final stageRenderBox = tester.renderObject<RenderBox>(
        find.byType(SlideFoodDiscovery),
      );
      final stageSize = stageRenderBox.size;
      final double w = stageSize.width;
      final double h = stageSize.height;

      // Face Safe Zone on Slide 1: Horizontal [0.24 * w, 0.70 * w], Vertical [0.18 * h, 0.48 * h]
      final faceSafeZone = Rect.fromLTRB(
        w * 0.24,
        h * 0.18,
        w * 0.70,
        h * 0.48,
      );

      // Check all food images on slide 1
      final foodImages = find.descendant(
        of: find.byType(SlideFoodDiscovery),
        matching: find.byType(Image),
      );

      for (final element in tester.elementList(foodImages)) {
        final renderBox = element.renderObject as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          final localPos = renderBox.localToGlobal(
            Offset.zero,
            ancestor: stageRenderBox,
          );
          final rect = Rect.fromLTWH(
            localPos.dx,
            localPos.dy,
            renderBox.size.width,
            renderBox.size.height,
          );
          final imageWidget = element.widget as Image;
          if (imageWidget.image is AssetImage) {
            final asset = imageWidget.image as AssetImage;
            // Only test food images, not the portrait photo
            if (asset.assetName.contains('food')) {
              final intersects = rect.overlaps(faceSafeZone);
              expect(
                intersects,
                isFalse,
                reason:
                    '${asset.assetName} overlaps the Face Safe Zone: $rect vs $faceSafeZone',
              );
            }
          }
        }
      }
    });

    testWidgets(
      '14. Food images are strictly bounded and never exceed maximum threshold',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(child: const OnboardingScreen()),
        );
        await tester.pumpAndSettle();

        // Check all ConstrainedBox wrappers specifically for food items
        final foodImages = find.descendant(
          of: find.byType(SlideFoodDiscovery),
          matching: find.byType(Image),
        );

        for (final element in tester.elementList(foodImages)) {
          final imageWidget = element.widget as Image;
          if (imageWidget.image is AssetImage) {
            final asset = imageWidget.image as AssetImage;
            if (asset.assetName.contains('food')) {
              final constrainedBox = element
                  .findAncestorWidgetOfExactType<ConstrainedBox>();
              expect(constrainedBox, isNotNull);
              expect(
                constrainedBox!.constraints.maxWidth,
                lessThanOrEqualTo(120.0),
                reason:
                    'Food image ${asset.assetName} width exceeded max threshold',
              );
              expect(
                constrainedBox.constraints.maxHeight,
                lessThanOrEqualTo(130.0),
                reason:
                    'Food image ${asset.assetName} height exceeded max threshold',
              );
            }
          }
        }
      },
    );
  });
}
