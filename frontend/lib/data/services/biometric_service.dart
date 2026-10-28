import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Service wrapping system biometric capabilities using [LocalAuthentication].
/// Supports fingerprint, face recognition, and platform-level biometric security.
class BiometricService {
  final LocalAuthentication _localAuth;

  BiometricService([LocalAuthentication? localAuth])
    : _localAuth = localAuth ?? LocalAuthentication();

  LocalAuthentication get localAuth => _localAuth;

  /// Checks if the device hardware supports biometrics.
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException catch (e) {
      debugPrint('[BiometricService] isDeviceSupported error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[BiometricService] isDeviceSupported unexpected error: $e');
      return false;
    }
  }

  /// Checks if biometrics can be checked on this device.
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      debugPrint('[BiometricService] canCheckBiometrics error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[BiometricService] canCheckBiometrics unexpected error: $e');
      return false;
    }
  }

  /// Retrieves list of enrolled biometric types on the device.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint(
        '[BiometricService] getAvailableBiometrics error: ${e.message}',
      );
      return const [];
    } catch (e) {
      debugPrint(
        '[BiometricService] getAvailableBiometrics unexpected error: $e',
      );
      return const [];
    }
  }

  /// Returns true if the device supports biometrics and has enrolled credentials.
  Future<bool> isBiometricAvailable() async {
    final supported = await isDeviceSupported();
    if (!supported) return false;

    final canCheck = await canCheckBiometrics();
    if (!canCheck) return false;

    final available = await getAvailableBiometrics();
    return available.isNotEmpty;
  }

  /// Returns true if fingerprint sensor is available.
  Future<bool> hasFingerprint() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.fingerprint) ||
        biometrics.contains(BiometricType.strong);
  }

  /// Returns true if face authentication is available.
  Future<bool> hasFace() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.face);
  }

  /// Authenticates user using system biometric prompt.
  Future<bool> authenticate({
    required String localizedReason,
    bool biometricOnly = true,
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (e) {
      debugPrint(
        '[BiometricService] authenticate PlatformException: [${e.code}] ${e.message}',
      );
      return false;
    } catch (e) {
      debugPrint('[BiometricService] authenticate unexpected error: $e');
      return false;
    }
  }
}
