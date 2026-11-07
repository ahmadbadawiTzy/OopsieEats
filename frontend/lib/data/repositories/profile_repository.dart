import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/core/nutrition_calculator.dart';
import 'package:nutriview/data/api_client.dart';
import 'package:nutriview/core/profile_photo_logger.dart';
import 'package:nutriview/data/models/profile.dart';
import 'package:nutriview/data/models/user.dart';
import 'package:nutriview/data/services/supabase_storage_service.dart';

class ProfileRepository {
  final ApiClient _apiClient;
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final SupabaseStorageService _storageService;

  ProfileRepository([
    ApiClient? apiClient,
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    SupabaseStorageService? storageService,
  ]) : _apiClient = apiClient ?? ApiClient(),
       _auth = auth ?? fb.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storageService = storageService ?? SupabaseStorageService();

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

      final photoPath = data['photo_path'] as String?;
      String? photoUrl = data['photo_url'] as String?;

      if (photoPath != null && photoPath.isNotEmpty) {
        try {
          final signed = await _storageService.getSignedImageUrl(photoPath);
          if (signed != null && signed.isNotEmpty) {
            photoUrl = signed;
          }
        } catch (_) {}
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
        isProfileComplete: (data['is_profile_complete'] as bool?) ??
            (profile != null &&
                profile.heightCm >= 50 &&
                profile.weightKg >= 20 &&
                (profile.birthDate != null || profile.age > 0) &&
                profile.sex.isNotEmpty &&
                profile.activityLevel.isNotEmpty),
        profile: profile,
        photoUrl: photoUrl,
        photoPath: photoPath,
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
        'is_profile_complete': true,
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

  /// Uploads, compresses, and persists a real profile photo to Supabase Storage and Firestore.
  /// Automatically cleans up previous photo object from Supabase Storage.
  Future<User> updateProfilePhoto(Uint8List imageBytes) async {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) {
      throw ApiException(
        statusCode: 401,
        code: 'UNAUTHORIZED',
        message: 'Pengguna belum terautentikasi.',
      );
    }

    try {
      // 1. Fetch current document to identify existing photo path
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final oldPath = userDoc.data()?['photo_path'] as String?;

      // 2. Compress (1:1 square crop, max 512px) and upload to Supabase Storage
      final newPath = await _storageService.uploadProfilePhoto(
        userId: uid,
        imageBytes: imageBytes,
      );

      // 3. Generate initial signed URL
      final signedUrl = await _storageService.getSignedImageUrl(newPath);

      // 4. Update Firestore user document
      final firestoreStopwatch = Stopwatch()..start();
      try {
        await _firestore.collection('users').doc(uid).set({
          'photo_path': newPath,
          'photo_url': signedUrl,
          'avatar_preset': FieldValue.delete(),
          'updated_at': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
        ProfilePhotoLogger.log(
          stage: 'STAGE_9_FIRESTORE_UPDATE',
          status: 'SUCCESS',
          uid: uid,
          path: newPath,
          durationMs: firestoreStopwatch.elapsedMilliseconds,
        );
      } catch (e) {
        ProfilePhotoLogger.log(
          stage: 'STAGE_9_FIRESTORE_UPDATE',
          status: 'FAILED',
          uid: uid,
          path: newPath,
          durationMs: firestoreStopwatch.elapsedMilliseconds,
          error: e,
        );
        rethrow;
      }

      // 5. Delete previous storage object if different
      if (oldPath != null && oldPath.isNotEmpty && oldPath != newPath) {
        await _storageService.deleteProfilePhoto(oldPath);
      }

      // 6. Return refreshed user
      final refreshStopwatch = Stopwatch()..start();
      try {
        final refreshedUser = await getUser();
        ProfilePhotoLogger.log(
          stage: 'STAGE_11_USER_REFRESH',
          status: 'SUCCESS',
          uid: uid,
          path: newPath,
          durationMs: refreshStopwatch.elapsedMilliseconds,
        );
        return refreshedUser;
      } catch (e) {
        ProfilePhotoLogger.log(
          stage: 'STAGE_11_USER_REFRESH',
          status: 'FAILED',
          uid: uid,
          path: newPath,
          durationMs: refreshStopwatch.elapsedMilliseconds,
          error: e,
        );
        rethrow;
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 500,
        code: 'PROFILE_PHOTO_UPLOAD_FAILED',
        message: 'Gagal mengunggah foto profil.',
      );
    }
  }

  /// Permanently removes profile photo reference from Firestore and deletes file from Supabase Storage.
  Future<void> deleteProfilePhoto() async {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) {
      throw ApiException(
        statusCode: 401,
        code: 'UNAUTHORIZED',
        message: 'Pengguna belum terautentikasi.',
      );
    }

    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final oldPath = userDoc.data()?['photo_path'] as String?;

      await _firestore.collection('users').doc(uid).set({
        'photo_path': FieldValue.delete(),
        'photo_url': FieldValue.delete(),
        'avatar_preset': FieldValue.delete(),
        'updated_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      if (oldPath != null && oldPath.isNotEmpty) {
        await _storageService.deleteProfilePhoto(oldPath);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 500,
        code: 'PROFILE_PHOTO_DELETE_FAILED',
        message: 'Gagal menghapus foto profil.',
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
        'is_profile_complete': false,
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
        'is_profile_complete': true,
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
