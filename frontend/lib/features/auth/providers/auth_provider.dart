import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/data/models/profile.dart';
import 'package:nutriview/data/models/user.dart';
import 'package:nutriview/data/repositories/auth_repository.dart';

/// Explicit lifecycle states for the NutriView authentication engine.
/// Explicit lifecycle states for the NutriView authentication engine.
enum AuthLifecycleState {
  /// Firebase or local repository is initializing and restoring session
  initializing,

  /// Clean state ready for identity login (Email/Password or Google)
  unauthenticated,

  /// Saved session detected on device, but locked behind biometric gatekeeper
  biometricRequired,

  /// OS hardware biometric prompt currently presented
  biometricAuthenticating,

  /// User opted to unlock their existing session using password instead of biometrics
  passwordFallback,

  /// Session validated, loading user profile and role from Firestore
  loadingProfile,

  /// User fully verified, authorized, and active
  authenticated,

  /// Session invalidated by server or expired
  sessionExpired,

  /// Fatal unrecoverable auth error
  error;

  /// Backward-compatibility aliases
  static const AuthLifecycleState uninitialized = AuthLifecycleState.initializing;
  static const AuthLifecycleState authenticating = AuthLifecycleState.loadingProfile;
  static const AuthLifecycleState biometricLocked = AuthLifecycleState.biometricRequired;
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthLifecycleState _lifecycleState = AuthLifecycleState.initializing;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;
  String? _errorCode;
  User? _currentUser;
  String? _savedRole;
  String? _savedName;
  String? _savedEmail;
  VoidCallback? onLogout;

  bool _isResetPasswordLoading = false;
  bool _isBiometricLoading = false;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _hasPromptedBiometric = false;
  List<BiometricType> _availableBiometrics = const [];

  AuthProvider(this._repository);

  // --- State Machine Getters ---
  AuthLifecycleState get lifecycleState => _lifecycleState;
  AuthLifecycleState get state => _lifecycleState;
  bool get isInitializing => _lifecycleState == AuthLifecycleState.initializing;
  bool get isUnauthenticated =>
      _lifecycleState == AuthLifecycleState.unauthenticated;
  bool get isBiometricRequired =>
      _lifecycleState == AuthLifecycleState.biometricRequired ||
      _lifecycleState == AuthLifecycleState.biometricAuthenticating;
  bool get isBiometricLocked => isBiometricRequired;
  bool get isBiometricAuthenticating =>
      _lifecycleState == AuthLifecycleState.biometricAuthenticating;
  bool get isPasswordFallback =>
      _lifecycleState == AuthLifecycleState.passwordFallback;
  bool get isLoadingProfile =>
      _lifecycleState == AuthLifecycleState.loadingProfile;
  bool get isAuthenticated =>
      _lifecycleState == AuthLifecycleState.authenticated;
  bool get isBiometricEligible =>
      _isBiometricEnabled && _isBiometricAvailable && _isLoggedIn;
  bool get hasPromptedBiometric => _hasPromptedBiometric;

  // --- Backward Compatible Getters ---
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading =>
      _isLoading ||
      _isGoogleLoading ||
      _isResetPasswordLoading ||
      _isBiometricLoading;
  bool get isEmailLoading => _isLoading;
  bool get isGoogleLoading => _isGoogleLoading;
  bool get isResetPasswordLoading => _isResetPasswordLoading;
  bool get isBiometricLoading => _isBiometricLoading;
  bool get isBiometricAvailable => _isBiometricAvailable;
  bool get isBiometricEnabled => _isBiometricEnabled;
  List<BiometricType> get availableBiometrics => _availableBiometrics;
  bool get hasFingerprint =>
      _availableBiometrics.contains(BiometricType.fingerprint) ||
      _availableBiometrics.contains(BiometricType.strong);
  bool get hasFace => _availableBiometrics.contains(BiometricType.face);
  String? get errorMessage => _errorMessage;
  String? get errorCode => _errorCode;
  User? get currentUser => _currentUser;

  String get role => _currentUser?.role ?? _savedRole ?? 'user';
  String get name => _currentUser?.fullName ?? _savedName ?? 'User';
  String get email => _currentUser?.email ?? _savedEmail ?? '';

