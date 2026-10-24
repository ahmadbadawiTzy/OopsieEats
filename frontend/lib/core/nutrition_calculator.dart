import 'package:nutriview/data/models/profile.dart';

class NutritionCalculator {
  static const Map<String, double> activityFactors = {
    'sedentary': 1.2,
    'light': 1.375,
    'moderate': 1.55,
    'active': 1.725,
    'very_active': 1.9,
  };

  static const Map<String, double> proteinPerKg = {
    'lose_weight': 1.6,
    'maintain_weight': 1.2,
    'gain_weight': 1.6,
  };

  static const Map<String, double> goalCalorieDelta = {
    'lose_weight': -500.0,
    'maintain_weight': 0.0,
    'gain_weight': 300.0,
  };

  static const Map<String, double> minCalories = {
    'male': 1500.0,
    'female': 1200.0,
  };

  static double roundHalfUp(double value, int places) {
    final factor = places == 0 ? 1.0 : (places == 1 ? 10.0 : 100.0);
    return ((value * factor) + 0.00000001).round() / factor;
  }

  static DailyTarget calculateDailyTarget({
    required int age,
    required String sex,
    required double weightKg,
    required double heightCm,
    required String activityLevel,
    required String goal,
  }) {
    // Step 1: BMR (Mifflin-St Jeor formula)
    // male:   BMR = 10 * berat_kg + 6.25 * tinggi_cm - 5 * usia + 5
    // female: BMR = 10 * berat_kg + 6.25 * tinggi_cm - 5 * usia - 161
    final double bmr;
    if (sex.toLowerCase() == 'male') {
      bmr = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * age) + 5.0;
    } else {
      bmr = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * age) - 161.0;
    }

    // Step 2: TDEE = BMR * activity_factor
    final factor = activityFactors[activityLevel.toLowerCase()] ?? 1.2;
    final tdee = bmr * factor;

    // Step 3: Target Calories = TDEE + delta, subject to lower bounds
    final delta = goalCalorieDelta[goal.toLowerCase()] ?? 0.0;
    double calorieTarget = tdee + delta;
    final minCal = minCalories[sex.toLowerCase()] ?? 1200.0;
    if (calorieTarget < minCal) {
      calorieTarget = minCal;
    }

    // Step 4: Macronutrients
    // protein_g = protein_per_kg * berat_kg
    // fat_g     = 0.25 * kalori_target / 9
    // carbs_g   = (kalori_target - protein_g * 4 - fat_g * 9) / 4 (min 0)
    final proteinRate = proteinPerKg[goal.toLowerCase()] ?? 1.2;
    final protein = proteinRate * weightKg;
    final fat = (0.25 * calorieTarget) / 9.0;
    double carbs = (calorieTarget - (protein * 4.0) - (fat * 9.0)) / 4.0;
    if (carbs < 0.0) {
      carbs = 0.0;
    }

    return DailyTarget(
      caloriesKcal: roundHalfUp(calorieTarget, 0).toInt(),
      proteinG: roundHalfUp(protein, 1),
      carbsG: roundHalfUp(carbs, 1),
      fatG: roundHalfUp(fat, 1),
      bmrKcal: roundHalfUp(bmr, 1),
      tdeeKcal: roundHalfUp(tdee, 1),
    );
  }

  static Map<String, double> calculatePortionNutrition({
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
    required double portionGrams,
  }) {
    final factor = portionGrams / 100.0;
    return {
      'calories_kcal': roundHalfUp(caloriesPer100g * factor, 2),
      'protein_g': roundHalfUp(proteinPer100g * factor, 2),
      'carbs_g': roundHalfUp(carbsPer100g * factor, 2),
      'fat_g': roundHalfUp(fatPer100g * factor, 2),
    };
  }

  static void validateAtwater({
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  }) {
    final totalMacros = protein + carbs + fat;
    if (totalMacros > 100.0) {
      throw ArgumentError(
        'Total makronutrien (${totalMacros.toStringAsFixed(1)}g) tidak boleh melebihi 100 gram.',
      );
    }

    final theoreticalCals = (4.0 * protein) + (4.0 * carbs) + (9.0 * fat);
    if (calories > 0) {
      final diff = (calories - theoreticalCals).abs();
      final ratio = diff / (calories > 1.0 ? calories : 1.0);
      if (ratio > 0.30) {
        throw ArgumentError(
          'Inkonsistensi energi Atwater: Kalori input (${calories.toStringAsFixed(1)} kkal) '
          'berbeda lebih dari 30% dibanding estimasi makronutrien (${theoreticalCals.toStringAsFixed(1)} kkal).',
        );
      }
    }
  }
}
