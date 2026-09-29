import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/data/models/dashboard.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/features/auth/screens/login_screen.dart';
import 'package:nutriview/shared/widgets/progress_card.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutriview/data/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthProvider authProvider;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authProvider = AuthProvider(mockAuthRepository);
  });

  testWidgets('LoginScreen displays NutriView title and input fields',
      (WidgetTester tester) async {
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

    expect(find.text('NutriView'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Daftar Sekarang'), findsOneWidget);
  });

  testWidgets('ProgressCard displays correct percentage and nutrient amounts',
      (WidgetTester tester) async {
    final progress = NutrientProgress(
      consumed: 1200.5,
      target: 2546.0,
      percentage: 47.2,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: ProgressCard(
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
}
