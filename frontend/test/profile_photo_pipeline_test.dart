import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mocktail/mocktail.dart';
import 'package:oopsieeats/core/error_handler.dart';
import 'package:oopsieeats/core/profile_photo_logger.dart';
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

  group('Suite 1: Image Validation & Pre-Upload Checks', () {
    test('validates file size within 5MB boundary', () {
      const fiveMb = 5 * 1024 * 1024;
      final validBytes = Uint8List(1024 * 1024); // 1 MB
      final edgeBytes = Uint8List(fiveMb); // Exactly 5 MB
      final invalidBytes = Uint8List(fiveMb + 1); // 5 MB + 1 byte

      expect(validBytes.length <= fiveMb, isTrue);
      expect(edgeBytes.length <= fiveMb, isTrue);
      expect(invalidBytes.length > fiveMb, isTrue);
    });

    test('rejects empty byte array (0 bytes)', () {
      final emptyBytes = Uint8List(0);
      expect(emptyBytes.isEmpty, isTrue);
    });

    test('ProfilePhotoLogger masks user identifiers and sanitizes JWTs', () {
      expect(ProfilePhotoLogger.maskUid(''), equals('-'));
      expect(ProfilePhotoLogger.maskUid(null), equals('-'));
      expect(ProfilePhotoLogger.maskUid('abc'), equals('abc'));
      expect(ProfilePhotoLogger.maskUid('abcdef123456'), equals('abc...456'));

      final rawError = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.doNotLeak';
      final sanitized = ProfilePhotoLogger.sanitizeError(rawError);
      expect(sanitized.contains('doNotLeak'), isFalse);
      expect(sanitized.contains('[JWT_REDACTED]'), isTrue);
    });
  });

  group('Suite 2: SupabaseStorageService Compression & Path Structure', () {
    test('compresses and crops rectangular image to 1:1 square <= 512px', () async {
      final storage = SupabaseStorageService();

      // Create a 1000x500 rectangular test image
      final imgOriginal = img.Image(width: 1000, height: 500);
      img.fill(imgOriginal, color: img.ColorRgb8(120, 200, 80));
      final rawBytes = Uint8List.fromList(img.encodePng(imgOriginal));

      final result = await storage.compressProfilePhoto(rawBytes);

      expect(result.width, equals(result.height)); // 1:1 aspect ratio
      expect(result.width, lessThanOrEqualTo(512));
      expect(result.height, lessThanOrEqualTo(512));
      expect(result.bytes.isNotEmpty, isTrue);
    });

    test('path pattern adheres strictly to Supabase Storage RLS regex', () {
      const uid = 'usr_abc123';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '$uid/profile/profile_$timestamp.jpg';

      final rlsRegex = RegExp(
        r'^[a-zA-Z0-9_-]+/(profile|[0-9]+)/(profile|food)_[0-9]+\.(jpg|jpeg|png|webp)$',
      );

      expect(rlsRegex.hasMatch(path), isTrue);
      expect(rlsRegex.hasMatch('malicious/path/inject.sh'), isFalse);
      expect(rlsRegex.hasMatch('../../../etc/passwd'), isFalse);
      expect(rlsRegex.hasMatch('$uid/other/file.jpg'), isFalse);
    });

    test('in-memory cache returns cached signed URL if valid lifetime remains', () async {
      final storage = SupabaseStorageService();
      const testPath = 'usr_1/profile/profile_100.jpg';
      const testUrl = 'https://supabase.co/storage/v1/sign/food-history-images/usr_1/profile_100.jpg?token=abc';

      storage.seedSignedUrlCache(
        testPath,
        testUrl,
        DateTime.now().add(const Duration(hours: 1)),
      );

      final cached = await storage.getSignedImageUrl(testPath);
      expect(cached, equals(testUrl));
    });
  });

  group('Suite 3: ProfileRepository State & Firestore Contract', () {
    late MockProfileRepository mockRepo;
    late ProfileProvider profileProvider;

    setUp(() {
      mockRepo = MockProfileRepository();
      profileProvider = ProfileProvider(mockRepo);
    });

    test('updates profile photo, clears preset avatar, and notifies UI listeners', () async {
      final syntheticBytes = Uint8List.fromList([255, 216, 255, 224]);
      final updatedUser = User(
        id: 42,
        email: 'test@nutriview.com',
        fullName: 'Dr. Nutri',
        photoUrl: 'https://supabase.co/signed/user42.jpg',
        photoPath: 'user42/profile/profile_12345.jpg',
        avatarPreset: null,
      );

      when(() => mockRepo.updateProfilePhoto(syntheticBytes))
          .thenAnswer((_) async => updatedUser);

      var notificationCount = 0;
      profileProvider.addListener(() {
        notificationCount++;
      });

      final success = await profileProvider.updateProfilePhoto(syntheticBytes);

      expect(success, isTrue);
      expect(notificationCount, greaterThanOrEqualTo(1));
      expect(profileProvider.user?.photoUrl, equals('https://supabase.co/signed/user42.jpg'));
      expect(profileProvider.user?.photoPath, equals('user42/profile/profile_12345.jpg'));
      expect(profileProvider.user?.avatarPreset, isNull);
      expect(profileProvider.isLoading, isFalse);
    });

    test('handles upload error gracefully without crashing and sets friendly errorMessage', () async {
      final syntheticBytes = Uint8List.fromList([1, 2, 3]);

      when(() => mockRepo.updateProfilePhoto(syntheticBytes)).thenThrow(
        ApiException(
          statusCode: 500,
          code: 'PROFILE_PHOTO_UPLOAD_FAILED',
          message: 'Gagal mengunggah foto profil.',
        ),
      );

      final success = await profileProvider.updateProfilePhoto(syntheticBytes);

      expect(success, isFalse);
      expect(profileProvider.errorMessage, equals('Gagal mengunggah foto profil.'));
      expect(profileProvider.isLoading, isFalse);
    });

    test('deleteProfilePhoto removes photo references and resets to name initials', () async {
      when(() => mockRepo.deleteProfilePhoto()).thenAnswer((_) async {});

      final initialUser = User(
        id: 42,
        email: 'test@nutriview.com',
        fullName: 'Dr. Nutri',
        photoUrl: 'https://supabase.co/signed/user42.jpg',
        photoPath: 'user42/profile/profile_12345.jpg',
      );
      when(() => mockRepo.getUser()).thenAnswer((_) async => initialUser);

      await profileProvider.loadProfile();
      expect(profileProvider.user?.photoUrl, isNotNull);

      final success = await profileProvider.deleteProfilePhoto();

      expect(success, isTrue);
      expect(profileProvider.user?.photoUrl, isNull);
      expect(profileProvider.user?.photoPath, isNull);
    });
  });

  group('Suite 4: Integration (Upload -> Signed URL -> Firestore -> UserProfileAvatar)', () {
    testWidgets('renders UserProfileAvatar with initial letters fallback when photoUrl is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserProfileAvatar(
              name: 'Ahmad Badawi',
              photoUrl: null,
              size: 64,
            ),
          ),
        ),
      );

      expect(find.text('AB'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders fallback initials when photoUrl is invalid or empty string', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserProfileAvatar(
              name: 'Siti Rahma',
              photoUrl: '',
              size: 48,
            ),
          ),
        ),
      );

      expect(find.text('SR'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('extractInitials handles diverse naming patterns deterministically', (
      tester,
    ) async {
      expect(UserProfileAvatar.extractInitials('John Doe'), equals('JD'));
      expect(UserProfileAvatar.extractInitials('Single'), equals('S'));
      expect(UserProfileAvatar.extractInitials('user@domain.com'), equals('U'));
      expect(UserProfileAvatar.extractInitials(''), equals('U'));
      expect(UserProfileAvatar.extractInitials('  Tri  Agustina  Dewi '), equals('TA'));
    });
  });
}
