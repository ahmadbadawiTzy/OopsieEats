import 'package:flutter/material.dart';
import 'package:oopsieeats/core/error_handler.dart';
import 'package:oopsieeats/data/models/dashboard.dart';
import 'package:oopsieeats/data/repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repository;

  DailyDashboard? _dashboard;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isProfileIncomplete = false;

  DashboardProvider(this._repository);

  DailyDashboard? get dashboard => _dashboard;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isProfileIncomplete => _isProfileIncomplete;

  void invalidateCache() {
    _repository.invalidateUserCache();
  }

  Future<void> loadDashboard({
    DateTime? date,
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      _repository.invalidateUserCache();
    }
    if (date != null) {
      _selectedDate = date;
    }
    _isLoading = true;
    _errorMessage = null;
    _isProfileIncomplete = false;
    notifyListeners();

    try {
      _dashboard = await _repository.getDailyDashboard(
        _selectedDate,
        forceRefresh: forceRefresh,
      );
    } on ApiException catch (e) {
      if (e.code == 'PROFILE_INCOMPLETE') {
        _isProfileIncomplete = true;
      }
      _errorMessage = e.friendlyMessage;
    } catch (_) {
      _errorMessage = 'Gagal memuat dashboard harian.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void changeDate(DateTime newDate) {
    _selectedDate = newDate;
    loadDashboard(date: newDate);
  }

  void clear() {
    _dashboard = null;
    _selectedDate = DateTime.now();
    _isLoading = false;
    _errorMessage = null;
    _isProfileIncomplete = false;
    notifyListeners();
  }
}
