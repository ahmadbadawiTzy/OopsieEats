import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:oopsieeats/core/error_handler.dart';
import 'package:oopsieeats/core/routes.dart';
import 'package:oopsieeats/core/theme.dart';
import 'package:oopsieeats/data/api_client.dart';
import 'package:oopsieeats/data/models/profile.dart';
import 'package:oopsieeats/data/models/user.dart';
import 'package:oopsieeats/data/repositories/auth_repository.dart';
import 'package:oopsieeats/data/repositories/dashboard_repository.dart';
import 'package:oopsieeats/data/repositories/meal_repository.dart';
import 'package:oopsieeats/data/repositories/profile_repository.dart';
import 'package:oopsieeats/features/auth/providers/auth_provider.dart';
import 'package:oopsieeats/features/dashboard/providers/dashboard_provider.dart';
import 'package:oopsieeats/features/meals/providers/meal_history_provider.dart';
import 'package:oopsieeats/features/profile/providers/profile_provider.dart';
import 'package:oopsieeats/features/profile/screens/profile_screen.dart';
import 'package:oopsieeats/shared/neo/neo_button.dart';

// --- Mocks ---
class MockApiClient extends Mock implements ApiClient {}

class MockFirebaseAuth extends Mock implements fb.FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockUser extends Mock implements fb.User {}

class MockUserMetadata extends Mock implements fb.UserMetadata {}

class MockAuthCredential extends Mock implements fb.AuthCredential {}

// ignore: subtype_of_sealed_class
class MockCollectionReference<T extends Object?> extends Mock
    implements CollectionReference<T> {}

// ignore: subtype_of_sealed_class
class MockDocumentReference<T extends Object?> extends Mock
    implements DocumentReference<T> {}

// ignore: subtype_of_sealed_class
class MockQuerySnapshot<T extends Object?> extends Mock
    implements QuerySnapshot<T> {}

// ignore: subtype_of_sealed_class
class MockQueryDocumentSnapshot<T extends Object?> extends Mock
    implements QueryDocumentSnapshot<T> {}

