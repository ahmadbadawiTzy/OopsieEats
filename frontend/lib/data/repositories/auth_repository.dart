import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/data/api_client.dart';
import 'package:nutriview/data/models/user.dart';
import 'package:nutriview/data/services/biometric_service.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final BiometricService _biometricService;
  bool _isGoogleSignInInitialized = false;

  AuthRepository([
    ApiClient? apiClient,
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
    BiometricService? biometricService,
  ]) : _apiClient = apiClient ?? ApiClient(),
       _auth = auth ?? fb.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _biometricService = biometricService ?? BiometricService();

  ApiClient get apiClient => _apiClient;
  fb.FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  GoogleSignIn get googleSignIn => _googleSignIn;
  BiometricService get biometricService => _biometricService;

  Future<User> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = cred.user?.uid ?? '';
      await cred.user?.updateDisplayName(fullName);

      final userDoc = {
        'id': uid.hashCode.abs(),
        'uid': uid,
        'email': email.trim(),
        'full_name': fullName,
        'role': 'user',
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (uid.isNotEmpty) {
        await _firestore.collection('users').doc(uid).set(userDoc);
      }

      await _apiClient.saveToken(uid);
      await _apiClient.saveUserSession(
        role: 'user',
        name: fullName,
        email: email.trim(),
      );

      return User(
        id: uid.hashCode.abs(),
        email: email.trim(),
        fullName: fullName,
        role: 'user',
        isActive: true,
      );
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw ApiException(
          statusCode: 400,
          code: 'EMAIL_ALREADY_REGISTERED',
          message:
              'Email sudah terdaftar. Silakan gunakan email lain atau login.',
        );
      } else if (e.code == 'weak-password') {
        throw ApiException(
          statusCode: 422,
          code: 'VALIDATION_ERROR',
          message: 'Kata sandi minimal 8 karakter.',
        );
      } else {
        throw ApiException(
          statusCode: 400,
          code: 'REGISTER_FAILED',
          message: e.message ?? 'Pendaftaran gagal.',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 500,
        code: 'INTERNAL_ERROR',
        message: 'Terjadi kesalahan sistem saat mendaftar.',
      );
    }
  }

  Future<User> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = cred.user?.uid ?? '';
      String role = 'user';
      String fullName = cred.user?.displayName ?? '';
      bool isActive = true;

      if (uid.isNotEmpty) {
        try {
          final snapshot = await _firestore.collection('users').doc(uid).get();
          if (snapshot.exists && snapshot.data() != null) {
            final data = snapshot.data()!;
            isActive = data['is_active'] as bool? ?? true;
            if (!isActive) {
              await _auth.signOut();
              throw ApiException(
                statusCode: 403,
                code: 'ACCOUNT_DEACTIVATED',
                message: 'Akun Anda telah dinonaktifkan oleh administrator.',
              );
            }
            role = (data['role'] as String?)?.toLowerCase().trim() ?? 'user';
            fullName = (data['full_name'] as String?)?.isNotEmpty == true
                ? data['full_name'] as String
                : fullName;
          }
        } catch (e) {
          if (e is ApiException) rethrow;
          // Fallback to offline cached role if Firestore fetch fails
          role = (await _apiClient.getRole())?.toLowerCase().trim() ?? 'user';
          fullName = await _apiClient.getUserName() ?? fullName;
        }
      }

      await _apiClient.saveToken(uid);
      await _apiClient.saveUserSession(
        role: role,
        name: fullName.isNotEmpty ? fullName : email.split('@').first,
        email: email.trim(),
      );
      await _apiClient.saveRememberMe(rememberMe);

      return User(
        id: uid.hashCode.abs(),
        email: email.trim(),
        fullName: fullName.isNotEmpty ? fullName : email.split('@').first,
        role: role,
        isActive: isActive,
      );
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-disabled') {
        throw ApiException(
          statusCode: 403,
          code: 'ACCOUNT_DEACTIVATED',
          message: 'Akun Anda telah dinonaktifkan.',
        );
      }
      throw ApiException(
        statusCode: 401,
        code: 'INVALID_CREDENTIALS',
        message: 'Email atau kata sandi yang Anda masukkan salah.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 401,
        code: 'INVALID_CREDENTIALS',
        message: 'Email atau kata sandi yang Anda masukkan salah.',
      );
    }
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_isGoogleSignInInitialized) return;
    try {
      const serverClientId = String.fromEnvironment(
        'GOOGLE_SERVER_CLIENT_ID',
        defaultValue: '350308179098-rj47kjc7qkab0loht39si2ek37qj7gku.apps.googleusercontent.com',
      );
      await _googleSignIn.initialize(
        serverClientId: serverClientId.isNotEmpty ? serverClientId : null,
      );
    } catch (e) {
      debugPrint('[AuthRepository] GoogleSignIn.initialize notice: $e');
    }
    _isGoogleSignInInitialized = true;
  }

  Future<User?> loginWithGoogle({bool rememberMe = true}) async {
    try {
      await _ensureGoogleSignInInitialized();

      final GoogleSignInAccount account;
      try {
        account = await _googleSignIn.authenticate();
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled ||
            e.code == GoogleSignInExceptionCode.interrupted) {
          // User intentionally cancelled account picker
          return null;
        }
        if (e.code == GoogleSignInExceptionCode.clientConfigurationError) {
          throw ApiException(
            statusCode: 500,
            code: 'GOOGLE_CONFIG_ERROR',
            message: 'Konfigurasi Google Sign-In tidak valid. Pastikan SHA-1 fingerprint terdaftar di Firebase Console.',
          );
        }
        throw ApiException(
          statusCode: 400,
          code: 'GOOGLE_SIGN_IN_FAILED',
          message:
              'Gagal melakukan autentikasi Google: ${e.description ?? e.code.name}',
        );
      }

      final googleAuth = account.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw ApiException(
          statusCode: 400,
          code: 'MISSING_ID_TOKEN',
          message: 'Gagal memperoleh token autentikasi Google.',
        );
      }

      final credential = fb.GoogleAuthProvider.credential(idToken: idToken);
      final cred = await _auth.signInWithCredential(credential);
      final fbUser = cred.user;
      final uid = fbUser?.uid ?? '';

      if (uid.isEmpty) {
        throw ApiException(
          statusCode: 400,
          code: 'AUTH_FAILED',
          message: 'Autentikasi gagal.',
        );
      }

      final userDocRef = _firestore.collection('users').doc(uid);
      final snapshot = await userDocRef.get();

      String role = 'user';
      String fullName = fbUser?.displayName ?? '';
      bool isActive = true;

      if (!snapshot.exists || snapshot.data() == null) {
        // First-time Google user: initialize initial profile record
        final email = fbUser?.email ?? '';
        if (fullName.isEmpty) {
          fullName = email.isNotEmpty ? email.split('@').first : 'User';
        }
        final newUserDoc = {
          'id': uid.hashCode.abs(),
          'uid': uid,
          'email': email.trim(),
          'full_name': fullName,
          'role': 'user',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        await userDocRef.set(newUserDoc);
      } else {
        // Returning user: strictly preserve existing profile and role
        final data = snapshot.data()!;
        isActive = data['is_active'] as bool? ?? true;
        if (!isActive) {
          await _auth.signOut();
          try {
            await _googleSignIn.signOut();
          } catch (_) {}
          throw ApiException(
            statusCode: 403,
            code: 'ACCOUNT_DEACTIVATED',
            message: 'Akun Anda telah dinonaktifkan oleh administrator.',
          );
        }
        role = (data['role'] as String?)?.toLowerCase().trim() ?? 'user';
        final storedName = data['full_name'] as String?;
        if (storedName != null && storedName.isNotEmpty) {
          fullName = storedName;
        } else if (fullName.isEmpty) {
          fullName = (fbUser?.email ?? '').split('@').first;
        }
      }

      await _apiClient.saveToken(uid);
      await _apiClient.saveUserSession(
        role: role,
        name: fullName.isNotEmpty
            ? fullName
            : (fbUser?.email ?? '').split('@').first,
        email: (fbUser?.email ?? '').trim(),
      );
      await _apiClient.saveRememberMe(rememberMe);

      return User(
        id: uid.hashCode.abs(),
        email: (fbUser?.email ?? '').trim(),
        fullName: fullName.isNotEmpty
            ? fullName
            : (fbUser?.email ?? '').split('@').first,
        role: role,
        isActive: isActive,
      );
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw ApiException(
          statusCode: 409,
          code: 'ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL',
          message: 'Email ini sudah terdaftar menggunakan kata sandi. Silakan masuk menggunakan email dan kata sandi.',
        );
      } else if (e.code == 'user-disabled') {
        throw ApiException(
          statusCode: 403,
          code: 'ACCOUNT_DEACTIVATED',
          message: 'Akun Anda telah dinonaktifkan.',
        );
      } else if (e.code == 'network-request-failed') {
        throw ApiException(
          statusCode: 503,
          code: 'NETWORK_ERROR',
          message:
              'Koneksi jaringan bermasalah. Periksa koneksi internet Anda.',
        );
      } else {
        throw ApiException(
          statusCode: 400,
          code: 'AUTH_FAILED',
          message: e.message ?? 'Autentikasi gagal.',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 500,
        code: 'INTERNAL_ERROR',
        message: 'Terjadi kesalahan sistem saat masuk dengan Google.',
      );
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } finally {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      await _apiClient.clearBiometricPreference();
      await _apiClient.clearToken();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      throw ApiException(
        statusCode: 400,
        code: 'EMPTY_EMAIL',
        message: 'Email wajib diisi.',
      );
    }
    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      throw ApiException(
        statusCode: 422,
        code: 'INVALID_EMAIL_FORMAT',
        message: 'Format email tidak valid.',
      );
    }

    try {
      await _auth.sendPasswordResetEmail(email: cleanEmail);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Anti-Account Enumeration: do not leak non-registered emails
        return;
      } else if (e.code == 'invalid-email') {
        throw ApiException(
          statusCode: 422,
          code: 'INVALID_EMAIL',
          message: 'Format email tidak valid.',
        );
      } else if (e.code == 'too-many-requests') {
        throw ApiException(
          statusCode: 429,
          code: 'RATE_LIMIT_EXCEEDED',
          message: 'Terlalu banyak permintaan. Silakan tunggu beberapa saat sebelum mencoba kembali.',
        );
      } else if (e.code == 'network-request-failed') {
        throw ApiException(
          statusCode: 503,
          code: 'NETWORK_ERROR',
          message: 'Koneksi internet bermasalah. Periksa jaringan Anda dan coba lagi.',
        );
      } else {
        throw ApiException(
          statusCode: 400,
          code: 'RESET_FAILED',
          message:
              e.message ?? 'Gagal mengirim instruksi pemulihan kata sandi.',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 500,
        code: 'INTERNAL_ERROR',
        message:
            'Terjadi kesalahan sistem saat memproses pemulihan kata sandi.',
      );
    }
  }

  Future<bool> isRememberMeEnabled() async {
    return await _apiClient.isRememberMeEnabled();
  }

  Future<void> setRememberMe(bool enabled) async {
    await _apiClient.saveRememberMe(enabled);
  }

  Future<bool> isBiometricAvailable() async {
    return await _biometricService.isBiometricAvailable();
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _biometricService.getAvailableBiometrics();
  }

  Future<bool> isBiometricEnabled() async {
    return await _apiClient.isBiometricEnabled();
  }

  Future<bool> hasPromptedBiometric() async {
    return await _apiClient.hasPromptedBiometric();
  }

  Future<void> setBiometricPrompted(bool prompted) async {
    await _apiClient.saveBiometricPrompted(prompted);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    if (enabled) {
      final user = _auth.currentUser;
      if (user == null) {
        throw ApiException(
          statusCode: 401,
          code: 'UNAUTHORIZED',
          message: 'Pengguna harus login untuk mengaktifkan biometrik.',
        );
      }
      final email = user.email ?? (await _apiClient.getUserEmail()) ?? '';
      await _apiClient.saveBiometricEmail(email);
      await _apiClient.saveBiometricUid(user.uid);
      await _apiClient.saveBiometricEnabled(true);
      await _apiClient.saveBiometricPrompted(true);
    } else {
      await _apiClient.clearBiometricPreference();
    }
  }

  Future<User> authenticateWithBiometrics({String? localizedReason}) async {
    final isAvailable = await isBiometricAvailable();
    if (!isAvailable) {
      throw ApiException(
        statusCode: 400,
        code: 'BIOMETRIC_UNAVAILABLE',
        message: 'Sensor biometrik tidak tersedia atau belum didaftarkan pada perangkat ini.',
      );
    }

    final isEnabled = await isBiometricEnabled();
    if (!isEnabled) {
      throw ApiException(
        statusCode: 400,
        code: 'BIOMETRIC_NOT_ENABLED',
        message: 'Kunci biometrik belum diaktifkan pada akun ini.',
      );
    }

    // Secure Session Unlock: Validate that Firebase Auth session is active!
    final fbUser = _auth.currentUser;
    if (fbUser == null) {
      // Ephemeral or expired session. Clear preference to avoid stale state.
      await _apiClient.clearBiometricPreference();
      throw ApiException(
        statusCode: 401,
        code: 'SESSION_EXPIRED',
        message: 'Sesi login telah kedaluwarsa. Silakan masuk kembali dengan email atau Google.',
      );
    }

    // Verify account association: UID check
    final savedBiometricUid = await _apiClient.getBiometricUid();
    if (savedBiometricUid != null &&
        savedBiometricUid.isNotEmpty &&
        savedBiometricUid != fbUser.uid) {
      await _apiClient.clearBiometricPreference();
      throw ApiException(
        statusCode: 403,
        code: 'BIOMETRIC_ACCOUNT_MISMATCH',
        message: 'Biometrik terdaftar untuk akun berbeda. Silakan masuk kembali secara manual.',
      );
    }

    // Verify account association: Email check
    final savedBiometricEmail = await _apiClient.getBiometricEmail();
    if (savedBiometricEmail != null &&
        savedBiometricEmail.isNotEmpty &&
        fbUser.email != null &&
        savedBiometricEmail.toLowerCase().trim() !=
            fbUser.email!.toLowerCase().trim()) {
      await _apiClient.clearBiometricPreference();
      throw ApiException(
        statusCode: 403,
        code: 'BIOMETRIC_ACCOUNT_MISMATCH',
        message: 'Biometrik terdaftar untuk akun berbeda. Silakan masuk kembali secara manual.',
      );
    }

    // Execute hardware biometric prompt
    final reason =
        localizedReason ??
        'Pindai sidik jari atau wajah Anda untuk membuka NutriView.';
    final authenticated = await _biometricService.authenticate(
      localizedReason: reason,
    );

    if (!authenticated) {
      throw ApiException(
        statusCode: 401,
        code: 'BIOMETRIC_CANCELLED',
        message: 'Verifikasi biometrik dibatalkan.',
      );
    }

    // Restore user profile
    final uid = fbUser.uid;
    String role = 'user';
    String fullName = fbUser.displayName ?? '';
    bool isActive = true;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        isActive = data['is_active'] as bool? ?? true;
        if (!isActive) {
          await _auth.signOut();
          await _apiClient.clearBiometricPreference();
          await _apiClient.clearToken();
          throw ApiException(
            statusCode: 403,
            code: 'ACCOUNT_DEACTIVATED',
            message: 'Akun Anda telah dinonaktifkan.',
          );
        }
        role = (data['role'] as String?)?.toLowerCase().trim() ?? 'user';
        fullName = (data['full_name'] as String?)?.isNotEmpty == true
            ? data['full_name'] as String
            : fullName;
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      role = (await _apiClient.getRole())?.toLowerCase().trim() ?? 'user';
      fullName = await _apiClient.getUserName() ?? fullName;
    }

    await _apiClient.saveToken(uid);
    await _apiClient.saveUserSession(
      role: role,
      name: fullName.isNotEmpty
          ? fullName
          : (fbUser.email ?? '').split('@').first,
      email: (fbUser.email ?? '').trim(),
    );

    return User(
      id: uid.hashCode.abs(),
      email: (fbUser.email ?? '').trim(),
      fullName: fullName.isNotEmpty
          ? fullName
          : (fbUser.email ?? '').split('@').first,
      role: role,
      isActive: isActive,
    );
  }

  /// Verifies password for an existing session during password fallback without requiring email re-entry.
  Future<User> verifyPasswordFallback(String password) async {
    final fbUser = _auth.currentUser;
    final savedEmail = await _apiClient.getUserEmail() ??
        await _apiClient.getBiometricEmail() ??
        '';

    if (fbUser == null && savedEmail.isEmpty) {
      await _apiClient.clearBiometricPreference();
      throw ApiException(
        statusCode: 401,
        code: 'SESSION_EXPIRED',
        message: 'Sesi login telah berakhir. Silakan masuk kembali.',
      );
    }

    final emailToVerify = (fbUser?.email ?? savedEmail).trim();
    if (emailToVerify.isEmpty) {
      throw ApiException(
        statusCode: 400,
        code: 'NO_EMAIL',
        message: 'Akun tidak memiliki email terdaftar untuk verifikasi.',
      );
    }

    if (fbUser != null) {
      try {
        final credential = fb.EmailAuthProvider.credential(
          email: emailToVerify,
          password: password,
        );
        await fbUser.reauthenticateWithCredential(credential);
      } on fb.FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          throw ApiException(
            statusCode: 401,
            code: 'WRONG_PASSWORD',
            message: 'Kata sandi salah. Silakan coba lagi.',
          );
        } else if (e.code == 'user-mismatch') {
          throw ApiException(
            statusCode: 403,
            code: 'USER_MISMATCH',
            message: 'Kredensial tidak sesuai dengan akun aktif.',
          );
        } else if (e.code == 'too-many-requests') {
          throw ApiException(
            statusCode: 429,
            code: 'TOO_MANY_REQUESTS',
            message:
                'Terlalu banyak percobaan gagal. Silakan tunggu beberapa saat.',
          );
        } else {
          throw ApiException(
            statusCode: 400,
            code: e.code,
            message: e.message ?? 'Verifikasi kata sandi gagal.',
          );
        }
      }
    } else {
      // Session dropped: Fallback to direct sign-in with preserved email & password
      return await login(
        email: emailToVerify,
        password: password,
        rememberMe: true,
      );
    }

    // Resolve user profile & role
    final uid = fbUser.uid;
    String role = 'user';
    String fullName = fbUser.displayName ?? '';
    bool isActive = true;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        isActive = data['is_active'] as bool? ?? true;
        if (!isActive) {
          await _auth.signOut();
          await _apiClient.clearBiometricPreference();
          await _apiClient.clearToken();
          throw ApiException(
            statusCode: 403,
            code: 'ACCOUNT_DEACTIVATED',
            message: 'Akun Anda telah dinonaktifkan oleh administrator.',
          );
        }
        role = (data['role'] as String?)?.toLowerCase().trim() ?? 'user';
        final storedName = data['full_name'] as String?;
        if (storedName != null && storedName.isNotEmpty) {
          fullName = storedName;
        }
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      // Resilient fallback to offline cached profile if Firestore query fails
      role = (await _apiClient.getRole())?.toLowerCase().trim() ?? 'user';
      fullName = await _apiClient.getUserName() ?? fullName;
    }

    await _apiClient.saveToken(uid);
    await _apiClient.saveUserSession(
      role: role,
      name: fullName.isNotEmpty ? fullName : emailToVerify.split('@').first,
      email: emailToVerify,
    );

    return User(
      id: uid.hashCode.abs(),
      email: emailToVerify,
      fullName: fullName.isNotEmpty ? fullName : emailToVerify.split('@').first,
      role: role,
      isActive: isActive,
    );
  }

  Future<void> reauthenticateWithPassword(String password) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw ApiException(
        statusCode: 401,
        code: 'UNAUTHORIZED',
        message: 'Pengguna belum terautentikasi.',
      );
    }
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw ApiException(
        statusCode: 400,
        code: 'NO_EMAIL',
        message: 'Akun tidak memiliki email terdaftar untuk verifikasi.',
      );
    }
    try {
      final credential = fb.EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw ApiException(
          statusCode: 401,
          code: 'WRONG_PASSWORD',
          message: 'Kata sandi salah. Verifikasi gagal.',
        );
      }
      throw ApiException(
        statusCode: 400,
        code: e.code,
        message: e.message ?? 'Verifikasi kata sandi gagal.',
      );
    }
  }

  Future<void> deleteAccount({String? password}) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint(
        '[AccountDeletion] No active Firebase Auth user found. Clearing local token.',
      );
      await _apiClient.clearToken();
      return;
    }

    final uid = user.uid;
    debugPrint(
      '[AccountDeletion] Initiating account deletion workflow for UID: $uid',
    );

    // 1. Reauthentication handling
    if (password != null && password.isNotEmpty) {
      debugPrint(
        '[AccountDeletion] Stage 1: Reauthenticating with provided password credentials.',
      );
      await reauthenticateWithPassword(password);
      debugPrint('[AccountDeletion] Stage 1: Reauthentication successful.');
    } else {
      debugPrint('[AccountDeletion] Stage 1: Checking session freshness.');
      final lastSignIn = user.metadata.lastSignInTime;
      if (lastSignIn == null ||
          DateTime.now().difference(lastSignIn) > const Duration(minutes: 5)) {
        debugPrint(
          '[AccountDeletion] Stage 1: Session is stale (> 5 mins) or unrecorded. Prompting re-auth.',
        );
        throw ApiException(
          statusCode: 401,
          code: 'REQUIRES_RECENT_LOGIN',
          message: 'Demi keamanan, masukkan kata sandi akun Anda untuk konfirmasi penghapusan.',
        );
      }
      debugPrint(
        '[AccountDeletion] Stage 1: Session is fresh (< 5 mins). Proceeding to data cleanup.',
      );
    }

    // 2. Delete user data in Firestore while session is valid and fresh
    debugPrint('[AccountDeletion] Stage 2: Cleaning up Firestore collections.');
    try {
      // 2a. Delete all user meals in subcollection with batch chunking (max 450 per commit)
      final mealsSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('meals')
          .get();

      if (mealsSnapshot.docs.isNotEmpty) {
        debugPrint(
          '[AccountDeletion] Found ${mealsSnapshot.docs.length} meal record(s) in subcollection. Deleting in batches.',
        );
        const batchLimit = 450;
        for (var i = 0; i < mealsSnapshot.docs.length; i += batchLimit) {
          final end = (i + batchLimit > mealsSnapshot.docs.length)
              ? mealsSnapshot.docs.length
              : i + batchLimit;
          final chunk = mealsSnapshot.docs.sublist(i, end);
          final batch = _firestore.batch();
          for (final doc in chunk) {
            batch.delete(doc.reference);
          }
          await batch.commit();
        }
        debugPrint(
          '[AccountDeletion] Subcollection users/$uid/meals successfully cleared.',
        );
      } else {
        debugPrint('[AccountDeletion] No meals found in subcollection.');
      }

      // 2b. Delete user document
      debugPrint('[AccountDeletion] Deleting document users/$uid.');
      await _firestore.collection('users').doc(uid).delete();
      debugPrint('[AccountDeletion] Document users/$uid successfully deleted.');

      // 2c. Delete profile document if present
      try {
        await _firestore.collection('profiles').doc(uid).delete();
      } catch (_) {
        // Ignored: profiles collection is legacy/optional
      }
    } on fb.FirebaseException catch (e) {
      debugPrint(
        '[AccountDeletion] Firestore cleanup failed: [${e.plugin}/${e.code}] ${e.message}',
      );
      throw ApiException(
        statusCode: 500,
        code: 'FIRESTORE_CLEANUP_FAILED',
        message: 'Gagal membersihkan data akun di server. Penghapusan dibatalkan demi keamanan.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      debugPrint(
        '[AccountDeletion] Unexpected error during Firestore cleanup: $e',
      );
      throw ApiException(
        statusCode: 500,
        code: 'FIRESTORE_CLEANUP_FAILED',
        message: 'Gagal membersihkan data akun di server. Penghapusan dibatalkan demi keamanan.',
      );
    }

    // 3. Delete Firebase Auth user
    debugPrint(
      '[AccountDeletion] Stage 3: Deleting Firebase Auth user account.',
    );
    try {
      await user.delete();
      debugPrint(
        '[AccountDeletion] Firebase Auth user account successfully deleted.',
      );
    } on fb.FirebaseAuthException catch (e) {
      debugPrint(
        '[AccountDeletion] Firebase Auth user.delete failed: [${e.code}] ${e.message}',
      );
      if (e.code == 'requires-recent-login') {
        throw ApiException(
          statusCode: 401,
          code: 'REQUIRES_RECENT_LOGIN',
          message: 'Demi keamanan, masukkan kata sandi akun Anda untuk konfirmasi penghapusan.',
        );
      }
      throw ApiException(
        statusCode: 400,
        code: 'DELETE_ACCOUNT_FAILED',
        message: e.message ?? 'Gagal menghapus akun autentikasi.',
      );
    }

    // 4. Session cleanup ONLY upon successful deletion!
    debugPrint(
      '[AccountDeletion] Stage 4: Wiping local cached credentials and tokens.',
    );
    await _apiClient.clearBiometricPreference();
    await _apiClient.clearToken();
    debugPrint(
      '[AccountDeletion] Account deletion workflow completed successfully.',
    );
  }

  Future<bool> isLoggedIn() async {
    if (_auth.currentUser != null) return true;
    final token = await _apiClient.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getRole() async {
    if (_auth.currentUser != null) {
      final uid = _auth.currentUser!.uid;
      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final serverRole = (doc.data()!['role'] as String?)
              ?.toLowerCase()
              .trim();
          if (serverRole != null && serverRole.isNotEmpty) {
            await _apiClient.saveUserSession(
              role: serverRole,
              name: (doc.data()!['full_name'] as String?)?.isNotEmpty == true
                  ? doc.data()!['full_name'] as String
                  : (_auth.currentUser!.displayName ?? ''),
              email: _auth.currentUser!.email ?? '',
            );
            return serverRole;
          }
        }
      } catch (_) {
        // Fallback to locally stored session role
      }
    }
    return await _apiClient.getRole();
  }

  Future<String?> getUserName() async {
    return _auth.currentUser?.displayName ?? await _apiClient.getUserName();
  }

  Future<String?> getUserEmail() async {
    return _auth.currentUser?.email ?? await _apiClient.getUserEmail();
  }
}
