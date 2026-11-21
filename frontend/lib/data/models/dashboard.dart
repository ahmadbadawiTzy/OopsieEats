import 'package:oopsieeats/core/nutrition_calculator.dart';
import 'package:oopsieeats/data/models/meal.dart';

class NutrientProgress {
  final double consumed;
  final double target;
  final double percentage;

  NutrientProgress({
    required this.consumed,
    required this.target,
    required this.percentage,
  });

  factory NutrientProgress.fromJson(Map<String, dynamic> json) {
    return NutrientProgress(
      consumed: (json['consumed'] as num).toDouble(),
      target: (json['target'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class DashboardProgress {
  final NutrientProgress calories;
  final NutrientProgress protein;
  final NutrientProgress carbs;
  final NutrientProgress fat;

  DashboardProgress({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory DashboardProgress.fromJson(Map<String, dynamic> json) {
    return DashboardProgress(
      calories: NutrientProgress.fromJson(
        json['calories_kcal'] as Map<String, dynamic>,
      ),
      protein: NutrientProgress.fromJson(
        json['protein_g'] as Map<String, dynamic>,
      ),
      carbs: NutrientProgress.fromJson(json['carbs_g'] as Map<String, dynamic>),
      fat: NutrientProgress.fromJson(json['fat_g'] as Map<String, dynamic>),
    );
  }
}

class DailyDashboard {
  final String date;
  final int mealCount;
  final MealNutritionTotals target;
  final MealNutritionTotals consumed;
  final DashboardProgress progress;

  DailyDashboard({
    required this.date,
    required this.mealCount,
    required this.target,
    required this.consumed,
    required this.progress,
  });

  DailyDashboard withUpdatedTarget(DailyTarget newTarget) {
    final targetTotals = MealNutritionTotals(
      caloriesKcal: NutritionCalculator.roundHalfUp(
        newTarget.caloriesKcal.toDouble(),
        1,
      ),
      proteinG: NutritionCalculator.roundHalfUp(newTarget.proteinG, 1),
      carbsG: NutritionCalculator.roundHalfUp(newTarget.carbsG, 1),
      fatG: NutritionCalculator.roundHalfUp(newTarget.fatG, 1),
    );

    double calcPct(double c, double t) {
      if (t <= 0) return 0.0;
      return NutritionCalculator.roundHalfUp((c / t) * 100.0, 2);
    }

    return DailyDashboard(
      date: date,
      mealCount: mealCount,
      target: targetTotals,
      consumed: consumed,
      progress: DashboardProgress(
        calories: NutrientProgress(
          consumed: consumed.caloriesKcal,
          target: targetTotals.caloriesKcal,
          percentage: calcPct(consumed.caloriesKcal, targetTotals.caloriesKcal),
        ),
        protein: NutrientProgress(
          consumed: consumed.proteinG,
          target: targetTotals.proteinG,
          percentage: calcPct(consumed.proteinG, targetTotals.proteinG),
        ),
        carbs: NutrientProgress(
          consumed: consumed.carbsG,
          target: targetTotals.carbsG,
          percentage: calcPct(consumed.carbsG, targetTotals.carbsG),
        ),
        fat: NutrientProgress(
          consumed: consumed.fatG,
          target: targetTotals.fatG,
          percentage: calcPct(consumed.fatG, targetTotals.fatG),
        ),
      ),
    );
  }

  factory DailyDashboard.fromJson(Map<String, dynamic> json) {
    return DailyDashboard(
      date: json['date'] as String,
      mealCount: json['meal_count'] as int,
      target: MealNutritionTotals.fromJson(
        json['target'] as Map<String, dynamic>,
      ),
      consumed: MealNutritionTotals.fromJson(
        json['consumed'] as Map<String, dynamic>,
      ),
      progress: DashboardProgress.fromJson(
        json['progress'] as Map<String, dynamic>,
      ),
    );
  }
}
