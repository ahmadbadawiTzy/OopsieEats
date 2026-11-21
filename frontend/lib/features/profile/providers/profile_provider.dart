import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:oopsieeats/core/error_handler.dart';
import 'package:oopsieeats/core/nutrition_calculator.dart';
import 'package:oopsieeats/data/models/profile.dart';
import 'package:oopsieeats/data/models/user.dart';
import 'package:oopsieeats/data/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  User? _user;
  UserProfile? _profile;
  DailyTarget? _dailyTarget;
  bool _isLoading = false;
  String? _errorMessage;
  int _biodataVersion = 0;
  int _operationId = 0;

  VoidCallback? onProfileUpdated;

  ProfileProvider(this._repository);

  User? get user => _user;
  UserProfile? get profile => _profile;
  DailyTarget? get dailyTarget => _dailyTarget;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get biodataVersion => _biodataVersion;
  bool get hasProfile => _profile != null;
  bool get isProfileComplete {
    if (_profile == null) return false;
    return _profile!.heightCm >= 50 &&
        _profile!.weightKg >= 20 &&
        (_profile!.birthDate != null || _profile!.age > 0) &&
        _profile!.sex.isNotEmpty &&
        _profile!.activityLevel.isNotEmpty;
  }

  DailyTarget _calculateTargetFor(UserProfile p) {
    return NutritionCalculator.calculateDailyTarget(
      age: p.calculatedAge,
      sex: p.sex,
      weightKg: p.weightKg,
      heightCm: p.heightCm,
      activityLevel: p.activityLevel,
      goal: p.goal,
    );
  }

  Future<void> loadProfile() async {
    final opId = ++_operationId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedUser = await _repository.getUser();
      if (opId != _operationId) return;
      _user = loadedUser;
      _profile = _user?.profile;
      if (_profile != null) {
        try {
          final target = await _repository.getDailyTarget();
          if (opId != _operationId) return;
          _dailyTarget = target;
        } catch (_) {
          if (opId != _operationId) return;
          _dailyTarget ??= _calculateTargetFor(_profile!);
        }
      }
    } on ApiException catch (e) {
      if (opId != _operationId) return;
      _errorMessage = e.friendlyMessage;
    } catch (_) {
      if (opId != _operationId) return;
      _errorMessage = 'Gagal memuat profil pengguna.';
    } finally {
      if (opId == _operationId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> saveProfile(UserProfile newProfile) async {
    final opId = ++_operationId;
    final previousProfile = _profile;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final savedProfile = await _repository.updateProfile(newProfile);
      if (opId != _operationId) return true;

      final metricsChanged =
          _dailyTarget == null ||
          !savedProfile.hasSameNutritionMetrics(previousProfile);

      _profile = savedProfile;
      if (_user != null) {
        _user = _user!.copyWith(
          profile: savedProfile,
          isProfileComplete: true,
        );
      }

      if (metricsChanged) {
        _dailyTarget = _calculateTargetFor(savedProfile);
        _biodataVersion++;
        onProfileUpdated?.call();
      }
      return true;
    } on ApiException catch (e) {
      if (opId == _operationId) {
        _errorMessage = e.friendlyMessage;
      }
      return false;
    } catch (_) {
      if (opId == _operationId) {
        _errorMessage = 'Gagal menyimpan profil.';
      }
      return false;
    } finally {
      if (opId == _operationId) {
        _isLoading = false;
        notifyListeners();
      }
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
    final opId = ++_operationId;
    final previousProfile = _profile;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanedName = fullName.trim();
      final savedProfile = await _repository.saveBiodata(
        fullName: cleanedName,
        profile: newProfile,
      );
      if (opId != _operationId) return true;

      final metricsChanged =
          _dailyTarget == null ||
          !savedProfile.hasSameNutritionMetrics(previousProfile);

      _profile = savedProfile;
      if (_user != null) {
        _user = _user!.copyWith(
          fullName: cleanedName.isNotEmpty ? cleanedName : _user!.fullName,
          profile: savedProfile,
          isProfileComplete: true,
        );
      } else {
        _user = User(
          id: 1,
          email: '',
          fullName: cleanedName,
          isProfileComplete: true,
          profile: savedProfile,
        );
      }

      if (metricsChanged) {
        _dailyTarget = _calculateTargetFor(savedProfile);
        _biodataVersion++;
        onProfileUpdated?.call();
      }
      return true;
    } on ApiException catch (e) {
      if (opId == _operationId) {
        _errorMessage = e.friendlyMessage;
      }
      return false;
    } catch (_) {
      if (opId == _operationId) {
        _errorMessage = 'Gagal menyimpan biodata pengguna.';
      }
      return false;
    } finally {
      if (opId == _operationId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> deleteBiodata() async {
    final opId = ++_operationId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteBiodata();
      if (opId != _operationId) return true;

      _profile = null;
      _dailyTarget = null;
      if (_user != null) {
        _user = User(
          id: _user!.id,
          email: _user!.email,
          fullName: _user!.fullName,
          role: _user!.role,
          isActive: _user!.isActive,
          isProfileComplete: false,
          profile: null,
          photoUrl: _user!.photoUrl,
          photoPath: _user!.photoPath,
          avatarPreset: _user!.avatarPreset,
        );
      }
      _biodataVersion++;
      onProfileUpdated?.call();
      return true;
    } on ApiException catch (e) {
      if (opId == _operationId) {
        _errorMessage = e.friendlyMessage;
      }
      return false;
    } catch (_) {
      if (opId == _operationId) {
        _errorMessage = 'Gagal menghapus biodata pengguna.';
      }
      return false;
    } finally {
      if (opId == _operationId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clear() {
    _operationId++;
    _biodataVersion = 0;
    _user = null;
    _profile = null;
    _dailyTarget = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
