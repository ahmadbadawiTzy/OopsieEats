import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/data/api_client.dart';
import 'package:nutriview/data/models/user.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository([
    ApiClient? apiClient,
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  ]) : _apiClient = apiClient ?? ApiClient(),
       _auth = auth ?? fb.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  ApiClient get apiClient => _apiClient;
  fb.FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;

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

  Future<User> login({required String email, required String password}) async {
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
            role = data['role'] as String? ?? 'user';
            fullName = (data['full_name'] as String?)?.isNotEmpty == true
                ? data['full_name'] as String
                : fullName;
          }
        } catch (e) {
          if (e is ApiException) rethrow;
          // Fallback to offline cached role if Firestore fetch fails
          role = await _apiClient.getRole() ?? 'user';
          fullName = await _apiClient.getUserName() ?? fullName;
        }
      }

      await _apiClient.saveToken(uid);
      await _apiClient.saveUserSession(
        role: role,
        name: fullName.isNotEmpty ? fullName : email.split('@').first,
        email: email.trim(),
      );

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

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } finally {
      await _apiClient.clearToken();
    }
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      await _apiClient.clearToken();
      return;
    }

    final uid = user.uid;
    try {
      // 1. Delete Firestore user document & profile document
      try {
        await _firestore.collection('users').doc(uid).delete();
        await _firestore.collection('profiles').doc(uid).delete();
      } catch (_) {
        // Continue if Firestore document delete fails or is offline
      }

      // 2. Delete Firebase Auth account
      await user.delete();
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw ApiException(
          statusCode: 401,
          code: 'REQUIRES_RECENT_LOGIN',
          message: 'Demi keamanan, silakan keluar dan masuk kembali sebelum menghapus akun.',
        );
      }
      throw ApiException(
        statusCode: 400,
        code: 'DELETE_ACCOUNT_FAILED',
        message: e.message ?? 'Gagal menghapus akun.',
      );
    } finally {
      await _apiClient.clearToken();
    }
  }

  Future<bool> isLoggedIn() async {
    if (_auth.currentUser != null) return true;
    final token = await _apiClient.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getRole() async {
    return await _apiClient.getRole();
  }

  Future<String?> getUserName() async {
    return _auth.currentUser?.displayName ?? await _apiClient.getUserName();
  }

  Future<String?> getUserEmail() async {
    return _auth.currentUser?.email ?? await _apiClient.getUserEmail();
  }
}
