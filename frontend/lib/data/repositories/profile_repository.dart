import 'package:nutriview/data/api_client.dart';
import 'package:nutriview/data/models/meal.dart';
import 'package:nutriview/data/models/profile.dart';
import 'package:nutriview/data/models/user.dart';

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<User> getUser() async {
    final response = await _apiClient.get('/users/me');
    return User.fromJson(response as Map<String, dynamic>);
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    final response = await _apiClient.put(
      '/users/me/profile',
      body: profile.toJson(),
    );
    return UserProfile.fromJson(response as Map<String, dynamic>);
  }

  Future<DailyTarget> getDailyTarget() async {
    final response = await _apiClient.get('/nutrition/target');
    return DailyTarget.fromJson(response as Map<String, dynamic>);
  }
}
