import 'package:flutter/material.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/data/models/meal.dart';
import 'package:nutriview/data/repositories/meal_repository.dart';

class MealHistoryProvider extends ChangeNotifier {
  final MealRepository _repository;

  List<MealRecord> _meals = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _filterDate;

  MealHistoryProvider(this._repository);

  List<MealRecord> get meals => _meals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get filterDate => _filterDate;

  Future<void> loadMeals({DateTime? date}) async {
    _filterDate = date;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _meals = await _repository.getMeals(
        dateFrom: date,
        dateTo: date,
        page: 1,
        pageSize: 50,
      );
    } on ApiException catch (e) {
      _errorMessage = e.friendlyMessage;
    } catch (_) {
      _errorMessage = 'Gagal memuat riwayat makan.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearFilter() {
    loadMeals(date: null);
  }
}
