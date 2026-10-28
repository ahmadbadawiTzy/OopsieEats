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
  static const String _rememberMeKey = 'nutriview_remember_me';
  static const String _biometricEnabledKey = 'nutriview_biometric_enabled';
  static const String _biometricEmailKey = 'nutriview_biometric_user_email';
  static const String _biometricUidKey = 'nutriview_biometric_uid';
  static const String _biometricPromptedKey = 'nutriview_biometric_prompted';

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

  Future<void> saveRememberMe(bool enabled) async {
    await _storage.write(
      key: _rememberMeKey,
      value: enabled ? 'true' : 'false',
    );
  }

  Future<bool> isRememberMeEnabled() async {
    final value = await _storage.read(key: _rememberMeKey);
    // Defaults to true (persistent mobile session) if never explicitly changed
    if (value == null) return true;
    return value == 'true';
  }

  Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: _biometricEnabledKey,
      value: enabled ? 'true' : 'false',
    );
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    // Defaults to false: opt-in security requirement
    return value == 'true';
  }

  Future<void> saveBiometricEmail(String email) async {
    await _storage.write(key: _biometricEmailKey, value: email);
  }

  Future<String?> getBiometricEmail() async {
    return await _storage.read(key: _biometricEmailKey);
  }

  Future<void> saveBiometricUid(String uid) async {
    await _storage.write(key: _biometricUidKey, value: uid);
  }

  Future<String?> getBiometricUid() async {
    return await _storage.read(key: _biometricUidKey);
  }

  Future<void> saveBiometricPrompted(bool prompted) async {
    await _storage.write(
      key: _biometricPromptedKey,
      value: prompted ? 'true' : 'false',
    );
  }

  Future<bool> hasPromptedBiometric() async {
    final value = await _storage.read(key: _biometricPromptedKey);
    return value == 'true';
  }

  Future<void> clearBiometricPreference() async {
    await _storage.delete(key: _biometricEnabledKey);
    await _storage.delete(key: _biometricEmailKey);
    await _storage.delete(key: _biometricUidKey);
    await _storage.delete(key: _biometricPromptedKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _nameKey);
    await _storage.delete(key: _emailKey);
  }
}
