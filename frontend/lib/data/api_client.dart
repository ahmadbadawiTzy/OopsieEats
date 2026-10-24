import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Client for local session and credential storage.
/// In the pure Firebase serverless architecture, all network communication
/// is handled by the official Firebase SDK (Auth, Firestore, Storage).
/// This client manages local session caching and token lifecycle.
class ApiClient {
  final FlutterSecureStorage _storage;
  void Function()? onUnauthorized;

  ApiClient({
    FlutterSecureStorage? storage,
    this.onUnauthorized,
    dynamic client,
    String? baseUrl,
  }) : _storage = storage ?? const FlutterSecureStorage();

  static const String _tokenKey = 'nutriview_access_token';
  static const String _roleKey = 'nutriview_user_role';
  static const String _nameKey = 'nutriview_user_name';
  static const String _emailKey = 'nutriview_user_email';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveUserSession({
    required String role,
    required String name,
    required String email,
  }) async {
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(key: _nameKey, value: name);
    await _storage.write(key: _emailKey, value: email);
  }

  Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  Future<String?> getUserName() async {
    return await _storage.read(key: _nameKey);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: _emailKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _nameKey);
    await _storage.delete(key: _emailKey);
  }
}
