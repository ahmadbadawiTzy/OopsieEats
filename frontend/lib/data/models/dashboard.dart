import 'package:nutriview/data/models/meal.dart';

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
      calories: NutrientProgress.fromJson(json['calories_kcal'] as Map<String, dynamic>),
      protein: NutrientProgress.fromJson(json['protein_g'] as Map<String, dynamic>),
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

  factory DailyDashboard.fromJson(Map<String, dynamic> json) {
    return DailyDashboard(
      date: json['date'] as String,
      mealCount: json['meal_count'] as int,
      target: MealNutritionTotals.fromJson(json['target'] as Map<String, dynamic>),
      consumed: MealNutritionTotals.fromJson(json['consumed'] as Map<String, dynamic>),
      progress: DashboardProgress.fromJson(json['progress'] as Map<String, dynamic>),
    );
  }
}