class MockWriteBatch extends Mock implements WriteBatch {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockMealRepository extends Mock implements MealRepository {}

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
    registerFallbackValue(MockAuthCredential());
    registerFallbackValue(MockDocumentReference<Map<String, dynamic>>());
  });

  group('AuthRepository.deleteAccount Unit Tests', () {
    late MockApiClient mockApiClient;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockUser mockUser;
    late MockUserMetadata mockMetadata;
    late MockCollectionReference<Map<String, dynamic>> mockUsersCollection;
    late MockDocumentReference<Map<String, dynamic>> mockUserDoc;
    late MockCollectionReference<Map<String, dynamic>> mockMealsCollection;
    late MockCollectionReference<Map<String, dynamic>> mockProfilesCollection;
    late MockDocumentReference<Map<String, dynamic>> mockProfileDoc;
    late MockQuerySnapshot<Map<String, dynamic>> mockMealsSnapshot;
    late MockWriteBatch mockWriteBatch;
    late AuthRepository authRepository;

    const testUid = 'user_abc_123';
    const testEmail = 'user@example.com';

    setUp(() {
      mockApiClient = MockApiClient();
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockUser = MockUser();
      mockMetadata = MockUserMetadata();
      mockUsersCollection = MockCollectionReference<Map<String, dynamic>>();
      mockUserDoc = MockDocumentReference<Map<String, dynamic>>();
      mockMealsCollection = MockCollectionReference<Map<String, dynamic>>();
      mockProfilesCollection = MockCollectionReference<Map<String, dynamic>>();
      mockProfileDoc = MockDocumentReference<Map<String, dynamic>>();
      mockMealsSnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      mockWriteBatch = MockWriteBatch();

      when(() => mockApiClient.clearToken()).thenAnswer((_) async {});
      when(() => mockApiClient.clearBiometricPreference())
          .thenAnswer((_) async {});

      when(() => mockUser.uid).thenReturn(testUid);
      when(() => mockUser.email).thenReturn(testEmail);
      when(() => mockUser.metadata).thenReturn(mockMetadata);
      when(() => mockUser.delete()).thenAnswer((_) async {});
      when(() => mockUser.providerData).thenReturn([]);

      when(() => mockAuth.currentUser).thenReturn(mockUser);

      when(() => mockFirestore.collection('users'))
          .thenReturn(mockUsersCollection);
      when(() => mockFirestore.collection('profiles'))
          .thenReturn(mockProfilesCollection);
      when(() => mockUsersCollection.doc(testUid)).thenReturn(mockUserDoc);
      when(() => mockProfilesCollection.doc(testUid))
          .thenReturn(mockProfileDoc);
      when(() => mockUserDoc.collection('meals'))
          .thenReturn(mockMealsCollection);

      when(() => mockMealsCollection.get())
          .thenAnswer((_) async => mockMealsSnapshot);
      when(() => mockMealsSnapshot.docs).thenReturn([]);
      when(() => mockUserDoc.delete()).thenAnswer((_) async {});
      when(() => mockProfileDoc.delete()).thenAnswer((_) async {});

      when(() => mockFirestore.batch()).thenReturn(mockWriteBatch);
      when(() => mockWriteBatch.commit()).thenAnswer((_) async {});

      authRepository = AuthRepository(mockApiClient, mockAuth, mockFirestore);
    });

    test(
      'deletes account and cleans data when session is fresh (< 5 mins)',
      () async {
        // Last sign in: 1 minute ago
        when(() => mockMetadata.lastSignInTime)
            .thenReturn(DateTime.now().subtract(const Duration(minutes: 1)));

        final mockMealDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        final mockMealDocRef = MockDocumentReference<Map<String, dynamic>>();
        when(() => mockMealDoc.reference).thenReturn(mockMealDocRef);
        when(() => mockMealsSnapshot.docs).thenReturn([mockMealDoc]);
        // ignore: void_checks
        when(() => mockWriteBatch.delete(mockMealDocRef)).thenReturn(null);

        await authRepository.deleteAccount();

        // Verify meals deleted in batch
        verify(() => mockWriteBatch.delete(mockMealDocRef)).called(1);
        verify(() => mockWriteBatch.commit()).called(1);
        // Verify user document deleted
        verify(() => mockUserDoc.delete()).called(1);
        // Verify auth user deleted
        verify(() => mockUser.delete()).called(1);
        // Verify token cleared
        verify(() => mockApiClient.clearToken()).called(1);
      },
    );

    test('throws REQUIRES_RECENT_LOGIN and preserves data if session > 5 mins without password', () async {
      // Last sign in: 10 minutes ago
      when(() => mockMetadata.lastSignInTime)
          .thenReturn(DateTime.now().subtract(const Duration(minutes: 10)));

      expect(
        () => authRepository.deleteAccount(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            'REQUIRES_RECENT_LOGIN',
          ),
        ),
      );

      // Verify NO data was deleted
      verifyNever(() => mockUserDoc.delete());
      verifyNever(() => mockUser.delete());
      // Verify local token was NOT prematurely wiped
      verifyNever(() => mockApiClient.clearToken());
    });

    test(
      'reauthenticates and deletes data when password is provided',
      () async {
        when(() => mockUser.reauthenticateWithCredential(any()))
            .thenAnswer((_) async => MockUserCredential());

        await authRepository.deleteAccount(password: 'MyValidPassword123!');

        verify(() => mockUser.reauthenticateWithCredential(any())).called(1);
        verify(() => mockUserDoc.delete()).called(1);
        verify(() => mockUser.delete()).called(1);
        verify(() => mockApiClient.clearToken()).called(1);
      },
    );

    test(
      'throws WRONG_PASSWORD and preserves data if reauthentication fails',
      () async {
        when(() => mockUser.reauthenticateWithCredential(any()))
            .thenThrow(fb.FirebaseAuthException(code: 'wrong-password'));

        expect(
          () => authRepository.deleteAccount(password: 'WrongPassword'),
          throwsA(
            isA<ApiException>().having((e) => e.code, 'code', 'WRONG_PASSWORD'),
          ),
        );

        verifyNever(() => mockUserDoc.delete());
        verifyNever(() => mockUser.delete());
        verifyNever(() => mockApiClient.clearToken());
      },
    );

    test(
      'aborts without deleting auth user if Firestore cleanup fails',
      () async {
        when(() => mockMetadata.lastSignInTime).thenReturn(DateTime.now());
        when(() => mockUserDoc.delete())
            .thenThrow(Exception('Firestore error'));

        expect(
          () => authRepository.deleteAccount(),
          throwsA(
            isA<ApiException>().having(
              (e) => e.code,
              'code',
              'FIRESTORE_CLEANUP_FAILED',
            ),
          ),
        );

        verifyNever(() => mockUser.delete());
        verifyNever(() => mockApiClient.clearToken());
      },
    );
  });

  group('AuthProvider.deleteAccount Unit Tests', () {
    late MockAuthRepository mockAuthRepository;
    late AuthProvider authProvider;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      authProvider = AuthProvider(mockAuthRepository);
    });

    test('returns true and resets user state on success', () async {
      when(
        () =>
            mockAuthRepository.deleteAccount(password: any(named: 'password')),
      ).thenAnswer((_) async {});

      final result = await authProvider.deleteAccount();

      expect(result, isTrue);
      expect(authProvider.isLoggedIn, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.errorMessage, isNull);
      expect(authProvider.errorCode, isNull);
    });

    test(
      'returns false and records errorCode on REQUIRES_RECENT_LOGIN',
      () async {
        when(
          () => mockAuthRepository.deleteAccount(
            password: any(named: 'password'),
          ),
        ).thenThrow(
          ApiException(
            statusCode: 401,
            code: 'REQUIRES_RECENT_LOGIN',
            message: 'Masukkan kata sandi.',
          ),
        );

        final result = await authProvider.deleteAccount();

        expect(result, isFalse);
        expect(authProvider.errorCode, 'REQUIRES_RECENT_LOGIN');
        expect(authProvider.errorMessage, 'Masukkan kata sandi.');
      },
    );
  });

  group('ProfileScreen Account Deletion Widget Tests', () {
    late MockAuthRepository mockAuthRepo;
    late MockProfileRepository mockProfileRepo;
    late MockMealRepository mockMealRepo;
    late MockDashboardRepository mockDashboardRepo;
    late AuthProvider authProvider;
    late ProfileProvider profileProvider;
    late MealHistoryProvider mealHistoryProvider;
    late DashboardProvider dashboardProvider;

    final testUser = User(
      id: 1,
      email: 'ahmad@example.com',
      fullName: 'Ahmad Badawi',
      role: 'user',
      isActive: true,
      avatarPreset: 'champion',
      profile: UserProfile(
        age: 23,
        sex: 'male',
        weightKg: 70,
        heightCm: 175,
        activityLevel: 'moderate',
        goal: 'maintain',
      ),
    );

    setUp(() {
      mockAuthRepo = MockAuthRepository();
      mockProfileRepo = MockProfileRepository();
      mockMealRepo = MockMealRepository();
      mockDashboardRepo = MockDashboardRepository();

      when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => true);
      when(() => mockAuthRepo.getRole()).thenAnswer((_) async => 'user');
      when(() => mockAuthRepo.getUserName())
          .thenAnswer((_) async => 'Ahmad Badawi');
      when(() => mockAuthRepo.getUserEmail())
          .thenAnswer((_) async => 'ahmad@example.com');
      when(() => mockAuthRepo.logout()).thenAnswer((_) async {});
      when(() => mockAuthRepo.getSignInProviders()).thenReturn(['password']);
      when(() => mockAuthRepo.hasPasswordProvider()).thenReturn(true);
      when(() => mockAuthRepo.hasGoogleProvider()).thenReturn(false);
      when(() => mockAuthRepo.getPrimaryProviderId()).thenReturn('password');

      when(() => mockProfileRepo.getUser()).thenAnswer((_) async => testUser);
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

      when(
        () => mockMealRepo.getMeals(
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => []);

      authProvider = AuthProvider(mockAuthRepo);
      profileProvider = ProfileProvider(mockProfileRepo);
      mealHistoryProvider = MealHistoryProvider(mockMealRepo);
      dashboardProvider = DashboardProvider(mockDashboardRepo);
    });

    Widget createTestApp() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<ProfileProvider>.value(value: profileProvider),
          ChangeNotifierProvider<MealHistoryProvider>.value(
            value: mealHistoryProvider,
          ),
          ChangeNotifierProvider<DashboardProvider>.value(
            value: dashboardProvider,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          routes: {
            AppRoutes.profile: (_) => const ProfileScreen(),
            AppRoutes.login: (_) =>
                const Scaffold(body: Text('Login Screen Mock')),
          },
          home: const ProfileScreen(),
        ),
      );
    }

    testWidgets(
      'tapping Batal in confirmation dialog cancels deletion and stays on screen',
      (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        final deleteTile = find.text('Hapus Akun & Data');
        await tester.scrollUntilVisible(deleteTile, 300);
        await tester.pumpAndSettle();

        await tester.tap(deleteTile);
        await tester.pumpAndSettle();

        expect(find.text('Hapus Akun & Data?'), findsOneWidget);
        expect(find.text('Batal'), findsOneWidget);
        expect(find.text('Hapus Akun'), findsOneWidget);

        // Tap Batal
        await tester.tap(find.text('Batal'));
        await tester.pumpAndSettle();

        expect(find.text('Hapus Akun & Data?'), findsNothing);
        verifyNever(
          () => mockAuthRepo.deleteAccount(password: any(named: 'password')),
        );
      },
    );

    testWidgets(
      'handles REQUIRES_RECENT_LOGIN by showing password dialog and completing deletion',
      (tester) async {
        // 1st call without password throws REQUIRES_RECENT_LOGIN
        when(() => mockAuthRepo.deleteAccount(password: null)).thenThrow(
          ApiException(
            statusCode: 401,
            code: 'REQUIRES_RECENT_LOGIN',
            message: 'Masukkan kata sandi akun.',
          ),
        );
        // 2nd call with password succeeds
        when(() => mockAuthRepo.deleteAccount(password: 'MySecret123'))
            .thenAnswer((_) async {});

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        final deleteTile = find.text('Hapus Akun & Data');
        await tester.scrollUntilVisible(deleteTile, 300);
        await tester.pumpAndSettle();

        // Tap Hapus Akun & Data
        await tester.tap(deleteTile);
        await tester.pumpAndSettle();

        // Confirm in first dialog
        await tester.tap(find.text('Hapus Akun'));
        await tester.pump();
        await tester.pumpAndSettle();

        // Password dialog must appear
        expect(find.text('Konfirmasi Sandi'), findsOneWidget);
        expect(
          find.text(
            'Demi keamanan, masukkan kata sandi akun Anda untuk mengonfirmasi penghapusan permanen.',
          ),
          findsOneWidget,
        );

        // Enter password
        await tester.enterText(
          find.widgetWithText(TextField, 'Masukkan kata sandi Anda'),
          'MySecret123',
        );
        await tester.pumpAndSettle();

        // Tap Hapus Akun in password dialog
        await tester.tap(find.widgetWithText(NeoButton, 'Hapus Akun'));
        await tester.pump();
        await tester.pumpAndSettle();

        // Verified both calls
        verify(() => mockAuthRepo.deleteAccount(password: null)).called(1);
        verify(() => mockAuthRepo.deleteAccount(password: 'MySecret123'))
            .called(1);

        // Redirected to Login
        expect(find.text('Login Screen Mock'), findsOneWidget);
        // Providers cleared
        expect(profileProvider.user, isNull);
        expect(mealHistoryProvider.meals, isEmpty);
      },
    );
  });
}

class MockUserCredential extends Mock implements fb.UserCredential {}
