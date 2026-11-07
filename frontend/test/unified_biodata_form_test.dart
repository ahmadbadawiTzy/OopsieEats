import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/data/models/profile.dart';
import 'package:nutriview/data/models/user.dart';
import 'package:nutriview/data/repositories/profile_repository.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/features/dashboard/providers/dashboard_provider.dart';
import 'package:nutriview/features/profile/providers/profile_provider.dart';
import 'package:nutriview/features/profile/widgets/unified_biodata_form.dart';
import 'package:nutriview/shared/neo/neo_button.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}
class MockAuthProvider extends Mock implements AuthProvider {}
class MockDashboardProvider extends Mock implements DashboardProvider {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
    registerFallbackValue(UserProfile(
      age: 25,
      sex: 'male',
      weightKg: 70,
      heightCm: 175,
      activityLevel: 'moderate',
      goal: 'maintain',
    ));
  });

  group('UnifiedBiodataForm Unit & Widget Tests', () {
    late MockProfileRepository mockProfileRepo;
    late ProfileProvider profileProvider;
    late MockAuthProvider mockAuth;
    late MockDashboardProvider mockDashboard;

    setUp(() {
      mockProfileRepo = MockProfileRepository();
      profileProvider = ProfileProvider(mockProfileRepo);
      mockAuth = MockAuthProvider();
      mockDashboard = MockDashboardProvider();

      when(() => mockAuth.currentUser).thenReturn(User(
        id: 1,
        email: 'user@nutriview.id',
        fullName: 'Budi Santoso',
      ));
      when(() => mockAuth.isProfileComplete).thenReturn(false);
    });

    Widget createTestWidget({required BiodataFormMode mode}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ProfileProvider>.value(value: profileProvider),
          Provider<ProfileRepository>.value(value: mockProfileRepo),
          ChangeNotifierProvider<AuthProvider>.value(value: mockAuth),
          ChangeNotifierProvider<DashboardProvider>.value(value: mockDashboard),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: UnifiedBiodataForm(mode: mode),
            ),
          ),
        ),
      );
    }

    testWidgets('Onboarding mode renders clean initial fields and onboarding copy', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(mode: BiodataFormMode.onboarding));
      await tester.pumpAndSettle();

      // Headers & Educational Card
      expect(find.text('Satu Langkah Terakhir!'), findsOneWidget);
      expect(
        find.textContaining('NutriView membutuhkan data fisik Anda untuk mengestimasi kebutuhan kalori harian'),
        findsOneWidget,
      );

      // Verify empty text fields (no dummy / sample numbers)
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(3)); // Name, Height, Weight
      
      final nameField = tester.widget<TextFormField>(textFields.at(0));
      expect(nameField.controller?.text, equals('Budi Santoso'));

      final heightField = tester.widget<TextFormField>(textFields.at(1));
      expect(heightField.controller?.text, isEmpty);

      final weightField = tester.widget<TextFormField>(textFields.at(2));
      expect(weightField.controller?.text, isEmpty);

      // Submit button text
      expect(find.widgetWithText(NeoButton, 'Simpan & Lanjutkan'), findsOneWidget);
      // Delete biodata should NOT exist in onboarding mode
      expect(find.text('Hapus Biodata Fisik'), findsNothing);
    });

    testWidgets('Edit mode pre-fills existing profile metrics and shows edit actions', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final existingUser = User(
        id: 1,
        email: 'ahmad@nutriview.id',
        fullName: 'Ahmad Badawi',
        profile: UserProfile(
          age: 26,
          birthDate: DateTime(2000, 3, 20),
          sex: 'male',
          weightKg: 65,
          heightCm: 172,
          activityLevel: 'moderate',
          goal: 'maintain_weight',
          profession: 'Programmer',
        ),
      );

      when(() => mockProfileRepo.getUser()).thenAnswer((_) async => existingUser);
      when(() => mockProfileRepo.getDailyTarget()).thenAnswer((_) async => DailyTarget(
        caloriesKcal: 2200,
        proteinG: 100,
        carbsG: 280,
        fatG: 60,
        bmrKcal: 1600,
        tdeeKcal: 2200,
      ));

      await profileProvider.loadProfile();

      await tester.pumpWidget(createTestWidget(mode: BiodataFormMode.edit));
      await tester.pumpAndSettle();

      // Headers & Educational Card
      expect(find.text('Informasi Fisik & Kesehatan'), findsOneWidget);
      expect(
        find.textContaining('Umur dihitung secara akurat dari tanggal lahir'),
        findsOneWidget,
      );

      // Pre-filled fields
      final textFields = find.byType(TextFormField);
      final heightField = tester.widget<TextFormField>(textFields.at(1));
      expect(heightField.controller?.text, equals('172'));

      final weightField = tester.widget<TextFormField>(textFields.at(2));
      expect(weightField.controller?.text, equals('65'));

      // Action buttons
      expect(find.widgetWithText(NeoButton, 'Simpan Perubahan Biodata'), findsOneWidget);
      expect(find.text('Hapus Biodata Fisik'), findsOneWidget);
    });

    testWidgets('Validation triggers correctly on empty and out-of-bounds input', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(mode: BiodataFormMode.onboarding));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      // Empty input test
      final submitBtn = find.widgetWithText(NeoButton, 'Simpan & Lanjutkan');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Wajib diisi'), findsNWidgets(2)); // Height and weight required

      // Out of range test (< 100 cm, < 30 kg)
      await tester.enterText(textFields.at(1), '80');
      await tester.enterText(textFields.at(2), '25');
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('100 - 250 cm'), findsOneWidget);
      expect(find.text('30 - 300 kg'), findsOneWidget);

      // Out of range test (> 250 cm, > 300 kg)
      await tester.enterText(textFields.at(1), '280');
      await tester.enterText(textFields.at(2), '350');
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('100 - 250 cm'), findsOneWidget);
      expect(find.text('30 - 300 kg'), findsOneWidget);
    });
  });
}
