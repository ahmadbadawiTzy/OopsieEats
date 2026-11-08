import 'package:oopsieeats/core/age_calculator.dart';

class UserProfile {
  static const List<String> predefinedProfessions = [
    'Umum',
    'Ahli Gizi',
    'Dokter',
    'Mahasiswa',
    'Software Developer',
    'Atlet / Trainer',
    'Guru / Dosen',
    'Lainnya',
  ];

  final int age;
  final DateTime? birthDate;
  final String sex;
  final double weightKg;
  final double heightCm;
  final String activityLevel;
  final String goal;
  final String profession;

  UserProfile({
    required this.age,
    this.birthDate,
    required this.sex,
    required this.weightKg,
    required this.heightCm,
    required this.activityLevel,
    required this.goal,
    this.profession = 'Umum',
  });

  /// Dynamic age computed from [birthDate]. Falls back to [age] if [birthDate] is null.
  int get calculatedAge => AgeCalculator.calculateAge(birthDate) ?? age;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final rawBirthDate = json['birth_date'] as String?;
    final parsedBirthDate = AgeCalculator.parseIsoDate(rawBirthDate);
    final rawAge = (json['age'] as num?)?.toInt() ?? 25;
    final dynamicAge = AgeCalculator.calculateAge(parsedBirthDate) ?? rawAge;

    return UserProfile(
      age: dynamicAge,
      birthDate: parsedBirthDate,
      sex: json['sex'] as String? ?? 'male',
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 60.0,
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 165.0,
      activityLevel: json['activity_level'] as String? ?? 'moderate',
      goal: json['goal'] as String? ?? 'maintain_weight',
      profession: json['profession'] as String? ?? 'Umum',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': calculatedAge,
      'birth_date': birthDate != null
          ? AgeCalculator.formatIsoDate(birthDate!)
          : null,
      'sex': sex,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'activity_level': activityLevel,
      'goal': goal,
      'profession': profession,
    };
  }

  UserProfile copyWith({
    int? age,
    DateTime? birthDate,
    String? sex,
    double? weightKg,
    double? heightCm,
    String? activityLevel,
    String? goal,
    String? profession,
  }) {
    return UserProfile(
      age: age ?? this.age,
      birthDate: birthDate ?? this.birthDate,
      sex: sex ?? this.sex,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      profession: profession ?? this.profession,
    );
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

class DailyTarget {
  final int caloriesKcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double bmrKcal;
  final double tdeeKcal;

  DailyTarget({
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.bmrKcal,
    required this.tdeeKcal,
  });

  factory DailyTarget.fromJson(Map<String, dynamic> json) {
    final basis = json['basis'] as Map<String, dynamic>? ?? {};
    return DailyTarget(
      caloriesKcal: (json['calories_kcal'] as num).toInt(),
      proteinG: (json['protein_g'] as num).toDouble(),
      carbsG: (json['carbs_g'] as num).toDouble(),
      fatG: (json['fat_g'] as num).toDouble(),
      bmrKcal: (basis['bmr_kcal'] as num?)?.toDouble() ?? 0.0,
      tdeeKcal: (basis['tdee_kcal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
