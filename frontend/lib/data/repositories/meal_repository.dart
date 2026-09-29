import 'package:intl/intl.dart';
import 'package:nutriview/data/api_client.dart';
import 'package:nutriview/data/models/meal.dart';

class MealRepository {
  final ApiClient _apiClient;

  MealRepository(this._apiClient);

  Future<MealRecord> createMeal({
    required String mealType,
    required DateTime consumedAt,
    required List<Map<String, dynamic>> items,
  }) async {
    // Format ISO 8601 with offset
    final isoDate = consumedAt.toIso8601String();
    // Ensure offset is present
    final offsetStr = consumedAt.timeZoneOffset.isNegative ? '-' : '+';
    final offsetHours = consumedAt.timeZoneOffset.inHours.abs().toString().padLeft(2, '0');
    final offsetMinutes =
        (consumedAt.timeZoneOffset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final formattedTime = '$isoDate$offsetStr$offsetHours:$offsetMinutes';

    final response = await _apiClient.post(
      '/meals',
      body: {
        'meal_type': mealType,
        'consumed_at': formattedTime,
        'items': items,
      },
    );
    return MealRecord.fromJson(response as Map<String, dynamic>);
  }

  Future<List<MealRecord>> getMeals({
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
    int pageSize = 20,
  }) async {
    final Map<String, dynamic> params = {
      'page': page,
      'page_size': pageSize,
    };
    final formatter = DateFormat('yyyy-MM-dd');
    if (dateFrom != null) {
      params['date_from'] = formatter.format(dateFrom);
    }
    if (dateTo != null) {
      params['date_to'] = formatter.format(dateTo);
    }

    final response = await _apiClient.get('/meals', queryParameters: params);
    final items = response['items'] as List;
    return items.map((json) => MealRecord.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<MealRecord> getMealDetail(int id) async {
    final response = await _apiClient.get('/meals/$id');
    return MealRecord.fromJson(response as Map<String, dynamic>);
  }
}
