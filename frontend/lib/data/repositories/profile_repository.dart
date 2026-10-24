import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/core/nutrition_calculator.dart';
import 'package:nutriview/data/api_client.dart';
import 'package:nutriview/data/models/profile.dart';
import 'package:nutriview/data/models/user.dart';

class ProfileRepository {
  final ApiClient _apiClient;
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ProfileRepository([
    ApiClient? apiClient,
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  ]) : _apiClient = apiClient ?? ApiClient(),
       _auth = auth ?? fb.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  String? get _currentUid => _auth.currentUser?.uid;

  Future<User> getUser() async {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) {
      throw ApiException(
        statusCode: 401,
        code: 'UNAUTHORIZED',
        message: 'Pengguna belum terautentikasi.',
      );
    }

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        final email =
            _auth.currentUser?.email ?? await _apiClient.getUserEmail() ?? '';
        final name =
            _auth.currentUser?.displayName ??
            await _apiClient.getUserName() ??
            '';
        final role = await _apiClient.getRole() ?? 'user';
        return User(
          id: uid.hashCode.abs(),
          email: email,
          fullName: name,
          role: role,
          isActive: true,
        );
      }

      final data = doc.data()!;
      UserProfile? profile;
      if (data['profile'] != null) {
        profile = UserProfile.fromJson(
          Map<String, dynamic>.from(data['profile'] as Map),
        );
      }

      return User(
        id: (data['id'] as num?)?.toInt() ?? uid.hashCode.abs(),
        email: data['email'] as String? ?? _auth.currentUser?.email ?? '',
        fullName:
            data['full_name'] as String? ??
            _auth.currentUser?.displayName ??
            '',
        role: data['role'] as String? ?? 'user',
        isActive: data['is_active'] as bool? ?? true,
        profile: profile,
        photoUrl: data['photo_url'] as String?,
        avatarPreset: data['avatar_preset'] as String?,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 500,
        code: 'PROFILE_LOAD_FAILED',
        message: 'Gagal memuat profil pengguna.',
      );
    }
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) {
      throw ApiException(
        statusCode: 401,
        code: 'UNAUTHORIZED',
        message: 'Pengguna belum terautentikasi.',
      );
    }

    try {
      // Calculate daily targets deterministically
      final target = NutritionCalculator.calculateDailyTarget(
        age: profile.age,
        sex: profile.sex,
        weightKg: profile.weightKg,
        heightCm: profile.heightCm,
        activityLevel: profile.activityLevel,
        goal: profile.goal,
      );

      final targetMap = {
        'calories_kcal': target.caloriesKcal,
        'protein_g': target.proteinG,
        'carbs_g': target.carbsG,
        'fat_g': target.fatG,
        'basis': {
          'bmr_kcal': target.bmrKcal,
          'tdee_kcal': target.tdeeKcal,
          'formula': 'mifflin_st_jeor',
        },
      };

      await _firestore.collection('users').doc(uid).set({
        'profile': profile.toJson(),
        'daily_target': targetMap,
        'updated_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      return profile;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 500,
        code: 'PROFILE_UPDATE_FAILED',
        message: 'Gagal memperbarui profil pengguna.',
      );
    }
  }

  Future<DailyTarget> getDailyTarget() async {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) {
      throw ApiException(
        statusCode: 401,
        code: 'UNAUTHORIZED',
        message: 'Pengguna belum terautentikasi.',
      );
    }

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        throw ApiException(
          statusCode: 400,
          code: 'PROFILE_INCOMPLETE',
          message: 'Profil Anda belum lengkap. Silakan lengkapi profil terlebih dahulu.',
        );
      }

      final data = doc.data()!;
      if (data['daily_target'] != null) {
        return DailyTarget.fromJson(
          Map<String, dynamic>.from(data['daily_target'] as Map),
        );
      }

      if (data['profile'] != null) {
        final profile = UserProfile.fromJson(
          Map<String, dynamic>.from(data['profile'] as Map),
        );
        final target = NutritionCalculator.calculateDailyTarget(
          age: profile.age,
          sex: profile.sex,
          weightKg: profile.weightKg,
          heightCm: profile.heightCm,
          activityLevel: profile.activityLevel,
          goal: profile.goal,
        );

        // Cache computed target
        await _firestore.collection('users').doc(uid).set({
          'daily_target': {
            'calories_kcal': target.caloriesKcal,
            'protein_g': target.proteinG,
            'carbs_g': target.carbsG,
            'fat_g': target.fatG,
            'basis': {
              'bmr_kcal': target.bmrKcal,
              'tdee_kcal': target.tdeeKcal,
              'formula': 'mifflin_st_jeor',
            },
          },
        }, SetOptions(merge: true));

        return target;
      }

      throw ApiException(
        statusCode: 400,
        code: 'PROFILE_INCOMPLETE',
        message: 'Profil Anda belum lengkap. Silakan lengkapi profil terlebih dahulu.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 500,
        code: 'TARGET_FETCH_FAILED',
        message: 'Gagal memuat target nutrisi harian.',
      );
    }
  }

  Future<void> updateAvatar({String? photoUrl, String? avatarPreset}) async {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) {
      throw ApiException(
        statusCode: 401,
        code: 'UNAUTHORIZED',
        message: 'Pengguna belum terautentikasi.',
      );
    }

    try {
      final updateData = <String, dynamic>{
        'photo_url': photoUrl,
        'avatar_preset': avatarPreset,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _firestore
          .collection('users')
          .doc(uid)
          .set(updateData, SetOptions(merge: true));
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 500,
        code: 'AVATAR_UPDATE_FAILED',
        message: 'Gagal memperbarui avatar pengguna.',
      );
    }
  }

  Future<void> deleteBiodata() async {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) {
      throw ApiException(
        statusCode: 401,
        code: 'UNAUTHORIZED',
        message: 'Pengguna belum terautentikasi.',
      );
    }

    try {
      await _firestore.collection('users').doc(uid).update({
        'profile': FieldValue.delete(),
        'daily_target': FieldValue.delete(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 500,
        code: 'BIODATA_DELETE_FAILED',
        message: 'Gagal menghapus biodata pengguna.',
      );
    }
  }

  Future<UserProfile> saveBiodata({
    required String fullName,
    required UserProfile profile,
  }) async {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) {
      throw ApiException(
        statusCode: 401,
        code: 'UNAUTHORIZED',
        message: 'Pengguna belum terautentikasi.',
      );
    }

    try {
      final target = NutritionCalculator.calculateDailyTarget(
        age: profile.calculatedAge,
        sex: profile.sex,
        weightKg: profile.weightKg,
        heightCm: profile.heightCm,
        activityLevel: profile.activityLevel,
        goal: profile.goal,
      );

      final targetMap = {
        'calories_kcal': target.caloriesKcal,
        'protein_g': target.proteinG,
        'carbs_g': target.carbsG,
        'fat_g': target.fatG,
        'basis': {
          'bmr_kcal': target.bmrKcal,
          'tdee_kcal': target.tdeeKcal,
          'formula': 'mifflin_st_jeor',
        },
      };

      await _firestore.collection('users').doc(uid).set({
        'full_name': fullName.trim(),
        'profile': profile.toJson(),
        'daily_target': targetMap,
        'updated_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      return profile;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 500,
        code: 'BIODATA_SAVE_FAILED',
        message: 'Gagal menyimpan biodata pengguna.',
      );
    }
  }
}
