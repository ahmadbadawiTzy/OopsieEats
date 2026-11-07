import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/data/api_client.dart';
import 'package:nutriview/data/models/user.dart';
import 'package:nutriview/data/repositories/auth_repository.dart';
import 'package:nutriview/data/services/biometric_service.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockApiClient extends Mock implements ApiClient {}

class MockFirebaseAuth extends Mock implements fb.FirebaseAuth {}

class MockUser extends Mock implements fb.User {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

// ignore: subtype_of_sealed_class
class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockBiometricService extends Mock implements BiometricService {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('BiometricService Unit Tests', () {
    late MockLocalAuthentication mockLocalAuth;
    late BiometricService biometricService;

    setUp(() {
      mockLocalAuth = MockLocalAuthentication();
      biometricService = BiometricService(mockLocalAuth);
    });

    test('isDeviceSupported returns result from LocalAuthentication', () async {
      when(() => mockLocalAuth.isDeviceSupported())
          .thenAnswer((_) async => true);
      expect(await biometricService.isDeviceSupported(), isTrue);

      when(() => mockLocalAuth.isDeviceSupported())
          .thenAnswer((_) async => false);
      expect(await biometricService.isDeviceSupported(), isFalse);
    });

    test(
      'canCheckBiometrics returns result from LocalAuthentication',
      () async {
        when(() => mockLocalAuth.canCheckBiometrics)
            .thenAnswer((_) async => true);
        expect(await biometricService.canCheckBiometrics(), isTrue);
      },
    );

    test('getAvailableBiometrics returns list of BiometricType', () async {
      when(() => mockLocalAuth.getAvailableBiometrics()).thenAnswer(
        (_) async => [BiometricType.fingerprint, BiometricType.face],
      );

      final result = await biometricService.getAvailableBiometrics();
      expect(result, contains(BiometricType.fingerprint));
      expect(result, contains(BiometricType.face));
      expect(await biometricService.hasFingerprint(), isTrue);
      expect(await biometricService.hasFace(), isTrue);
    });

    test('isBiometricAvailable returns true only when supported, checkable, and non-empty', () async {
      when(() => mockLocalAuth.isDeviceSupported())
          .thenAnswer((_) async => true);
      when(() => mockLocalAuth.canCheckBiometrics)
          .thenAnswer((_) async => true);
      when(() => mockLocalAuth.getAvailableBiometrics())
          .thenAnswer((_) async => [BiometricType.fingerprint]);

      expect(await biometricService.isBiometricAvailable(), isTrue);

      when(() => mockLocalAuth.getAvailableBiometrics())
          .thenAnswer((_) async => []);
      expect(await biometricService.isBiometricAvailable(), isFalse);
    });

    test(
      'authenticate passes localizedReason and returns true on success',
      () async {
        when(
          () => mockLocalAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            biometricOnly: any(named: 'biometricOnly'),
            persistAcrossBackgrounding: any(
              named: 'persistAcrossBackgrounding',
            ),
          ),
        ).thenAnswer((_) async => true);

        final result = await biometricService.authenticate(
          localizedReason: 'Pindai sidik jari',
        );
        expect(result, isTrue);
      },
    );
  });

  group('ApiClient Biometric Preference Storage Tests', () {
    late MockFlutterSecureStorage mockStorage;
    late ApiClient apiClient;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      apiClient = ApiClient(storage: mockStorage);
    });

    test('isBiometricEnabled defaults to false (opt-in requirement)', () async {
      when(() => mockStorage.read(key: 'nutriview_biometric_enabled'))
          .thenAnswer((_) async => null);
      expect(await apiClient.isBiometricEnabled(), isFalse);
    });

