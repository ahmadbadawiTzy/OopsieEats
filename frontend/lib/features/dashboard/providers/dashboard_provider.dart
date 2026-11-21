import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oopsieeats/core/error_handler.dart';
import 'package:oopsieeats/core/nutrition_calculator.dart';
import 'package:oopsieeats/data/models/dashboard.dart';
import 'package:oopsieeats/data/models/meal.dart';
import 'package:oopsieeats/data/repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repository;

  DailyDashboard? _dashboard;
  DailyTarget? _activeTargetOverride;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isProfileIncomplete = false;
  int _loadRequestId = 0;

  DashboardProvider(this._repository);

  DailyDashboard? get dashboard => _dashboard;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isProfileIncomplete => _isProfileIncomplete;

  void invalidateCache() {
    _repository.invalidateUserCache();
  }

  /// Immediately updates the active dashboard target & progress in memory
  /// when biodata changes, avoiding stale cached values and unnecessary network waits.
  void updateTargetFromBiodata(DailyTarget target) {
    _repository.invalidateUserCache();
    _activeTargetOverride = target;
    final stateFlagsChanged = _isProfileIncomplete || _errorMessage != null;
    _isProfileIncomplete = false;
    _errorMessage = null;

    if (_dashboard != null) {
      final newCal = NutritionCalculator.roundHalfUp(
        target.caloriesKcal.toDouble(),
        1,
      );
      final newPro = NutritionCalculator.roundHalfUp(target.proteinG, 1);
      final newCarb = NutritionCalculator.roundHalfUp(target.carbsG, 1);
      final newFat = NutritionCalculator.roundHalfUp(target.fatG, 1);

      final currentTarget = _dashboard!.target;
      final targetChanged =
          currentTarget.caloriesKcal != newCal ||
          currentTarget.proteinG != newPro ||
          currentTarget.carbsG != newCarb ||
          currentTarget.fatG != newFat;

      _dashboard = _dashboard!.withUpdatedTarget(target);
      if (targetChanged || stateFlagsChanged) {
        notifyListeners();
      }
    } else {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final zeroTotals = MealNutritionTotals(
        caloriesKcal: 0,
        proteinG: 0,
        carbsG: 0,
        fatG: 0,
      );
      final zeroProgress = NutrientProgress(
        consumed: 0,
        target: 0,
        percentage: 0,
      );
      _dashboard = DailyDashboard(
        date: dateStr,
        mealCount: 0,
        target: zeroTotals,
        consumed: zeroTotals,
        progress: DashboardProgress(
          calories: zeroProgress,
          protein: zeroProgress,
          carbs: zeroProgress,
          fat: zeroProgress,
        ),
      ).withUpdatedTarget(target);
      notifyListeners();
    }
  }

  void handleBiodataDeleted() {
    _repository.invalidateUserCache();
    _activeTargetOverride = null;
    _isProfileIncomplete = true;
    notifyListeners();
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
    final requestId = ++_loadRequestId;
    _isLoading = true;
    _errorMessage = null;
    _isProfileIncomplete = false;
    notifyListeners();

    try {
      var loaded = await _repository.getDailyDashboard(_selectedDate);
      if (requestId != _loadRequestId) return;
      if (_activeTargetOverride != null) {
        loaded = loaded.withUpdatedTarget(_activeTargetOverride!);
      }
      _dashboard = loaded;
    } on ApiException catch (e) {
      if (requestId != _loadRequestId) return;
      if (e.code == 'PROFILE_INCOMPLETE') {
        _isProfileIncomplete = true;
      }
      _errorMessage = e.friendlyMessage;
    } catch (_) {
      if (requestId != _loadRequestId) return;
      _errorMessage = 'Gagal memuat dashboard harian.';
    } finally {
      if (requestId == _loadRequestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void changeDate(DateTime newDate) {
    _selectedDate = newDate;
    loadDashboard(date: newDate);
  }

  void clear() {
    _loadRequestId++;
    _dashboard = null;
    _activeTargetOverride = null;
    _selectedDate = DateTime.now();
    _isLoading = false;
    _errorMessage = null;
    _isProfileIncomplete = false;
    notifyListeners();
  }
}
