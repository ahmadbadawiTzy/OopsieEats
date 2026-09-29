class FoodItem {
  final int id;
  final String name;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;

  FoodItem({
    required this.id,
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as int,
      name: json['name'] as String,
      caloriesPer100g: (json['calories_kcal_per_100g'] as num).toDouble(),
      proteinPer100g: (json['protein_g_per_100g'] as num).toDouble(),
      carbsPer100g: (json['carbs_g_per_100g'] as num).toDouble(),
      fatPer100g: (json['fat_g_per_100g'] as num).toDouble(),
    );
  }
}

class FoodDetail extends FoodItem {
  final String source;

  FoodDetail({
    required super.id,
    required super.name,
    required super.caloriesPer100g,
    required super.proteinPer100g,
    required super.carbsPer100g,
    required super.fatPer100g,
    required this.source,
  });

  factory FoodDetail.fromJson(Map<String, dynamic> json) {
    return FoodDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      caloriesPer100g: (json['calories_kcal_per_100g'] as num).toDouble(),
      proteinPer100g: (json['protein_g_per_100g'] as num).toDouble(),
      carbsPer100g: (json['carbs_g_per_100g'] as num).toDouble(),
      fatPer100g: (json['fat_g_per_100g'] as num).toDouble(),
      source: json['source'] as String? ?? 'TKPI',
    );
  }
}

class DetectionItem {
  final int foodId;
  final String foodName;
  final double confidence;
  final bool lowConfidence;

  DetectionItem({
    required this.foodId,
    required this.foodName,
    required this.confidence,
    required this.lowConfidence,
  });

  factory DetectionItem.fromJson(Map<String, dynamic> json) {
    return DetectionItem(
      foodId: json['food_id'] as int,
      foodName: json['food_name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      lowConfidence: json['low_confidence'] as bool? ?? false,
    );
  }
}
