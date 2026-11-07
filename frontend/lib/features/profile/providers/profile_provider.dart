import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/data/models/profile.dart';
import 'package:nutriview/data/models/user.dart';
import 'package:nutriview/data/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  User? _user;
  UserProfile? _profile;
  DailyTarget? _dailyTarget;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileProvider(this._repository);

  User? get user => _user;
  UserProfile? get profile => _profile;
  DailyTarget? get dailyTarget => _dailyTarget;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasProfile => _profile != null;
  bool get isProfileComplete {
    if (_profile == null) return false;
    return _profile!.heightCm >= 50 &&
        _profile!.weightKg >= 20 &&
        (_profile!.birthDate != null || _profile!.age > 0) &&
        _profile!.sex.isNotEmpty &&
        _profile!.activityLevel.isNotEmpty;
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repository.getUser();
      _profile = _user?.profile;
      if (_profile != null) {
        try {
          _dailyTarget = await _repository.getDailyTarget();
        } catch (_) {}
      }
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
    } catch (_) {
      _errorMessage = 'Gagal memuat profil pengguna.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile(UserProfile newProfile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.updateProfile(newProfile);
      _dailyTarget = await _repository.getDailyTarget();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal menyimpan profil.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAvatar({String? photoUrl, String? avatarPreset}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateAvatar(
        photoUrl: photoUrl,
        avatarPreset: avatarPreset,
      );
      // Reload profile to refresh user object across app
      await loadProfile();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal memperbarui avatar.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfilePhoto(Uint8List imageBytes) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repository.updateProfilePhoto(imageBytes);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal memperbarui foto profil.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProfilePhoto() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteProfilePhoto();
      if (_user != null) {
        _user = _user!.copyWith(clearPhoto: true);
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal menghapus foto profil.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveBiodata({
    required String fullName,
    required UserProfile newProfile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.saveBiodata(
        fullName: fullName,
        profile: newProfile,
      );
      _dailyTarget = await _repository.getDailyTarget();
      await loadProfile();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal menyimpan biodata pengguna.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBiodata() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteBiodata();
      _profile = null;
      _dailyTarget = null;
      await loadProfile();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal menghapus biodata pengguna.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _user = null;
    _profile = null;
    _dailyTarget = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
