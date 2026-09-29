import 'package:nutriview/data/models/profile.dart';

class User {
  final int id;
  final String email;
  final String fullName;
  final UserProfile? profile;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'profile': profile?.toJson(),
    };
  }
}
