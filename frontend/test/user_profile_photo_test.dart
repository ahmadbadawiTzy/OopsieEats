import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mocktail/mocktail.dart';
import 'package:oopsieeats/data/models/user.dart';
import 'package:oopsieeats/data/repositories/profile_repository.dart';
import 'package:oopsieeats/data/services/supabase_storage_service.dart';
import 'package:oopsieeats/features/auth/providers/auth_provider.dart';
import 'package:oopsieeats/features/profile/providers/profile_provider.dart';
import 'package:oopsieeats/shared/neo/user_profile_avatar.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}
class MockSupabaseStorageService extends Mock implements SupabaseStorageService {}
class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  group('UserProfileAvatar Unit & Widget Tests', () {
    test('extractInitials extracts clean 1-2 uppercase letters correctly', () {
      expect(UserProfileAvatar.extractInitials('Ahmad Badawi'), equals('AB'));
      expect(UserProfileAvatar.extractInitials('Budi'), equals('B'));
      expect(UserProfileAvatar.extractInitials('ahmad badawi'), equals('AB'));
      expect(UserProfileAvatar.extractInitials('  Siti   Nurhaliza  '), equals('SN'));
      expect(UserProfileAvatar.extractInitials('badawi@example.com'), equals('B'));
      expect(UserProfileAvatar.extractInitials(''), equals('U'));
      expect(UserProfileAvatar.extractInitials('   '), equals('U'));
    });

    testWidgets('renders initials on vibrant background when photoUrl is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserProfileAvatar(
              name: 'Ahmad Badawi',
              size: 48,
            ),
          ),
        ),
      );

      expect(find.text('AB'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(
        find.bySemanticsLabel('Foto profil Ahmad Badawi'),
        findsOneWidget,
      );
    });

    testWidgets('triggers onTap callback when pressed', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserProfileAvatar(
              name: 'Budi Santoso',
              size: 50,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(UserProfileAvatar));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('SupabaseStorageService Profile Photo Compression Tests', () {
    test('compresses rectangular image into 1:1 square with max 512px dimension', () async {
      final storage = SupabaseStorageService();

      // Create a 800x400 landscape synthetic test image
      final testImage = img.Image(width: 800, height: 400);
      img.fill(testImage, color: img.ColorRgb8(200, 100, 50));
      final rawBytes = Uint8List.fromList(img.encodePng(testImage));

      final result = await storage.compressProfilePhoto(rawBytes);

      // Verify center square cropping and downscaling (max dimension 512)
      expect(result.width, lessThanOrEqualTo(512));
      expect(result.height, lessThanOrEqualTo(512));
      expect(result.width, equals(result.height)); // 1:1 aspect ratio
      expect(result.bytes.isNotEmpty, isTrue);
    });
  });

  group('ProfileProvider Photo State Management Tests', () {
    late MockProfileRepository mockRepo;
    late ProfileProvider profileProvider;

    setUp(() {
      mockRepo = MockProfileRepository();
      profileProvider = ProfileProvider(mockRepo);
    });

    test('updateProfilePhoto successfully updates user and notifies listeners', () async {
      final dummyBytes = Uint8List.fromList([1, 2, 3, 4]);
      final updatedUser = User(
        id: 1,
        email: 'ahmad@example.com',
        fullName: 'Ahmad Badawi',
        photoUrl: 'https://example.com/signed/profile_123.jpg',
        photoPath: 'uid_123/profile/profile_123.jpg',
      );

      when(() => mockRepo.updateProfilePhoto(dummyBytes))
          .thenAnswer((_) async => updatedUser);

      bool notified = false;
      profileProvider.addListener(() {
        notified = true;
      });

      final success = await profileProvider.updateProfilePhoto(dummyBytes);

      expect(success, isTrue);
      expect(notified, isTrue);
      expect(profileProvider.user?.photoUrl, equals('https://example.com/signed/profile_123.jpg'));
      expect(profileProvider.user?.photoPath, equals('uid_123/profile/profile_123.jpg'));
      expect(profileProvider.isLoading, isFalse);
    });

    test('deleteProfilePhoto clears photoUrl and photoPath from state', () async {
      when(() => mockRepo.deleteProfilePhoto()).thenAnswer((_) async {});

      // Seed initial user with photo
      final initialUser = User(
        id: 1,
        email: 'ahmad@example.com',
        fullName: 'Ahmad Badawi',
        photoUrl: 'https://example.com/signed/profile_123.jpg',
        photoPath: 'uid_123/profile/profile_123.jpg',
      );
      when(() => mockRepo.getUser()).thenAnswer((_) async => initialUser);
      await profileProvider.loadProfile();

      expect(profileProvider.user?.photoUrl, isNotNull);

      final success = await profileProvider.deleteProfilePhoto();

      expect(success, isTrue);
      expect(profileProvider.user?.photoUrl, isNull);
      expect(profileProvider.user?.photoPath, isNull);
    });

    test('updateProfilePhoto rollback on exception retains previous user state and sets errorMessage', () async {
      final initialUser = User(
        id: 1,
        email: 'ahmad@example.com',
        fullName: 'Ahmad Badawi',
        photoUrl: 'https://example.com/initial_photo.jpg',
        photoPath: 'uid_123/profile/initial.jpg',
      );
      when(() => mockRepo.getUser()).thenAnswer((_) async => initialUser);
      await profileProvider.loadProfile();

      when(() => mockRepo.updateProfilePhoto(any()))
          .thenThrow(Exception('Supabase storage network timeout'));

      final success = await profileProvider.updateProfilePhoto(Uint8List.fromList([1, 2, 3]));

      expect(success, isFalse);
      expect(profileProvider.errorMessage, equals('Gagal memperbarui foto profil.'));
      expect(profileProvider.user?.photoUrl, equals('https://example.com/initial_photo.jpg'));
      expect(profileProvider.user?.photoPath, equals('uid_123/profile/initial.jpg'));
      expect(profileProvider.isLoading, isFalse);
    });

    test('deleteProfilePhoto failure retains photo and exposes errorMessage', () async {
      final initialUser = User(
        id: 1,
        email: 'ahmad@example.com',
        fullName: 'Ahmad Badawi',
        photoUrl: 'https://example.com/signed/profile_123.jpg',
        photoPath: 'uid_123/profile/profile_123.jpg',
      );
      when(() => mockRepo.getUser()).thenAnswer((_) async => initialUser);
      await profileProvider.loadProfile();

      when(() => mockRepo.deleteProfilePhoto())
          .thenThrow(Exception('Firestore permission denied'));

      final success = await profileProvider.deleteProfilePhoto();

      expect(success, isFalse);
      expect(profileProvider.errorMessage, equals('Gagal menghapus foto profil.'));
      expect(profileProvider.user?.photoUrl, equals('https://example.com/signed/profile_123.jpg'));
    });
  });

  group('User Model Photo Persistence & CopyWith Tests', () {
    test('fromJson and toJson persist photo_path and photo_url accurately', () {
      final json = {
        'id': 42,
        'email': 'ahmad@nutriview.id',
        'full_name': 'Ahmad Badawi',
        'role': 'user',
        'is_active': true,
        'is_profile_complete': true,
        'photo_url': 'https://storage.supabase.co/profile.jpg',
        'photo_path': 'user_42/profile/profile_999.jpg',
      };

      final user = User.fromJson(json);
      expect(user.photoUrl, equals('https://storage.supabase.co/profile.jpg'));
      expect(user.photoPath, equals('user_42/profile/profile_999.jpg'));

      final outJson = user.toJson();
      expect(outJson['photo_url'], equals('https://storage.supabase.co/profile.jpg'));
      expect(outJson['photo_path'], equals('user_42/profile/profile_999.jpg'));
    });

    test('copyWith clearPhoto clears photo properties completely', () {
      final user = User(
        id: 1,
        email: 'test@example.com',
        fullName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        photoPath: 'uid/photo.jpg',
        avatarPreset: 'chef_pro',
      );

      final cleared = user.copyWith(clearPhoto: true);
      expect(cleared.photoUrl, isNull);
      expect(cleared.photoPath, isNull);
      expect(cleared.avatarPreset, isNull);
      expect(cleared.fullName, equals('Test User'));
    });
  });
}