  bool get isAdmin => role.toLowerCase().trim() == 'admin';
  bool get isProfileComplete => _currentUser?.isProfileComplete ?? false;

  /// Provider-aware detection
  List<String> get signInProviders => _repository.getSignInProviders();
  bool get hasPasswordProvider => _repository.hasPasswordProvider();
  bool get hasGoogleProvider => _repository.hasGoogleProvider();
  String get primaryProviderId => _repository.getPrimaryProviderId();

  /// Updates current user profile and synchronizes completion state in memory.
  void updateProfile(UserProfile profile) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        profile: profile,
        isProfileComplete: true,
      );
    } else {
      _currentUser = User(
        id: (_savedEmail ?? '').hashCode.abs(),
        email: _savedEmail ?? '',
        fullName: _savedName ?? 'User',
        role: _savedRole ?? 'user',
        isActive: true,
        isProfileComplete: true,
        profile: profile,
      );
    }
    notifyListeners();
  }

  /// Updates or clears active in-memory user profile photo state across the entire app.
  void updateUserPhoto({
    String? photoUrl,
    String? photoPath,
    bool clearPhoto = false,
  }) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        photoUrl: photoUrl,
        photoPath: photoPath,
        clearPhoto: clearPhoto,
      );
    } else if (!clearPhoto && (photoUrl != null || photoPath != null)) {
      _currentUser = User(
        id: (_savedEmail ?? '').hashCode.abs(),
        email: _savedEmail ?? '',
        fullName: _savedName ?? 'User',
        role: _savedRole ?? 'user',
        isActive: true,
        photoUrl: photoUrl,
        photoPath: photoPath,
      );
    }
    notifyListeners();
  }

  /// Sets or updates the active in-memory user instance.
  void setCurrentUser(User user) {
    _currentUser = user;
    _isLoggedIn = true;
    _savedRole = user.role;
    _savedName = user.fullName;
    _savedEmail = user.email;
    notifyListeners();
  }

  /// Evaluates authentication state on app launch.
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    _lifecycleState = AuthLifecycleState.authenticating;
    notifyListeners();

    try {
      _isLoggedIn = await _repository.isLoggedIn();
      if (_isLoggedIn) {
        _savedRole = await _repository.getRole();
        _savedName = await _repository.getUserName();
        _savedEmail = await _repository.getUserEmail();

        // Check if session is protected by biometric gatekeeper
        try {
          _isBiometricAvailable = await _repository.isBiometricAvailable();
          if (_isBiometricAvailable) {
            _availableBiometrics = await _repository.getAvailableBiometrics();
          } else {
            _availableBiometrics = const [];
          }
          _isBiometricEnabled = await _repository.isBiometricEnabled();
          _hasPromptedBiometric = await _repository.hasPromptedBiometric();
        } catch (_) {
          _isBiometricAvailable = false;
          _availableBiometrics = const [];
          _isBiometricEnabled = false;
          _hasPromptedBiometric = false;
        }

        if (_isBiometricEnabled && _isBiometricAvailable) {
          // Protected session: Gate behind Biometric Unlock
          _lifecycleState = AuthLifecycleState.biometricLocked;
        } else {
          // Unprotected session: Direct access
          _lifecycleState = AuthLifecycleState.authenticated;
        }
      } else {
        _resetSessionState();
        _lifecycleState = AuthLifecycleState.unauthenticated;
      }
    } catch (_) {
      _resetSessionState();
      _lifecycleState = AuthLifecycleState.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes device biometric sensor capability and user enrollment status.
  Future<void> checkBiometricAvailability() async {
    try {
      _isBiometricAvailable = await _repository.isBiometricAvailable();
      if (_isBiometricAvailable) {
        _availableBiometrics = await _repository.getAvailableBiometrics();
      } else {
        _availableBiometrics = const [];
      }
      _isBiometricEnabled = await _repository.isBiometricEnabled();
      _hasPromptedBiometric = await _repository.hasPromptedBiometric();
    } catch (_) {
      _isBiometricAvailable = false;
      _isBiometricEnabled = false;
      _availableBiometrics = const [];
    }
    notifyListeners();
  }

  /// Allows user in `biometricRequired` mode to switch to password fallback form.
  void unlockWithPasswordInstead() {
    switchToPasswordFallback();
  }

  /// Explicit transition to contextual password fallback state.
  void switchToPasswordFallback() {
    _lifecycleState = AuthLifecycleState.passwordFallback;
    _errorMessage = null;
    notifyListeners();
  }

  /// Returns to biometric locked mode if the session is eligible.
  void returnToBiometricLock() {
    if (isBiometricEligible) {
      _lifecycleState = AuthLifecycleState.biometricRequired;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Verifies password for existing session during password fallback without requiring email re-entry.
  Future<User?> verifyPasswordFallback(String password) async {
    final cleanPassword = password.trim();
    if (cleanPassword.isEmpty) {
      _errorMessage = 'Kata sandi wajib diisi.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.verifyPasswordFallback(cleanPassword);
      _lifecycleState = AuthLifecycleState.loadingProfile;
      notifyListeners();

      _isLoggedIn = true;
      _currentUser = user;
      _savedRole = user.role;
      _savedName = user.fullName;
      _savedEmail = user.email;

      _lifecycleState = AuthLifecycleState.authenticated;
      return user;
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      if (e.code == 'SESSION_EXPIRED') {
        _resetSessionState();
        _lifecycleState = AuthLifecycleState.sessionExpired;
      } else {
        // Crucial: Stay in passwordFallback state so user can retry without losing context
        _lifecycleState = AuthLifecycleState.passwordFallback;
      }
      return null;
    } catch (_) {
      _errorMessage = 'Verifikasi kata sandi gagal. Silakan coba lagi.';
      _lifecycleState = AuthLifecycleState.passwordFallback;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Safely switches accounts by signing out, clearing tokens & biometric preferences,
  /// and transitioning cleanly to unauthenticated normal login state.
  Future<void> switchAccount() async {
    _isLoading = true;
    _lifecycleState = AuthLifecycleState.authenticating;
    notifyListeners();

    try {
      await _repository.logout();
    } catch (_) {}

    _resetSessionState();
    _lifecycleState = AuthLifecycleState.unauthenticated;
    _isLoading = false;
    notifyListeners();
  }

  /// Sets whether the first-time biometric enrollment prompt has been offered.
  Future<void> setBiometricPrompted(bool prompted) async {
    _hasPromptedBiometric = prompted;
    await _repository.setBiometricPrompted(prompted);
    notifyListeners();
  }

  /// Opt-in / opt-out user for biometric unlock.
  Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      await _repository.setBiometricEnabled(enabled);
      _isBiometricEnabled = enabled;
      _hasPromptedBiometric = true;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Gagal memperbarui preferensi biometrik.';
      notifyListeners();
      return false;
    }
  }

  /// Normal email/password identity login.
  Future<User?> login(
    String email,
    String password,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    _lifecycleState = AuthLifecycleState.authenticating;
    notifyListeners();

    try {
      final user = await _repository.login(
        email: email,
        password: password,
      );
      _isLoggedIn = true;
      _currentUser = user;
      _savedRole = user.role;
      _savedName = user.fullName;
      _savedEmail = user.email;

      // Check biometric environment for post-login enrollment check
      await checkBiometricAvailability();

      _lifecycleState = AuthLifecycleState.authenticated;
      return user;
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      _lifecycleState = AuthLifecycleState.unauthenticated;
      return null;
    } catch (e) {
      _errorMessage = 'Gagal terhubung ke server.';
      _lifecycleState = AuthLifecycleState.unauthenticated;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Google identity login.
  Future<User?> loginWithGoogle() async {
    _isGoogleLoading = true;
    _errorMessage = null;
    _lifecycleState = AuthLifecycleState.authenticating;
    notifyListeners();

    try {
      final user = await _repository.loginWithGoogle();
      if (user == null) {
        // User intentionally cancelled Google sign in dialog
        _lifecycleState = AuthLifecycleState.unauthenticated;
        return null;
      }
      _isLoggedIn = true;
      _currentUser = user;
      _savedRole = user.role;
      _savedName = user.fullName;
      _savedEmail = user.email;

      // Check biometric environment for post-login enrollment check
      await checkBiometricAvailability();

      _lifecycleState = AuthLifecycleState.authenticated;
      return user;
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      _lifecycleState = AuthLifecycleState.unauthenticated;
      return null;
    } catch (_) {
      _errorMessage = 'Gagal terhubung ke layanan Google.';
      _lifecycleState = AuthLifecycleState.unauthenticated;
      return null;
    } finally {
      _isGoogleLoading = false;
      notifyListeners();
    }
  }

  /// Biometric unlock for existing valid sessions.
  Future<User?> authenticateWithBiometrics({String? localizedReason}) async {
    _isBiometricLoading = true;
    _errorMessage = null;
    _lifecycleState = AuthLifecycleState.biometricAuthenticating;
    notifyListeners();

    try {
      final user = await _repository.authenticateWithBiometrics(
        localizedReason: localizedReason,
      );
      _isLoggedIn = true;
      _currentUser = user;
      _savedRole = user.role;
      _savedName = user.fullName;
      _savedEmail = user.email;
      _lifecycleState = AuthLifecycleState.authenticated;
      return user;
    } on ApiException catch (e) {
      if (e.code == 'BIOMETRIC_CANCELLED') {
        // User quietly dismissed dialog, stay in locked state calmly without red banner
        _errorMessage = null;
      } else {
        _errorMessage = e.friendlyMessage;
      }

      if (e.code == 'SESSION_EXPIRED') {
        _resetSessionState();
        _lifecycleState = AuthLifecycleState.sessionExpired;
      } else {
        _lifecycleState = AuthLifecycleState.biometricLocked;
      }
      return null;
    } catch (_) {
      _errorMessage = 'Verifikasi biometrik gagal.';
      _lifecycleState = AuthLifecycleState.biometricLocked;
      return null;
    } finally {
      _isBiometricLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _isResetPasswordLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.sendPasswordResetEmail(email);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal terhubung ke server pemulihan kata sandi.';
      return false;
    } finally {
      _isResetPasswordLoading = false;
      notifyListeners();
    }
  }

  Future<User?> register(String email, String password, String fullName) async {
    _isLoading = true;
    _errorMessage = null;
    _lifecycleState = AuthLifecycleState.authenticating;
    notifyListeners();

    try {
      await _repository.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      final user = await _repository.login(email: email, password: password);
      _isLoggedIn = true;
      _currentUser = user;
      _savedRole = user.role;
      _savedName = user.fullName;
      _savedEmail = user.email;

      await checkBiometricAvailability();

      _lifecycleState = AuthLifecycleState.authenticated;
      return user;
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      _lifecycleState = AuthLifecycleState.unauthenticated;
      return null;
    } catch (e) {
      _errorMessage = 'Gagal terhubung ke server.';
      _lifecycleState = AuthLifecycleState.unauthenticated;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {}
    _resetSessionState();
    _lifecycleState = AuthLifecycleState.unauthenticated;
    onLogout?.call();
    notifyListeners();
  }

  Future<bool> deleteAccount({String? password, bool useGoogleReauth = false}) async {
    _isLoading = true;
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();

    try {
      await _repository.deleteAccount(
        password: password,
        useGoogleReauth: useGoogleReauth,
      );
      _resetSessionState();
      _lifecycleState = AuthLifecycleState.unauthenticated;
      onLogout?.call();
      return true;
    } on ApiException catch (e) {
      _errorCode = e.code;
      _errorMessage = e.friendlyMessage;
      return false;
    } catch (_) {
      _errorCode = 'UNKNOWN_ERROR';
      _errorMessage = 'Gagal menghapus akun.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void handleSessionExpired() {
    _resetSessionState();
    _errorMessage = 'Sesi Anda telah kedaluwarsa. Silakan login kembali.';
    _lifecycleState = AuthLifecycleState.sessionExpired;
    onLogout?.call();
    notifyListeners();
  }

  void _resetSessionState() {
    _isLoggedIn = false;
    _currentUser = null;
    _savedRole = null;
    _savedName = null;
    _savedEmail = null;
    _isBiometricEnabled = false;
    _errorMessage = null;
    _errorCode = null;
  }
}
