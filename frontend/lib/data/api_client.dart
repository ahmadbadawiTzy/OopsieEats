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

  // Primary OopsieEats storage keys
  static const String _tokenKey = 'oopsieeats_access_token';
  static const String _roleKey = 'oopsieeats_user_role';
  static const String _nameKey = 'oopsieeats_user_name';
  static const String _emailKey = 'oopsieeats_user_email';
  static const String _biometricEnabledKey = 'oopsieeats_biometric_enabled';
  static const String _biometricEmailKey = 'oopsieeats_biometric_user_email';
  static const String _biometricUidKey = 'oopsieeats_biometric_uid';
  static const String _biometricPromptedKey = 'oopsieeats_biometric_prompted';
  static const String _onboardingCompletedKey =
      'oopsieeats_onboarding_completed';

  // Legacy NutriView storage keys for zero-loss migration
  static const String _legacyTokenKey = 'nutriview_access_token';
  static const String _legacyRoleKey = 'nutriview_user_role';
  static const String _legacyNameKey = 'nutriview_user_name';
  static const String _legacyEmailKey = 'nutriview_user_email';
  static const String _legacyBiometricEnabledKey = 'nutriview_biometric_enabled';
  static const String _legacyBiometricEmailKey = 'nutriview_biometric_user_email';
  static const String _legacyBiometricUidKey = 'nutriview_biometric_uid';
  static const String _legacyBiometricPromptedKey = 'nutriview_biometric_prompted';
  static const String _legacyOnboardingCompletedKey =
      'nutriview_onboarding_completed';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    final value = await _storage.read(key: _tokenKey);
    if (value != null) return value;
    final legacy = await _storage.read(key: _legacyTokenKey);
    if (legacy != null) {
      await _storage.write(key: _tokenKey, value: legacy);
      return legacy;
    }
    return null;
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
    final value = await _storage.read(key: _roleKey);
    if (value != null) return value;
    final legacy = await _storage.read(key: _legacyRoleKey);
    if (legacy != null) {
      await _storage.write(key: _roleKey, value: legacy);
      return legacy;
    }
    return null;
  }

  Future<String?> getUserName() async {
    final value = await _storage.read(key: _nameKey);
    if (value != null) return value;
    final legacy = await _storage.read(key: _legacyNameKey);
    if (legacy != null) {
      await _storage.write(key: _nameKey, value: legacy);
      return legacy;
    }
    return null;
  }

  Future<String?> getUserEmail() async {
    final value = await _storage.read(key: _emailKey);
    if (value != null) return value;
    final legacy = await _storage.read(key: _legacyEmailKey);
    if (legacy != null) {
      await _storage.write(key: _emailKey, value: legacy);
      return legacy;
    }
    return null;
  }

  Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: _biometricEnabledKey,
      value: enabled ? 'true' : 'false',
    );
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    if (value != null) return value == 'true';
    final legacy = await _storage.read(key: _legacyBiometricEnabledKey);
    if (legacy != null) {
      await _storage.write(key: _biometricEnabledKey, value: legacy);
      return legacy == 'true';
    }
    return false;
  }

  Future<void> saveBiometricEmail(String email) async {
    await _storage.write(key: _biometricEmailKey, value: email);
  }

  Future<String?> getBiometricEmail() async {
    final value = await _storage.read(key: _biometricEmailKey);
    if (value != null) return value;
    final legacy = await _storage.read(key: _legacyBiometricEmailKey);
    if (legacy != null) {
      await _storage.write(key: _biometricEmailKey, value: legacy);
      return legacy;
    }
    return null;
  }

  Future<void> saveBiometricUid(String uid) async {
    await _storage.write(key: _biometricUidKey, value: uid);
  }

  Future<String?> getBiometricUid() async {
    final value = await _storage.read(key: _biometricUidKey);
    if (value != null) return value;
    final legacy = await _storage.read(key: _legacyBiometricUidKey);
    if (legacy != null) {
      await _storage.write(key: _biometricUidKey, value: legacy);
      return legacy;
    }
    return null;
  }

  Future<void> saveBiometricPrompted(bool prompted) async {
    await _storage.write(
      key: _biometricPromptedKey,
      value: prompted ? 'true' : 'false',
    );
  }

  Future<bool> hasPromptedBiometric() async {
    final value = await _storage.read(key: _biometricPromptedKey);
    if (value != null) return value == 'true';
    final legacy = await _storage.read(key: _legacyBiometricPromptedKey);
    if (legacy != null) {
      await _storage.write(key: _biometricPromptedKey, value: legacy);
      return legacy == 'true';
    }
    return false;
  }

  Future<void> clearBiometricPreference() async {
    await _storage.delete(key: _biometricEnabledKey);
    await _storage.delete(key: _biometricEmailKey);
    await _storage.delete(key: _biometricUidKey);
    await _storage.delete(key: _biometricPromptedKey);
    await _storage.delete(key: _legacyBiometricEnabledKey);
    await _storage.delete(key: _legacyBiometricEmailKey);
    await _storage.delete(key: _legacyBiometricUidKey);
    await _storage.delete(key: _legacyBiometricPromptedKey);
  }

  Future<void> saveOnboardingCompleted(bool completed) async {
    await _storage.write(
      key: _onboardingCompletedKey,
      value: completed ? 'true' : 'false',
    );
  }

  Future<bool> hasCompletedOnboarding() async {
    final value = await _storage.read(key: _onboardingCompletedKey);
    if (value != null) return value == 'true';
    final legacy = await _storage.read(key: _legacyOnboardingCompletedKey);
    if (legacy != null) {
      await _storage.write(key: _onboardingCompletedKey, value: legacy);
      return legacy == 'true';
    }
    return false;
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _nameKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _legacyTokenKey);
    await _storage.delete(key: _legacyRoleKey);
    await _storage.delete(key: _legacyNameKey);
    await _storage.delete(key: _legacyEmailKey);
  }
}
