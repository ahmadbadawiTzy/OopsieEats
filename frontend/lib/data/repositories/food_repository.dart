import 'dart:io';
import 'package:nutriview/data/api_client.dart';
import 'package:nutriview/data/models/food.dart';

class FoodRepository {
  final ApiClient _apiClient;

  FoodRepository(this._apiClient);

  Future<List<FoodItem>> searchFoods({
    String? query,
    int page = 1,
    int pageSize = 20,
  }) async {
    final Map<String, dynamic> params = {
      'page': page,
      'page_size': pageSize,
    };
    if (query != null && query.trim().isNotEmpty) {
      params['q'] = query.trim();
    }

    final response = await _apiClient.get('/foods', queryParameters: params);
    final items = response['items'] as List;
    return items.map((json) => FoodItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<FoodDetail> getFoodDetail(int id) async {
    final response = await _apiClient.get('/foods/$id');
    return FoodDetail.fromJson(response as Map<String, dynamic>);
  }

  Future<List<DetectionItem>> detectFood(File imageFile) async {
    final response = await _apiClient.uploadImage('/foods/detect', imageFile);
    final detections = response['detections'] as List;
    return detections
        .map((json) => DetectionItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
