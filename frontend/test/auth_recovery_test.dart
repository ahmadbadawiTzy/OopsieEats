import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/data/api_client.dart';
import 'package:nutriview/data/repositories/auth_repository.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockFirebaseAuth extends Mock implements fb.FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AuthRepository - Password Reset & Remember Me', () {
    late MockApiClient mockApiClient;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockGoogleSignIn mockGoogleSignIn;
    late AuthRepository repository;

    setUp(() {
      mockApiClient = MockApiClient();
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockGoogleSignIn = MockGoogleSignIn();
      repository = AuthRepository(
        mockApiClient,
        mockAuth,
        mockFirestore,
        mockGoogleSignIn,
      );
    });

    group('sendPasswordResetEmail', () {
      test('throws EMPTY_EMAIL when email is empty or whitespace', () async {
        await expectLater(
          () => repository.sendPasswordResetEmail(''),
          throwsA(
            isA<ApiException>().having((e) => e.code, 'code', 'EMPTY_EMAIL'),
          ),
        );
        await expectLater(
          () => repository.sendPasswordResetEmail('   '),
          throwsA(
            isA<ApiException>().having((e) => e.code, 'code', 'EMPTY_EMAIL'),
          ),
        );
      });

      test(
        'throws INVALID_EMAIL_FORMAT when email format is invalid',
        () async {
          await expectLater(
            () => repository.sendPasswordResetEmail('invalid-email'),
            throwsA(
              isA<ApiException>().having(
                (e) => e.code,
                'code',
                'INVALID_EMAIL_FORMAT',
              ),
            ),
          );
          await expectLater(
            () => repository.sendPasswordResetEmail('user@domain'),
            throwsA(
              isA<ApiException>().having(
                (e) => e.code,
                'code',
                'INVALID_EMAIL_FORMAT',
              ),
            ),
          );
        },
      );

      test(
        'calls _auth.sendPasswordResetEmail on valid email and succeeds',
        () async {
          when(
            () => mockAuth.sendPasswordResetEmail(email: any(named: 'email')),
          ).thenAnswer((_) async {});

          await repository.sendPasswordResetEmail('test@example.com');

          verify(
            () => mockAuth.sendPasswordResetEmail(email: 'test@example.com'),
          ).called(1);
        },
      );

      test('anti-account enumeration: swallows user-not-found cleanly without throwing', () async {
        when(() => mockAuth.sendPasswordResetEmail(email: any(named: 'email')))
            .thenThrow(
              fb.FirebaseAuthException(
                code: 'user-not-found',
                message:
                    'There is no user record corresponding to this identifier.',
              ),
            );

        // Should complete normally to prevent enumeration attacks
        await repository.sendPasswordResetEmail('nonexistent@example.com');

        verify(
          () =>
              mockAuth.sendPasswordResetEmail(email: 'nonexistent@example.com'),
        ).called(1);
      });

      test(
        'throws RATE_LIMIT_EXCEEDED when too-many-requests occurs',
        () async {
          when(
            () => mockAuth.sendPasswordResetEmail(email: any(named: 'email')),
          ).thenThrow(
            fb.FirebaseAuthException(
              code: 'too-many-requests',
              message: 'Too many requests.',
            ),
          );

          await expectLater(
            () => repository.sendPasswordResetEmail('user@example.com'),
            throwsA(
              isA<ApiException>().having(
                (e) => e.code,
                'code',
                'RATE_LIMIT_EXCEEDED',
              ),
            ),
          );
        },
      );

      test('throws NETWORK_ERROR when network-request-failed occurs', () async {
        when(() => mockAuth.sendPasswordResetEmail(email: any(named: 'email')))
            .thenThrow(
              fb.FirebaseAuthException(
                code: 'network-request-failed',
                message: 'Network error.',
              ),
            );

        await expectLater(
          () => repository.sendPasswordResetEmail('user@example.com'),
          throwsA(
            isA<ApiException>().having((e) => e.code, 'code', 'NETWORK_ERROR'),
          ),
        );
      });

      test('throws INVALID_EMAIL when invalid-email occurs', () async {
        when(() => mockAuth.sendPasswordResetEmail(email: any(named: 'email')))
            .thenThrow(
              fb.FirebaseAuthException(
                code: 'invalid-email',
                message: 'The email address is badly formatted.',
              ),
            );

        await expectLater(
          () => repository.sendPasswordResetEmail('user@example.com'),
          throwsA(
            isA<ApiException>().having((e) => e.code, 'code', 'INVALID_EMAIL'),
          ),
        );
      });
    });
  });

  group('AuthProvider - Password Reset & Session Handling', () {
    late MockAuthRepository mockRepo;
    late AuthProvider provider;

    setUp(() {
      mockRepo = MockAuthRepository();
      provider = AuthProvider(mockRepo);
    });

    test('sendPasswordResetEmail handles success and loading states', () async {
      when(() => mockRepo.sendPasswordResetEmail(any()))
          .thenAnswer((_) async {});

      expect(provider.isResetPasswordLoading, isFalse);

      final future = provider.sendPasswordResetEmail('test@example.com');
      expect(provider.isResetPasswordLoading, isTrue);

      final result = await future;
      expect(result, isTrue);
      expect(provider.isResetPasswordLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test(
      'sendPasswordResetEmail handles error and updates errorMessage',
      () async {
        when(() => mockRepo.sendPasswordResetEmail(any())).thenThrow(
          ApiException(
            statusCode: 429,
            code: 'RATE_LIMIT_EXCEEDED',
            message: 'Terlalu banyak permintaan. Silakan tunggu.',
          ),
        );

        final result = await provider.sendPasswordResetEmail(
          'test@example.com',
        );
        expect(result, isFalse);
        expect(provider.isResetPasswordLoading, isFalse);
        expect(provider.errorMessage, contains('Terlalu banyak permintaan'));
      },
    );

    test('checkAuthStatus preserves session naturally on cold launch when logged in', () async {
      when(() => mockRepo.isLoggedIn()).thenAnswer((_) async => true);
      when(() => mockRepo.getRole()).thenAnswer((_) async => 'user');
      when(() => mockRepo.getUserName()).thenAnswer((_) async => 'Test User');
      when(() => mockRepo.getUserEmail())
          .thenAnswer((_) async => 'user@example.com');
      when(() => mockRepo.isBiometricAvailable()).thenAnswer((_) async => false);

      await provider.checkAuthStatus();

      expect(provider.isLoggedIn, isTrue);
      expect(provider.name, equals('Test User'));
      expect(provider.email, equals('user@example.com'));
      expect(provider.role, equals('user'));
      verifyNever(() => mockRepo.logout());
    });
  });
}
