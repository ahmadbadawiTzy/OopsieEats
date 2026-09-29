class UserProfile {
  final int age;
  final String sex;
  final double weightKg;
  final double heightCm;
  final String activityLevel;
  final String goal;

  UserProfile({
    required this.age,
    required this.sex,
    required this.weightKg,
    required this.heightCm,
    required this.activityLevel,
    required this.goal,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      age: json['age'] as int,
      sex: json['sex'] as String,
      weightKg: (json['weight_kg'] as num).toDouble(),
      heightCm: (json['height_cm'] as num).toDouble(),
      activityLevel: json['activity_level'] as String,
      goal: json['goal'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'sex': sex,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'activity_level': activityLevel,
      'goal': goal,
    };
  }

  String get sexLabel => sex == 'male' ? 'Laki-laki' : 'Perempuan';

  String get activityLabel {
    switch (activityLevel) {
      case 'sedentary':
        return 'Sedentari (jarang olahraga)';
      case 'light':
        return 'Ringan (olahraga 1-3 hari/minggu)';
      case 'moderate':
        return 'Sedang (olahraga 3-5 hari/minggu)';
      case 'active':
        return 'Aktif (olahraga 6-7 hari/minggu)';
      case 'very_active':
        return 'Sangat Aktif (latihan fisik berat)';
      default:
        return activityLevel;
    }
  }

  String get goalLabel {
    switch (goal) {
      case 'lose_weight':
        return 'Menurunkan berat badan';
      case 'maintain_weight':
        return 'Mempertahankan berat badan';
      case 'gain_weight':
        return 'Menambah berat badan';
      default:
        return goal;
    }
  }
}