    test('saveBiometricEnabled persists true/false', () async {
      when(
        () => mockStorage.write(
          key: 'nutriview_biometric_enabled',
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      await apiClient.saveBiometricEnabled(true);
      verify(
        () => mockStorage.write(
          key: 'nutriview_biometric_enabled',
          value: 'true',
        ),
      ).called(1);

      await apiClient.saveBiometricEnabled(false);
      verify(
        () => mockStorage.write(
          key: 'nutriview_biometric_enabled',
          value: 'false',
        ),
      ).called(1);
    });

    test('saveBiometricEmail and getBiometricEmail roundtrip', () async {
      when(
        () => mockStorage.write(
          key: 'nutriview_biometric_user_email',
          value: 'user@example.com',
        ),
      ).thenAnswer((_) async {});
      when(() => mockStorage.read(key: 'nutriview_biometric_user_email'))
          .thenAnswer((_) async => 'user@example.com');

      await apiClient.saveBiometricEmail('user@example.com');
      final email = await apiClient.getBiometricEmail();
      expect(email, equals('user@example.com'));
    });

    test('saveBiometricUid and getBiometricUid roundtrip', () async {
      when(
        () => mockStorage.write(
          key: 'nutriview_biometric_uid',
          value: 'user_uid_123',
        ),
      ).thenAnswer((_) async {});
      when(() => mockStorage.read(key: 'nutriview_biometric_uid'))
          .thenAnswer((_) async => 'user_uid_123');

      await apiClient.saveBiometricUid('user_uid_123');
      final uid = await apiClient.getBiometricUid();
      expect(uid, equals('user_uid_123'));
    });

    test('saveBiometricPrompted and hasPromptedBiometric roundtrip', () async {
      when(
        () => mockStorage.write(
          key: 'nutriview_biometric_prompted',
          value: 'true',
        ),
      ).thenAnswer((_) async {});
      when(() => mockStorage.read(key: 'nutriview_biometric_prompted'))
          .thenAnswer((_) async => 'true');

      await apiClient.saveBiometricPrompted(true);
      final prompted = await apiClient.hasPromptedBiometric();
      expect(prompted, isTrue);
    });

    test('clearBiometricPreference removes all 4 biometric keys', () async {
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      await apiClient.clearBiometricPreference();
      verify(() => mockStorage.delete(key: 'nutriview_biometric_enabled'))
          .called(1);
      verify(() => mockStorage.delete(key: 'nutriview_biometric_user_email'))
          .called(1);
      verify(() => mockStorage.delete(key: 'nutriview_biometric_uid'))
          .called(1);
      verify(() => mockStorage.delete(key: 'nutriview_biometric_prompted'))
          .called(1);
    });
  });

  group('AuthRepository Biometric Authentication Tests', () {
    late MockApiClient mockApiClient;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockBiometricService mockBiometricService;
    late AuthRepository repository;
    late MockUser mockFirebaseUser;
    late MockCollectionReference mockUsersCollection;
    late MockDocumentReference mockUserDoc;
    late MockDocumentSnapshot mockSnapshot;

    setUp(() {
      mockApiClient = MockApiClient();
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockBiometricService = MockBiometricService();
      mockFirebaseUser = MockUser();
      mockUsersCollection = MockCollectionReference();
      mockUserDoc = MockDocumentReference();
      mockSnapshot = MockDocumentSnapshot();

      when(() => mockFirestore.collection('users'))
          .thenReturn(mockUsersCollection);
      when(() => mockUsersCollection.doc(any())).thenReturn(mockUserDoc);

      when(() => mockFirebaseUser.uid).thenReturn('user_uid_123');
      when(() => mockFirebaseUser.email).thenReturn('budi@nutriview.com');
      when(() => mockFirebaseUser.displayName).thenReturn('Budi Santoso');

      when(() => mockApiClient.getBiometricUid())
          .thenAnswer((_) async => 'user_uid_123');
      when(() => mockApiClient.saveBiometricUid(any()))
          .thenAnswer((_) async {});
      when(() => mockApiClient.saveBiometricEmail(any()))
          .thenAnswer((_) async {});
      when(() => mockApiClient.saveBiometricEnabled(any()))
          .thenAnswer((_) async {});
      when(() => mockApiClient.saveBiometricPrompted(any()))
          .thenAnswer((_) async {});

      repository = AuthRepository(
        mockApiClient,
        mockAuth,
        mockFirestore,
        null,
        mockBiometricService,
      );
    });

    test(
      'setBiometricEnabled throws UNAUTHORIZED if currentUser is null',
      () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        await expectLater(
          () => repository.setBiometricEnabled(true),
          throwsA(
            isA<ApiException>().having((e) => e.code, 'code', 'UNAUTHORIZED'),
          ),
        );
      },
    );

    test('setBiometricEnabled saves email, uid, enabled, and prompted when user logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(mockFirebaseUser);

      await repository.setBiometricEnabled(true);
      verify(() => mockApiClient.saveBiometricEmail('budi@nutriview.com'))
          .called(1);
      verify(() => mockApiClient.saveBiometricUid('user_uid_123')).called(1);
      verify(() => mockApiClient.saveBiometricEnabled(true)).called(1);
      verify(() => mockApiClient.saveBiometricPrompted(true)).called(1);
    });

