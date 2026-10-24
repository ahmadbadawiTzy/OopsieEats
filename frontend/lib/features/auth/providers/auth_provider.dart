import 'package:flutter/material.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/data/models/user.dart';
import 'package:nutriview/data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  String? _savedRole;
  String? _savedName;
  String? _savedEmail;

  AuthProvider(this._repository);

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  String get role => _currentUser?.role ?? _savedRole ?? 'user';
  String get name => _currentUser?.fullName ?? _savedName ?? 'User';
  String get email => _currentUser?.email ?? _savedEmail ?? '';

  bool get isAdmin =>
      role == 'super_admin' || role == 'dietitian' || role == 'editor';

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      _isLoggedIn = await _repository.isLoggedIn();
      if (_isLoggedIn) {
        _savedRole = await _repository.getRole();
        _savedName = await _repository.getUserName();
        _savedEmail = await _repository.getUserEmail();
      }
    } catch (_) {
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<User?> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.login(email: email, password: password);
      _isLoggedIn = true;
      _currentUser = user;
      _savedRole = user.role;
      _savedName = user.fullName;
      _savedEmail = user.email;
      return user;
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      return null;
    } catch (e) {
      _errorMessage = 'Gagal terhubung ke server.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<User?> register(String email, String password, String fullName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      // Auto-login after registration (Strictly user role)
      final user = await _repository.login(email: email, password: password);
      _isLoggedIn = true;
      _currentUser = user;
      _savedRole = user.role;
      _savedName = user.fullName;
      _savedEmail = user.email;
      return user;
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      return null;
    } catch (e) {
      _errorMessage = 'Gagal terhubung ke server.';
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
    _isLoggedIn = false;
    _currentUser = null;
    _savedRole = null;
    _savedName = null;
    _savedEmail = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteAccount();
      _isLoggedIn = false;
      _currentUser = null;
      _savedRole = null;
      _savedName = null;
      _savedEmail = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal menghapus akun.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void handleSessionExpired() {
    _isLoggedIn = false;
    _currentUser = null;
    _savedRole = null;
    _savedName = null;
    _savedEmail = null;
    _errorMessage = 'Sesi Anda telah kedaluwarsa. Silakan login kembali.';
    notifyListeners();
  }
}
