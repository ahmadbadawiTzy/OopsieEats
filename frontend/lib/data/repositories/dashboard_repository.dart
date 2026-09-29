import 'package:intl/intl.dart';
import 'package:nutriview/data/api_client.dart';
import 'package:nutriview/data/models/dashboard.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<DailyDashboard> getDailyDashboard(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final response = await _apiClient.get(
      '/dashboard/daily',
      queryParameters: {'date': dateStr},
    );
    return DailyDashboard.fromJson(response as Map<String, dynamic>);
  }
}
