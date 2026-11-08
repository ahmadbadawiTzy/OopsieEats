import 'package:oopsieeats/data/models/profile.dart';

class User {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final bool isProfileComplete;
  final UserProfile? profile;
  final String? photoUrl;
  final String? photoPath;
  final String? avatarPreset;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.role = 'user',
    this.isActive = true,
    this.isProfileComplete = false,
    this.profile,
    this.photoUrl,
    this.photoPath,
    this.avatarPreset,
  });

  bool get isAdmin => role.toLowerCase().trim() == 'admin';
  bool get hasCompleteProfile => isProfileComplete;

  factory User.fromJson(Map<String, dynamic> json) {
    final parsedProfile = json['profile'] != null
        ? UserProfile.fromJson(
            Map<String, dynamic>.from(json['profile'] as Map),
          )
        : null;

    final bool computedComplete =
        parsedProfile != null &&
        parsedProfile.heightCm >= 50 &&
        parsedProfile.weightKg >= 20 &&
        (parsedProfile.birthDate != null || parsedProfile.age > 0) &&
        parsedProfile.sex.isNotEmpty &&
        parsedProfile.activityLevel.isNotEmpty;

    return User(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      isActive: json['is_active'] as bool? ?? true,
      isProfileComplete:
          json['is_profile_complete'] as bool? ?? computedComplete,
      profile: parsedProfile,
      photoUrl: json['photo_url'] as String?,
      photoPath: json['photo_path'] as String?,
      avatarPreset: json['avatar_preset'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'is_active': isActive,
      'is_profile_complete': isProfileComplete,
      'profile': profile?.toJson(),
      'photo_url': photoUrl,
      'photo_path': photoPath,
      'avatar_preset': avatarPreset,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? fullName,
    String? role,
    bool? isActive,
    bool? isProfileComplete,
    UserProfile? profile,
    String? photoUrl,
    String? photoPath,
    String? avatarPreset,
    bool clearPhoto = false,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      profile: profile ?? this.profile,
      photoUrl: clearPhoto ? null : (photoUrl ?? this.photoUrl),
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      avatarPreset: clearPhoto ? null : (avatarPreset ?? this.avatarPreset),
    );
  }
}
