import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/data/api_client.dart';
import 'package:nutriview/data/models/profile.dart';
import 'package:nutriview/data/models/user.dart';
import 'package:nutriview/features/admin/data/admin_repository.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/data/repositories/auth_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('Strict Binary Role System Tests (user & admin only)', () {
    test(
      'User model strictly allows ONLY role == admin to have isAdmin == true',
      () {
        final regularUser = User(
          id: 1,
          email: 'user@nutriview.id',
          fullName: 'Regular User',
          role: 'user',
        );
        expect(regularUser.role, 'user');
        expect(regularUser.isAdmin, isFalse);

        final adminUser = User(
          id: 2,
          email: 'admin@nutriview.id',
          fullName: 'Administrator',
          role: 'admin',
        );
        expect(adminUser.role, 'admin');
        expect(adminUser.isAdmin, isTrue);

        // Verify that old/legacy role strings are NO LONGER recognized as admin
        final oldSuperAdmin = User(
          id: 3,
          email: 'old_super@nutriview.id',
          fullName: 'Old Super Admin',
          role: 'super_admin',
        );
        expect(oldSuperAdmin.isAdmin, isFalse);

        final oldDietitian = User(
          id: 4,
          email: 'old_dietitian@nutriview.id',
          fullName: 'Old Dietitian',
          role: 'dietitian',
        );
        expect(oldDietitian.isAdmin, isFalse);

        final oldEditor = User(
          id: 5,
          email: 'old_editor@nutriview.id',
          fullName: 'Old Editor',
          role: 'editor',
        );
        expect(oldEditor.isAdmin, isFalse);
      },
    );

    test('Strict Separation: Display Profession does NOT grant admin permissions (No Privilege Escalation)', () {
      // User with profession 'Ahli Gizi' but security role 'user'
      final dietitianProfile = UserProfile(
        age: 30,
        sex: 'female',
        weightKg: 55.0,
        heightCm: 160.0,
        activityLevel: 'moderate',
        goal: 'maintain_weight',
        profession: 'Ahli Gizi',
      );

      final userWithDietitianProfession = User(
        id: 10,
        email: 'ahligizi@gmail.com',
        fullName: 'Dr. Gizi Pengguna',
        role: 'user',
        profile: dietitianProfile,
      );

      expect(userWithDietitianProfession.profile?.profession, 'Ahli Gizi');
      // Crucial security guarantee:
      expect(userWithDietitianProfession.role, 'user');
      expect(userWithDietitianProfession.isAdmin, isFalse);
    });

    test('UserProfile profession serialization and defaults', () {
      final defaultProfile = UserProfile(
        age: 22,
        sex: 'male',
        weightKg: 65.0,
        heightCm: 170.0,
        activityLevel: 'active',
        goal: 'gain_weight',
      );
      expect(defaultProfile.profession, 'Umum');
      expect(defaultProfile.toJson()['profession'], 'Umum');

      final json = {
        'age': 29,
        'sex': 'male',
        'weight_kg': 72.0,
        'height_cm': 176.0,
        'activity_level': 'sedentary',
        'goal': 'lose_weight',
        'profession': 'Software Developer',
      };
      final parsed = UserProfile.fromJson(json);
      expect(parsed.profession, 'Software Developer');
      expect(parsed.calculatedAge, 29);
    });

    test('AuthProvider reflects strict binary role status and prevents unauthorized access', () async {
      final mockRepo = MockAuthRepository();
      final authProvider = AuthProvider(mockRepo);

      // User role
      when(() => mockRepo.isLoggedIn()).thenAnswer((_) async => true);
      when(() => mockRepo.getRole()).thenAnswer((_) async => 'user');
      when(() => mockRepo.getUserName()).thenAnswer((_) async => 'Test User');
      when(() => mockRepo.getUserEmail()).thenAnswer((_) async => 'u@nutri.id');

      await authProvider.checkAuthStatus();
      expect(authProvider.role, 'user');
      expect(authProvider.isAdmin, isFalse);

      // Admin role
      when(() => mockRepo.getRole()).thenAnswer((_) async => 'admin');
      await authProvider.checkAuthStatus();
      expect(authProvider.role, 'admin');
      expect(authProvider.isAdmin, isTrue);
    });

    test('AdminRepository.setUserStatus enforces Admin authorization and blocks non-admin callers', () async {
      final mockClient = MockApiClient();

      // Non-admin user trying to alter user status
      when(() => mockClient.getRole()).thenAnswer((_) async => 'user');
      when(() => mockClient.getUserEmail())
          .thenAnswer((_) async => 'user@nutri.id');

      final repo = AdminRepository(client: mockClient);

      expect(
        () async => await repo.setUserStatus(100, false),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'FORBIDDEN')),
      );
    });
  });
}