    test('setBiometricEnabled(false) clears preference', () async {
      when(() => mockApiClient.clearBiometricPreference())
          .thenAnswer((_) async {});

      await repository.setBiometricEnabled(false);
      verify(() => mockApiClient.clearBiometricPreference()).called(1);
    });

    test('authenticateWithBiometrics throws BIOMETRIC_UNAVAILABLE when not available', () async {
      when(() => mockBiometricService.isBiometricAvailable())
          .thenAnswer((_) async => false);

      await expectLater(
        () => repository.authenticateWithBiometrics(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            'BIOMETRIC_UNAVAILABLE',
          ),
        ),
      );
    });

    test('authenticateWithBiometrics throws BIOMETRIC_NOT_ENABLED when not enabled', () async {
      when(() => mockBiometricService.isBiometricAvailable())
          .thenAnswer((_) async => true);
      when(() => mockApiClient.isBiometricEnabled())
          .thenAnswer((_) async => false);

      await expectLater(
        () => repository.authenticateWithBiometrics(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            'BIOMETRIC_NOT_ENABLED',
          ),
        ),
      );
    });

    test('authenticateWithBiometrics throws SESSION_EXPIRED when Firebase session is dead', () async {
      when(() => mockBiometricService.isBiometricAvailable())
          .thenAnswer((_) async => true);
      when(() => mockApiClient.isBiometricEnabled())
          .thenAnswer((_) async => true);
      when(() => mockAuth.currentUser).thenReturn(null);
      when(() => mockApiClient.clearBiometricPreference())
          .thenAnswer((_) async {});

      await expectLater(
        () => repository.authenticateWithBiometrics(),
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'SESSION_EXPIRED'),
        ),
      );
      verify(() => mockApiClient.clearBiometricPreference()).called(1);
    });

    test('authenticateWithBiometrics throws BIOMETRIC_ACCOUNT_MISMATCH on UID mismatch', () async {
      when(() => mockBiometricService.isBiometricAvailable())
          .thenAnswer((_) async => true);
      when(() => mockApiClient.isBiometricEnabled())
          .thenAnswer((_) async => true);
      when(() => mockAuth.currentUser).thenReturn(mockFirebaseUser);
      when(() => mockApiClient.getBiometricUid())
          .thenAnswer((_) async => 'different_uid_999');
      when(() => mockApiClient.clearBiometricPreference())
          .thenAnswer((_) async {});

      await expectLater(
        () => repository.authenticateWithBiometrics(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            'BIOMETRIC_ACCOUNT_MISMATCH',
          ),
        ),
      );
      verify(() => mockApiClient.clearBiometricPreference()).called(1);
    });

    test('authenticateWithBiometrics throws BIOMETRIC_ACCOUNT_MISMATCH on email mismatch', () async {
      when(() => mockBiometricService.isBiometricAvailable())
          .thenAnswer((_) async => true);
      when(() => mockApiClient.isBiometricEnabled())
          .thenAnswer((_) async => true);
      when(() => mockAuth.currentUser).thenReturn(mockFirebaseUser);
      when(() => mockApiClient.getBiometricUid())
          .thenAnswer((_) async => 'user_uid_123');
      when(() => mockApiClient.getBiometricEmail())
          .thenAnswer((_) async => 'other_user@nutriview.com');
      when(() => mockApiClient.clearBiometricPreference())
          .thenAnswer((_) async {});

      await expectLater(
        () => repository.authenticateWithBiometrics(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            'BIOMETRIC_ACCOUNT_MISMATCH',
          ),
        ),
      );
      verify(() => mockApiClient.clearBiometricPreference()).called(1);
    });

    test('authenticateWithBiometrics throws BIOMETRIC_CANCELLED when prompt cancelled', () async {
      when(() => mockBiometricService.isBiometricAvailable())
          .thenAnswer((_) async => true);
      when(() => mockApiClient.isBiometricEnabled())
          .thenAnswer((_) async => true);
      when(() => mockAuth.currentUser).thenReturn(mockFirebaseUser);
      when(() => mockApiClient.getBiometricUid())
          .thenAnswer((_) async => 'user_uid_123');
      when(() => mockApiClient.getBiometricEmail())
          .thenAnswer((_) async => 'budi@nutriview.com');
      when(
        () => mockBiometricService.authenticate(
          localizedReason: any(named: 'localizedReason'),
        ),
      ).thenAnswer((_) async => false);

      await expectLater(
        () => repository.authenticateWithBiometrics(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            'BIOMETRIC_CANCELLED',
          ),
        ),
      );
    });

    test(
      'authenticateWithBiometrics succeeds and returns User on valid auth',
      () async {
        when(() => mockBiometricService.isBiometricAvailable())
            .thenAnswer((_) async => true);
        when(() => mockApiClient.isBiometricEnabled())
            .thenAnswer((_) async => true);
        when(() => mockAuth.currentUser).thenReturn(mockFirebaseUser);
        when(() => mockApiClient.getBiometricUid())
            .thenAnswer((_) async => 'user_uid_123');
        when(() => mockApiClient.getBiometricEmail())
            .thenAnswer((_) async => 'budi@nutriview.com');
        when(
          () => mockBiometricService.authenticate(
            localizedReason: any(named: 'localizedReason'),
          ),
        ).thenAnswer((_) async => true);

        when(() => mockUserDoc.get()).thenAnswer((_) async => mockSnapshot);
        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn({
          'role': 'user',
          'full_name': 'Budi Santoso',
          'is_active': true,
        });

        when(() => mockApiClient.saveToken(any())).thenAnswer((_) async {});
        when(
          () => mockApiClient.saveUserSession(
            role: any(named: 'role'),
            name: any(named: 'name'),
            email: any(named: 'email'),
          ),
        ).thenAnswer((_) async {});

        final user = await repository.authenticateWithBiometrics();
        expect(user.email, equals('budi@nutriview.com'));
        expect(user.fullName, equals('Budi Santoso'));
        expect(user.role, equals('user'));
        verify(() => mockApiClient.saveToken('user_uid_123')).called(1);
      },
    );

    test('logout clears biometric preference and local token', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});
      when(() => mockApiClient.clearBiometricPreference())
          .thenAnswer((_) async {});
      when(() => mockApiClient.clearToken()).thenAnswer((_) async {});

      await repository.logout();
      verify(() => mockApiClient.clearBiometricPreference()).called(1);
      verify(() => mockApiClient.clearToken()).called(1);
    });
  });

  group('AuthProvider State Machine & Biometric Tests', () {
    late MockAuthRepository mockRepo;
    late AuthProvider authProvider;

    setUp(() {
      mockRepo = MockAuthRepository();
      authProvider = AuthProvider(mockRepo);
    });

    test('initial state is uninitialized', () {
      expect(authProvider.state, equals(AuthLifecycleState.uninitialized));
    });

    test('checkAuthStatus gates session in biometricLocked when biometric is enabled', () async {
      when(() => mockRepo.isLoggedIn()).thenAnswer((_) async => true);
      when(() => mockRepo.getRole()).thenAnswer((_) async => 'user');
      when(() => mockRepo.getUserName())
          .thenAnswer((_) async => 'Budi Santoso');
      when(() => mockRepo.getUserEmail())
          .thenAnswer((_) async => 'budi@nutriview.com');
      when(() => mockRepo.isBiometricAvailable()).thenAnswer((_) async => true);
      when(() => mockRepo.getAvailableBiometrics())
          .thenAnswer((_) async => [BiometricType.fingerprint]);
      when(() => mockRepo.isBiometricEnabled()).thenAnswer((_) async => true);
      when(() => mockRepo.hasPromptedBiometric()).thenAnswer((_) async => true);

      await authProvider.checkAuthStatus();

      expect(authProvider.isLoggedIn, isTrue);
      expect(authProvider.state, equals(AuthLifecycleState.biometricLocked));
      expect(authProvider.isBiometricLocked, isTrue);
    });

    test('checkAuthStatus marks authenticated directly when biometric is not enabled', () async {
      when(() => mockRepo.isLoggedIn()).thenAnswer((_) async => true);
      when(() => mockRepo.getRole()).thenAnswer((_) async => 'user');
      when(() => mockRepo.getUserName())
          .thenAnswer((_) async => 'Budi Santoso');
      when(() => mockRepo.getUserEmail())
          .thenAnswer((_) async => 'budi@nutriview.com');
      when(() => mockRepo.isBiometricAvailable()).thenAnswer((_) async => true);
      when(() => mockRepo.getAvailableBiometrics())
          .thenAnswer((_) async => [BiometricType.fingerprint]);
      when(() => mockRepo.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockRepo.hasPromptedBiometric())
          .thenAnswer((_) async => false);

      await authProvider.checkAuthStatus();

      expect(authProvider.isLoggedIn, isTrue);
      expect(authProvider.state, equals(AuthLifecycleState.authenticated));
      expect(authProvider.isBiometricLocked, isFalse);
    });

    test('unlockWithPasswordInstead switches state from biometricLocked to passwordFallback', () async {
      when(() => mockRepo.isLoggedIn()).thenAnswer((_) async => true);
      when(() => mockRepo.getRole()).thenAnswer((_) async => 'user');
      when(() => mockRepo.getUserName()).thenAnswer((_) async => 'Budi');
      when(() => mockRepo.getUserEmail())
          .thenAnswer((_) async => 'budi@nutriview.com');
      when(() => mockRepo.isBiometricAvailable()).thenAnswer((_) async => true);
      when(() => mockRepo.getAvailableBiometrics())
          .thenAnswer((_) async => [BiometricType.fingerprint]);
      when(() => mockRepo.isBiometricEnabled()).thenAnswer((_) async => true);
      when(() => mockRepo.hasPromptedBiometric()).thenAnswer((_) async => true);

      await authProvider.checkAuthStatus();
      expect(authProvider.isBiometricLocked, isTrue);

      authProvider.unlockWithPasswordInstead();
      expect(authProvider.state, equals(AuthLifecycleState.passwordFallback));
      expect(authProvider.isPasswordFallback, isTrue);
      expect(authProvider.isBiometricLocked, isFalse);
    });

    test('checkBiometricAvailability loads state from repository', () async {
      when(() => mockRepo.isBiometricAvailable()).thenAnswer((_) async => true);
      when(() => mockRepo.getAvailableBiometrics())
          .thenAnswer((_) async => [BiometricType.fingerprint]);
      when(() => mockRepo.isBiometricEnabled()).thenAnswer((_) async => true);
      when(() => mockRepo.hasPromptedBiometric()).thenAnswer((_) async => true);

      await authProvider.checkBiometricAvailability();

      expect(authProvider.isBiometricAvailable, isTrue);
      expect(authProvider.isBiometricEnabled, isTrue);
      expect(authProvider.hasPromptedBiometric, isTrue);
      expect(authProvider.hasFingerprint, isTrue);
      expect(authProvider.hasFace, isFalse);
    });

    test(
      'setBiometricEnabled updates preference and notifies listeners',
      () async {
        when(() => mockRepo.setBiometricEnabled(true)).thenAnswer((_) async {});

        final success = await authProvider.setBiometricEnabled(true);
        expect(success, isTrue);
        expect(authProvider.isBiometricEnabled, isTrue);

        when(() => mockRepo.setBiometricEnabled(false))
            .thenAnswer((_) async {});
        final successDisable = await authProvider.setBiometricEnabled(false);
        expect(successDisable, isTrue);
        expect(authProvider.isBiometricEnabled, isFalse);
      },
    );

    test('logout resets state to unauthenticated and clears session', () async {
      when(() => mockRepo.logout()).thenAnswer((_) async {});

      await authProvider.logout();
      expect(authProvider.state, equals(AuthLifecycleState.unauthenticated));
      expect(authProvider.isBiometricEnabled, isFalse);
      expect(authProvider.isLoggedIn, isFalse);
    });

    test(
      'switchAccount clears session and resets state to unauthenticated',
      () async {
        when(() => mockRepo.logout()).thenAnswer((_) async {});

        await authProvider.switchAccount();
        expect(authProvider.state, equals(AuthLifecycleState.unauthenticated));
        expect(authProvider.isBiometricLocked, isFalse);
        expect(authProvider.isLoggedIn, isFalse);
        expect(authProvider.isBiometricEligible, isFalse);
        verify(() => mockRepo.logout()).called(1);
      },
    );

    test(
      'returnToBiometricLock returns to biometricLocked only if eligible',
      () async {
        // Ineligible initially
        authProvider.returnToBiometricLock();
        expect(authProvider.isBiometricLocked, isFalse);

        // Now set up eligible session
        when(() => mockRepo.isLoggedIn()).thenAnswer((_) async => true);
        when(() => mockRepo.getRole()).thenAnswer((_) async => 'user');
        when(() => mockRepo.getUserName()).thenAnswer((_) async => 'Budi');
        when(() => mockRepo.getUserEmail())
            .thenAnswer((_) async => 'budi@test.com');
        when(() => mockRepo.isBiometricAvailable())
            .thenAnswer((_) async => true);
        when(() => mockRepo.getAvailableBiometrics())
            .thenAnswer((_) async => [BiometricType.fingerprint]);
        when(() => mockRepo.isBiometricEnabled()).thenAnswer((_) async => true);
        when(() => mockRepo.hasPromptedBiometric())
            .thenAnswer((_) async => true);

        await authProvider.checkAuthStatus();
        expect(authProvider.isBiometricLocked, isTrue);

        // User chooses password fallback
        authProvider.unlockWithPasswordInstead();
        expect(authProvider.state, equals(AuthLifecycleState.passwordFallback));
        expect(authProvider.isBiometricEligible, isTrue);

        // User returns to biometric lock
        authProvider.returnToBiometricLock();
        expect(authProvider.isBiometricLocked, isTrue);
        expect(authProvider.state, equals(AuthLifecycleState.biometricLocked));
      },
    );

    test('verifyPasswordFallback succeeds on valid password and routes user role', () async {
      when(() => mockRepo.verifyPasswordFallback('mypassword123')).thenAnswer(
        (_) async => User(
          id: 10,
          email: 'budi@nutriview.com',
          fullName: 'Budi Santoso',
          role: 'user',
        ),
      );

      final user = await authProvider.verifyPasswordFallback('mypassword123');
      expect(user, isNotNull);
      expect(user?.email, equals('budi@nutriview.com'));
      expect(authProvider.role, equals('user'));
      expect(authProvider.isAdmin, isFalse);
      expect(authProvider.state, equals(AuthLifecycleState.authenticated));
      expect(authProvider.errorMessage, isNull);
    });

    test('verifyPasswordFallback succeeds on valid password and routes admin role', () async {
      when(() => mockRepo.verifyPasswordFallback('adminsecret')).thenAnswer(
        (_) async => User(
          id: 1,
          email: 'admin@nutriview.com',
          fullName: 'Super Admin',
          role: 'admin',
        ),
      );

      final user = await authProvider.verifyPasswordFallback('adminsecret');
      expect(user, isNotNull);
      expect(user?.role, equals('admin'));
      expect(authProvider.isAdmin, isTrue);
      expect(authProvider.state, equals(AuthLifecycleState.authenticated));
    });

    test('verifyPasswordFallback with wrong password preserves passwordFallback state and displays error', () async {
      when(() => mockRepo.verifyPasswordFallback('wrongpass')).thenThrow(
        ApiException(
          statusCode: 401,
          code: 'WRONG_PASSWORD',
          message: 'Kata sandi salah. Silakan coba lagi.',
        ),
      );

      final user = await authProvider.verifyPasswordFallback('wrongpass');
      expect(user, isNull);
      expect(authProvider.state, equals(AuthLifecycleState.passwordFallback));
      expect(authProvider.errorMessage, equals('Kata sandi salah. Silakan coba lagi.'));
    });

    test('verifyPasswordFallback with empty password rejects immediately without hitting repository', () async {
      authProvider.switchToPasswordFallback();
      final user = await authProvider.verifyPasswordFallback('   ');
      expect(user, isNull);
      expect(authProvider.state, equals(AuthLifecycleState.passwordFallback));
      expect(authProvider.errorMessage, equals('Kata sandi wajib diisi.'));
      verifyNever(() => mockRepo.verifyPasswordFallback(any()));
    });

    test('verifyPasswordFallback on session expired resets session and marks sessionExpired', () async {
      when(() => mockRepo.verifyPasswordFallback('anypass')).thenThrow(
        ApiException(
          statusCode: 401,
          code: 'SESSION_EXPIRED',
          message: 'Sesi login telah berakhir. Silakan masuk kembali.',
        ),
      );

      final user = await authProvider.verifyPasswordFallback('anypass');
      expect(user, isNull);
      expect(authProvider.state, equals(AuthLifecycleState.sessionExpired));
      expect(authProvider.isLoggedIn, isFalse);
    });
  });
}
