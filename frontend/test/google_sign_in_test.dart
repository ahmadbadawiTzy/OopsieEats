import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oopsieeats/core/error_handler.dart';
import 'package:oopsieeats/data/api_client.dart';
import 'package:oopsieeats/data/repositories/auth_repository.dart';
import 'package:oopsieeats/features/auth/providers/auth_provider.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockFirebaseAuth extends Mock implements fb.FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockUserCredential extends Mock implements fb.UserCredential {}

class MockFbUser extends Mock implements fb.User {}

// ignore: subtype_of_sealed_class
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class FakeAuthCredential extends Fake implements fb.AuthCredential {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
  });

  late MockApiClient mockApiClient;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockAccount;
  late MockGoogleSignInAuthentication mockAuthTokens;
  late MockUserCredential mockUserCredential;
  late MockFbUser mockFbUser;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocRef;
  late MockDocumentSnapshot mockSnapshot;

  late AuthRepository repository;
  late AuthProvider provider;

  setUp(() {
    mockApiClient = MockApiClient();
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockGoogleSignIn = MockGoogleSignIn();
    mockAccount = MockGoogleSignInAccount();
    mockAuthTokens = MockGoogleSignInAuthentication();
    mockUserCredential = MockUserCredential();
    mockFbUser = MockFbUser();
    mockCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockSnapshot = MockDocumentSnapshot();

    when(
      () => mockGoogleSignIn.initialize(
        clientId: any(named: 'clientId'),
        serverClientId: any(named: 'serverClientId'),
        nonce: any(named: 'nonce'),
        hostedDomain: any(named: 'hostedDomain'),
      ),
    ).thenAnswer((_) async {});

    when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async {});
    when(() => mockAuth.signOut()).thenAnswer((_) async {});
    when(() => mockApiClient.clearToken()).thenAnswer((_) async {});
    when(() => mockApiClient.clearBiometricPreference())
        .thenAnswer((_) async {});
    when(() => mockApiClient.saveToken(any())).thenAnswer((_) async {});
    when(
      () => mockApiClient.saveUserSession(
        role: any(named: 'role'),
        name: any(named: 'name'),
        email: any(named: 'email'),
      ),
    ).thenAnswer((_) async {});

    repository = AuthRepository(
      mockApiClient,
      mockAuth,
      mockFirestore,
      mockGoogleSignIn,
    );
    provider = AuthProvider(repository);
  });

  group('AuthRepository.loginWithGoogle()', () {
    const testUid = 'google_uid_123';
    const testEmail = 'user@google.com';
    const testName = 'Google User';
    const testIdToken = 'mock_id_token_xyz';

    test('successfully authenticates a brand new user and creates document in users/{uid}', () async {
      when(() => mockGoogleSignIn.authenticate())
          .thenAnswer((_) async => mockAccount);
      when(() => mockAccount.authentication).thenReturn(mockAuthTokens);
      when(() => mockAuthTokens.idToken).thenReturn(testIdToken);

      when(() => mockAuth.signInWithCredential(any()))
          .thenAnswer((_) async => mockUserCredential);
      when(() => mockUserCredential.user).thenReturn(mockFbUser);
      when(() => mockFbUser.uid).thenReturn(testUid);
      when(() => mockFbUser.email).thenReturn(testEmail);
      when(() => mockFbUser.displayName).thenReturn(testName);

      when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
      when(() => mockCollection.doc(testUid)).thenReturn(mockDocRef);
      when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(false);
      when(() => mockSnapshot.data()).thenReturn(null);
      when(() => mockDocRef.set(any())).thenAnswer((_) async {});

      final result = await repository.loginWithGoogle();

      expect(result, isNotNull);
      expect(result!.email, equals(testEmail));
      expect(result.fullName, equals(testName));
      expect(result.role, equals('user'));
      expect(result.isActive, isTrue);

      verify(() => mockDocRef.set(any(that: isA<Map<String, dynamic>>())))
          .called(1);
      verify(() => mockApiClient.saveToken(testUid)).called(1);
      verify(
        () => mockApiClient.saveUserSession(
          role: 'user',
          name: testName,
          email: testEmail,
        ),
      ).called(1);
    });

    test('successfully authenticates returning user and preserves existing profile & role', () async {
      when(() => mockGoogleSignIn.authenticate())
          .thenAnswer((_) async => mockAccount);
      when(() => mockAccount.authentication).thenReturn(mockAuthTokens);
      when(() => mockAuthTokens.idToken).thenReturn(testIdToken);

      when(() => mockAuth.signInWithCredential(any()))
          .thenAnswer((_) async => mockUserCredential);
      when(() => mockUserCredential.user).thenReturn(mockFbUser);
      when(() => mockFbUser.uid).thenReturn(testUid);
      when(() => mockFbUser.email).thenReturn(testEmail);
      when(() => mockFbUser.displayName).thenReturn(testName);

      when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
      when(() => mockCollection.doc(testUid)).thenReturn(mockDocRef);
      when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn({
        'uid': testUid,
        'email': testEmail,
        'full_name': 'Custom Name In DB',
        'role': 'admin',
        'is_active': true,
      });

      final result = await repository.loginWithGoogle();

      expect(result, isNotNull);
      expect(result!.email, equals(testEmail));
      expect(result.fullName, equals('Custom Name In DB'));
      expect(result.role, equals('admin'));
      expect(result.isActive, isTrue);

      // Verify no overwrite on existing doc
      verifyNever(() => mockDocRef.set(any()));
      verify(() => mockApiClient.saveToken(testUid)).called(1);
      verify(
        () => mockApiClient.saveUserSession(
          role: 'admin',
          name: 'Custom Name In DB',
          email: testEmail,
        ),
      ).called(1);
    });

    test(
      'throws ACCOUNT_DEACTIVATED if account is marked is_active: false',
      () async {
        when(() => mockGoogleSignIn.authenticate())
            .thenAnswer((_) async => mockAccount);
        when(() => mockAccount.authentication).thenReturn(mockAuthTokens);
        when(() => mockAuthTokens.idToken).thenReturn(testIdToken);

        when(() => mockAuth.signInWithCredential(any()))
            .thenAnswer((_) async => mockUserCredential);
        when(() => mockUserCredential.user).thenReturn(mockFbUser);
        when(() => mockFbUser.uid).thenReturn(testUid);
        when(() => mockFbUser.email).thenReturn(testEmail);
        when(() => mockFbUser.displayName).thenReturn(testName);

        when(() => mockFirestore.collection('users'))
            .thenReturn(mockCollection);
        when(() => mockCollection.doc(testUid)).thenReturn(mockDocRef);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn({
          'uid': testUid,
          'email': testEmail,
          'role': 'user',
          'is_active': false,
        });

        await expectLater(
          () => repository.loginWithGoogle(),
          throwsA(
            isA<ApiException>().having(
              (e) => e.code,
              'code',
              equals('ACCOUNT_DEACTIVATED'),
            ),
          ),
        );

        // Verify sign out cleanup triggered
        verify(() => mockAuth.signOut()).called(1);
        verify(() => mockGoogleSignIn.signOut()).called(1);
      },
    );

    test(
      'returns null when user cancels account picker (cancellation handling)',
      () async {
        when(() => mockGoogleSignIn.authenticate()).thenThrow(
          const GoogleSignInException(
            code: GoogleSignInExceptionCode.canceled,
            description: 'User canceled dialog',
          ),
        );

        final result = await repository.loginWithGoogle();
        expect(result, isNull);
        verifyNever(() => mockAuth.signInWithCredential(any()));
      },
    );

    test(
      'throws GOOGLE_CONFIG_ERROR when clientConfigurationError occurs',
      () async {
        when(() => mockGoogleSignIn.authenticate()).thenThrow(
          const GoogleSignInException(
            code: GoogleSignInExceptionCode.clientConfigurationError,
            description: 'SHA-1 missing',
          ),
        );

        await expectLater(
          () => repository.loginWithGoogle(),
          throwsA(
            isA<ApiException>().having(
              (e) => e.code,
              'code',
              equals('GOOGLE_CONFIG_ERROR'),
            ),
          ),
        );
      },
    );

    test(
      'throws MISSING_ID_TOKEN when authentication tokens lack idToken',
      () async {
        when(() => mockGoogleSignIn.authenticate())
            .thenAnswer((_) async => mockAccount);
        when(() => mockAccount.authentication).thenReturn(mockAuthTokens);
        when(() => mockAuthTokens.idToken).thenReturn(null);

        await expectLater(
          () => repository.loginWithGoogle(),
          throwsA(
            isA<ApiException>().having(
              (e) => e.code,
              'code',
              equals('MISSING_ID_TOKEN'),
            ),
          ),
        );
      },
    );

    test('handles account-exists-with-different-credential cleanly', () async {
      when(() => mockGoogleSignIn.authenticate())
          .thenAnswer((_) async => mockAccount);
      when(() => mockAccount.authentication).thenReturn(mockAuthTokens);
      when(() => mockAuthTokens.idToken).thenReturn(testIdToken);

      when(() => mockAuth.signInWithCredential(any())).thenThrow(
        fb.FirebaseAuthException(
          code: 'account-exists-with-different-credential',
          message: 'Account exists',
        ),
      );

      await expectLater(
        () => repository.loginWithGoogle(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            equals('ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL'),
          ),
        ),
      );
    });

    test('handles network-request-failed cleanly', () async {
      when(() => mockGoogleSignIn.authenticate())
          .thenAnswer((_) async => mockAccount);
      when(() => mockAccount.authentication).thenReturn(mockAuthTokens);
      when(() => mockAuthTokens.idToken).thenReturn(testIdToken);

      when(() => mockAuth.signInWithCredential(any())).thenThrow(
        fb.FirebaseAuthException(
          code: 'network-request-failed',
          message: 'Connection timed out',
        ),
      );

      await expectLater(
        () => repository.loginWithGoogle(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            equals('NETWORK_ERROR'),
          ),
        ),
      );
    });

    test('logout signs out both Firebase Auth and GoogleSignIn', () async {
      await repository.logout();

      verify(() => mockAuth.signOut()).called(1);
      verify(() => mockGoogleSignIn.signOut()).called(1);
      verify(() => mockApiClient.clearToken()).called(1);
    });
  });

  group('AuthProvider.loginWithGoogle()', () {
    test('updates state and user upon successful Google login', () async {
      when(() => mockGoogleSignIn.authenticate())
          .thenAnswer((_) async => mockAccount);
      when(() => mockAccount.authentication).thenReturn(mockAuthTokens);
      when(() => mockAuthTokens.idToken).thenReturn('valid_token');
      when(() => mockAuth.signInWithCredential(any()))
          .thenAnswer((_) async => mockUserCredential);
      when(() => mockUserCredential.user).thenReturn(mockFbUser);
      when(() => mockFbUser.uid).thenReturn('uid999');
      when(() => mockFbUser.email).thenReturn('test@domain.com');
      when(() => mockFbUser.displayName).thenReturn('Test User');
      when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
      when(() => mockCollection.doc('uid999')).thenReturn(mockDocRef);
      when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn({
        'uid': 'uid999',
        'email': 'test@domain.com',
        'full_name': 'Test User',
        'role': 'user',
        'is_active': true,
      });

      expect(provider.isGoogleLoading, isFalse);
      expect(provider.isLoading, isFalse);

      final user = await provider.loginWithGoogle();

      expect(user, isNotNull);
      expect(provider.isLoggedIn, isTrue);
      expect(provider.currentUser?.email, equals('test@domain.com'));
      expect(provider.isGoogleLoading, isFalse);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('resets loading and does not set error on cancellation', () async {
      when(() => mockGoogleSignIn.authenticate()).thenThrow(
        const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
      );

      final user = await provider.loginWithGoogle();

      expect(user, isNull);
      expect(provider.isLoggedIn, isFalse);
      expect(provider.isGoogleLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('sets friendly error message on failure', () async {
      when(() => mockGoogleSignIn.authenticate()).thenThrow(
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.clientConfigurationError,
        ),
      );

      final user = await provider.loginWithGoogle();

      expect(user, isNull);
      expect(provider.isLoggedIn, isFalse);
      expect(provider.isGoogleLoading, isFalse);
      expect(provider.errorMessage, isNotNull);
      expect(provider.errorMessage, contains('Google Sign-In tidak valid'));
    });
  });
}
