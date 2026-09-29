class MealNutritionTotals {
  final double caloriesKcal;
  final double proteinG;
  final double carbsG;
  final double fatG;

  MealNutritionTotals({
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  factory MealNutritionTotals.fromJson(Map<String, dynamic> json) {
    return MealNutritionTotals(
      caloriesKcal: (json['calories_kcal'] as num).toDouble(),
      proteinG: (json['protein_g'] as num).toDouble(),
      carbsG: (json['carbs_g'] as num).toDouble(),
      fatG: (json['fat_g'] as num).toDouble(),
    );
  }
}

class MealItem {
  final int id;
  final int foodId;
  final String foodName;
  final double portionGrams;
  final double caloriesKcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final String source;
  final double? detectionConfidence;

  MealItem({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.portionGrams,
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.source,
    this.detectionConfidence,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      id: json['id'] as int,
      foodId: json['food_id'] as int,
      foodName: json['food_name'] as String,
      portionGrams: (json['portion_grams'] as num).toDouble(),
      caloriesKcal: (json['calories_kcal'] as num).toDouble(),
      proteinG: (json['protein_g'] as num).toDouble(),
      carbsG: (json['carbs_g'] as num).toDouble(),
      fatG: (json['fat_g'] as num).toDouble(),
      source: json['source'] as String,
      detectionConfidence: json['detection_confidence'] != null
          ? (json['detection_confidence'] as num).toDouble()
          : null,
    );
  }
}

class MealRecord {
  final int id;
  final String mealType;
  final String consumedAt;
  final String consumedDate;
  final List<MealItem> items;
  final MealNutritionTotals totals;
  final String createdAt;

  MealRecord({
    required this.id,
    required this.mealType,
    required this.consumedAt,
    required this.consumedDate,
    required this.items,
    required this.totals,
    required this.createdAt,
  });

  factory MealRecord.fromJson(Map<String, dynamic> json) {
    return MealRecord(
      id: json['id'] as int,
      mealType: json['meal_type'] as String,
      consumedAt: json['consumed_at'] as String,
      consumedDate: json['consumed_date'] as String,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => MealItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
      totals: MealNutritionTotals.fromJson(json['totals'] as Map<String, dynamic>),
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  String get mealTypeLabel {
    switch (mealType) {
      case 'breakfast':
        return 'Sarapan';
      case 'lunch':
        return 'Makan Siang';
      case 'dinner':
        return 'Makan Malam';
      case 'snack':
        return 'Camilan';
      default:
        return mealType;
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
