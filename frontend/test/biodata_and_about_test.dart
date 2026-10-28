import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/config/creator_config.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/data/models/profile.dart';
import 'package:nutriview/data/models/user.dart';
import 'package:nutriview/data/repositories/profile_repository.dart';
import 'package:nutriview/features/profile/providers/profile_provider.dart';
import 'package:nutriview/features/profile/screens/about_screen.dart';
import 'package:nutriview/features/profile/screens/biodata_screen.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('AboutScreen Tests', () {
    testWidgets('renders app branding and creator profile for Ahmad Badawi', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const AboutScreen()),
      );
      await tester.pumpAndSettle();

      // App identity
      expect(find.text('NutriView'), findsWidgets);
      expect(find.textContaining(CreatorConfig.appVersion), findsWidgets);
      expect(find.text('Nilai Utama Aplikasi'), findsOneWidget);

      // Creator profile
      expect(find.text('Profil Pengembang'), findsOneWidget);
      expect(find.text(CreatorConfig.creatorName), findsWidgets);
      expect(find.text(CreatorConfig.creatorProfession), findsOneWidget);
      expect(find.textContaining('Ahmad Badawi'), findsWidgets);

      // Social links & portfolios
      expect(find.text('GitHub'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('LinkedIn'), findsOneWidget);
      expect(find.text('github.com/ahmadbadawiTzy'), findsOneWidget);
      expect(find.text(CreatorConfig.instagramHandle), findsOneWidget);
    });

    testWidgets('tapping social links copies link to clipboard', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const AboutScreen()),
      );
      await tester.pumpAndSettle();

      // Tap GitHub link
      final gitHubButton = find.text('GitHub');
      await tester.ensureVisible(gitHubButton);
      await tester.pumpAndSettle();
      await tester.tap(gitHubButton);
      await tester.pump();

      // Verify SnackBar appears confirming copy
      expect(find.textContaining('disalin ke papan klip'), findsOneWidget);
    });
  });

  group('BiodataScreen Tests', () {
    late MockProfileRepository mockProfileRepo;
    late ProfileProvider profileProvider;

    setUp(() {
      mockProfileRepo = MockProfileRepository();
      profileProvider = ProfileProvider(mockProfileRepo);

      when(() => mockProfileRepo.getUser()).thenAnswer(
        (_) async => User(
          id: 1,
          email: 'test@example.com',
          fullName: 'Ahmad Badawi',
          role: 'user',
          avatarPreset: 'chef_pro',
          profile: UserProfile(
            age: 26,
            birthDate: DateTime(2000, 5, 15),
            sex: 'male',
            weightKg: 65,
            heightCm: 172,
            activityLevel: 'moderate',
            goal: 'maintain_weight',
          ),
        ),
      );
      when(() => mockProfileRepo.getDailyTarget()).thenAnswer(
        (_) async => DailyTarget(
          caloriesKcal: 2200,
          proteinG: 110,
          carbsG: 275,
          fatG: 73,
          bmrKcal: 1600,
          tdeeKcal: 2200,
        ),
      );
    });

    testWidgets('renders biodata fields with dynamic age badge', (
      tester,
    ) async {
      await profileProvider.loadProfile();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProfileProvider>.value(
              value: profileProvider,
            ),
            Provider<ProfileRepository>.value(value: mockProfileRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const BiodataScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check fields
      expect(find.text('Kelola Biodata'), findsOneWidget);
      expect(find.text('Tanggal Lahir'), findsOneWidget);
      expect(find.text('Berat Badan (kg)'), findsOneWidget);
      expect(find.text('Tinggi Badan (cm)'), findsOneWidget);
      expect(find.text('Tingkat Aktivitas Harian'), findsOneWidget);
      expect(find.text('Tujuan Gizi'), findsOneWidget);

      // Check dynamic age badge
      expect(find.textContaining('Usia:'), findsOneWidget);
      expect(find.textContaining('thn'), findsOneWidget);

      // Check buttons
      expect(find.text('Simpan Perubahan Biodata'), findsOneWidget);
      expect(find.text('Hapus Biodata Fisik'), findsOneWidget);
    });
  });
}
