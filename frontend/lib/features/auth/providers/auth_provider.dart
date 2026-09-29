import 'package:flutter/material.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._repository);

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      _isLoggedIn = await _repository.isLoggedIn();
    } catch (_) {
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.login(email: email, password: password);
      _isLoggedIn = true;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      return false;
    } catch (e) {
      _errorMessage = 'Gagal terhubung ke server.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String fullName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      // Auto-login after registration
      await _repository.login(email: email, password: password);
      _isLoggedIn = true;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      return false;
    } catch (e) {
      _errorMessage = 'Gagal terhubung ke server.';
      return false;
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
    _errorMessage = null;
    notifyListeners();
  }

  void handleSessionExpired() {
    _isLoggedIn = false;
    _errorMessage = 'Sesi Anda telah kedaluwarsa. Silakan login kembali.';
    notifyListeners();
  }
}
