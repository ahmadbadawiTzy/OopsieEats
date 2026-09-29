import 'package:nutriview/data/api_client.dart';
import 'package:nutriview/data/models/user.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<User> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      body: {
        'email': email,
        'password': password,
        'full_name': fullName,
      },
    );
    return User.fromJson(response as Map<String, dynamic>);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );
    final token = response['access_token'] as String;
    await _apiClient.saveToken(token);
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } finally {
      await _apiClient.clearToken();
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiClient.getToken();
    return token != null && token.isNotEmpty;
  }
}
