import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/data/api_client.dart';
import 'package:nutriview/features/admin/data/admin_repository.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiClient Session Management Tests', () {
    late MockSecureStorage mockStorage;
    late ApiClient apiClient;

    setUp(() {
      mockStorage = MockSecureStorage();
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      apiClient = ApiClient(storage: mockStorage);
    });

    test('saveToken and getToken manage secure token correctly', () async {
      when(() => mockStorage.read(key: 'nutriview_access_token'))
          .thenAnswer((_) async => 'mock_token_123');

      await apiClient.saveToken('mock_token_123');
      verify(
        () => mockStorage.write(
          key: 'nutriview_access_token',
          value: 'mock_token_123',
        ),
      ).called(1);

      final token = await apiClient.getToken();
      expect(token, 'mock_token_123');
    });

    test('saveUserSession saves role, name, and email', () async {
      when(() => mockStorage.read(key: 'nutriview_user_role'))
          .thenAnswer((_) async => 'admin');
      when(() => mockStorage.read(key: 'nutriview_user_name'))
          .thenAnswer((_) async => 'Ahmad Badawi');
      when(() => mockStorage.read(key: 'nutriview_user_email'))
          .thenAnswer((_) async => 'ahmadbadawi.biu.si@gmail.com');

      await apiClient.saveUserSession(
        role: 'admin',
        name: 'Ahmad Badawi',
        email: 'ahmadbadawi.biu.si@gmail.com',
      );

      verify(
        () => mockStorage.write(key: 'nutriview_user_role', value: 'admin'),
      ).called(1);
      verify(
        () => mockStorage.write(
          key: 'nutriview_user_name',
          value: 'Ahmad Badawi',
        ),
      ).called(1);
      verify(
        () => mockStorage.write(
          key: 'nutriview_user_email',
          value: 'ahmadbadawi.biu.si@gmail.com',
        ),
      ).called(1);

      expect(await apiClient.getRole(), 'admin');
      expect(await apiClient.getUserName(), 'Ahmad Badawi');
      expect(await apiClient.getUserEmail(), 'ahmadbadawi.biu.si@gmail.com');
    });

    test('clearToken deletes all session keys', () async {
      await apiClient.clearToken();
      verify(() => mockStorage.delete(key: 'nutriview_access_token')).called(1);
      verify(() => mockStorage.delete(key: 'nutriview_user_role')).called(1);
      verify(() => mockStorage.delete(key: 'nutriview_user_name')).called(1);
      verify(() => mockStorage.delete(key: 'nutriview_user_email')).called(1);
    });
  });

  group('AdminRepository Pure Firebase Unit Tests', () {
    late AdminRepository adminRepository;

    setUp(() {
      adminRepository = AdminRepository();
    });

    test(
      'login throws ApiException when Firebase is not initialized',
      () async {
        expect(
          () => adminRepository.login('admin@nutriview.id', 'Secret123!'),
          throwsA(
            isA<ApiException>().having(
              (e) => e.code,
              'code',
              'FIREBASE_NOT_INITIALIZED',
            ),
          ),
        );
      },
    );

    test(
      'createFood validates Atwater equation and throws on invalid macros',
      () async {
        expect(
          () => adminRepository.createFood({
            'name': 'Makanan Tidak Valid',
            'yolo_class': 'invalid_food',
            'calories_kcal_per_100g': 800.0, // expected ~ 160 kcal
            'protein_g_per_100g': 10.0,
            'carbs_g_per_100g': 20.0,
            'fat_g_per_100g': 4.0,
          }),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test(
      'getFoods returns empty list gracefully when Firestore is uninitialized',
      () async {
        final res = await adminRepository.getFoods();
        expect(res['items'], isEmpty);
        expect(res['total'], 0);
      },
    );

    test('getArticles returns empty list gracefully when Firestore is uninitialized', () async {
      final res = await adminRepository.getArticles();
      expect(res['items'], isEmpty);
      expect(res['total'], 0);
    });

    test('getCategories returns empty list gracefully when Firestore is uninitialized', () async {
      final res = await adminRepository.getCategories();
      expect(res, isEmpty);
    });

    test(
      'getMedia returns empty list gracefully when Firestore is uninitialized',
      () async {
        final res = await adminRepository.getMedia();
        expect(res['items'], isEmpty);
        expect(res['total'], 0);
      },
    );

    test('getAuditLogs returns empty list gracefully when Firestore is uninitialized', () async {
      final res = await adminRepository.getAuditLogs();
      expect(res['items'], isEmpty);
      expect(res['total'], 0);
    });

    test(
      'getUsers returns empty list gracefully when Firestore is uninitialized',
      () async {
        final res = await adminRepository.getUsers();
        expect(res['items'], isEmpty);
        expect(res['total'], 0);
      },
    );
  });
}
