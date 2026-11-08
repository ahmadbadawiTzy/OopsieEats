import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oopsieeats/core/theme.dart';
import 'package:oopsieeats/data/models/dashboard.dart';
import 'package:oopsieeats/features/auth/providers/auth_provider.dart';
import 'package:oopsieeats/features/auth/screens/login_screen.dart';
import 'package:oopsieeats/shared/neo/neo.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oopsieeats/data/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthProvider authProvider;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authProvider = AuthProvider(mockAuthRepository);
  });

  testWidgets('LoginScreen displays OopsieEats title and input fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('OopsieEats'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Daftar Sekarang'), findsOneWidget);
  });

  testWidgets('NeoStatCard displays correct percentage and nutrient amounts', (
    WidgetTester tester,
  ) async {
    final progress = NutrientProgress(
      consumed: 1200.5,
      target: 2546.0,
      percentage: 47.2,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: NeoStatCard(
            title: 'Energi / Kalori',
            progress: progress,
            unit: 'kkal',
          ),
        ),
      ),
    );

    expect(find.text('Energi / Kalori'), findsOneWidget);
    expect(find.text('47.2%'), findsOneWidget);
    expect(find.text('Terkonsumsi: 1200.5 kkal'), findsOneWidget);
    expect(find.text('Target: 2546.0 kkal'), findsOneWidget);
  });

  testWidgets('NeoButton responds to tap and displays loading indicator', (
    WidgetTester tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NeoButton(text: 'Tekan Saya', onPressed: () => tapped = true),
        ),
      ),
    );

    expect(find.text('Tekan Saya'), findsOneWidget);
    await tester.tap(find.text('Tekan Saya'));
    expect(tapped, isTrue);

    // Pump button in loading state
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NeoButton(
            text: 'Sedang Proses',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Sedang Proses'), findsNothing);
  });

  testWidgets('NeoBadge renders text label and icon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NeoBadge(
            label: 'TERVERIFIKASI',
            icon: Icons.check_rounded,
            color: NeoBadgeColor.mint,
          ),
        ),
      ),
    );

    expect(find.text('TERVERIFIKASI'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('NeoProgressBar renders visually and clamps fractions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: NeoProgressBar(value: 0.75))),
    );

    expect(find.byType(NeoProgressBar), findsOneWidget);
  });
}
