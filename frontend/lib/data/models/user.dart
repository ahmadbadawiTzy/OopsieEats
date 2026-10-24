import 'package:nutriview/data/models/profile.dart';

class User {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final UserProfile? profile;
  final String? photoUrl;
  final String? avatarPreset;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.role = 'user',
    this.isActive = true,
    this.profile,
    this.photoUrl,
    this.avatarPreset,
  });

  bool get isAdmin =>
      role == 'super_admin' || role == 'dietitian' || role == 'editor';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      isActive: json['is_active'] as bool? ?? true,
      profile: json['profile'] != null
          ? UserProfile.fromJson(
              Map<String, dynamic>.from(json['profile'] as Map),
            )
          : null,
      photoUrl: json['photo_url'] as String?,
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
      'profile': profile?.toJson(),
      'photo_url': photoUrl,
      'avatar_preset': avatarPreset,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? fullName,
    String? role,
    bool? isActive,
    UserProfile? profile,
    String? photoUrl,
    String? avatarPreset,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      profile: profile ?? this.profile,
      photoUrl: photoUrl ?? this.photoUrl,
      avatarPreset: avatarPreset ?? this.avatarPreset,
    );
  }
}
