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
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      caloriesPer100g:
          (json['calories_kcal_per_100g'] as num?)?.toDouble() ?? 0.0,
      proteinPer100g: (json['protein_g_per_100g'] as num?)?.toDouble() ?? 0.0,
      carbsPer100g: (json['carbs_g_per_100g'] as num?)?.toDouble() ?? 0.0,
      fatPer100g: (json['fat_g_per_100g'] as num?)?.toDouble() ?? 0.0,
    );
  }

  double get caloriesKcalPer100g => caloriesPer100g;
  double get proteinGPer100g => proteinPer100g;
  double get carbsGPer100g => carbsPer100g;
  double get fatGPer100g => fatPer100g;
  bool get hasNutritionData =>
      caloriesPer100g > 0 ||
      proteinPer100g > 0 ||
      carbsPer100g > 0 ||
      fatPer100g > 0;
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
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      caloriesPer100g:
          (json['calories_kcal_per_100g'] as num?)?.toDouble() ?? 0.0,
      proteinPer100g: (json['protein_g_per_100g'] as num?)?.toDouble() ?? 0.0,
      carbsPer100g: (json['carbs_g_per_100g'] as num?)?.toDouble() ?? 0.0,
      fatPer100g: (json['fat_g_per_100g'] as num?)?.toDouble() ?? 0.0,
      source: json['source'] as String? ?? 'TKPI',
    );
  }
}

class BoundingBox {
  final int x1;
  final int y1;
  final int x2;
  final int y2;

  const BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x1: (json['x1'] as num?)?.toInt() ?? 0,
      y1: (json['y1'] as num?)?.toInt() ?? 0,
      x2: (json['x2'] as num?)?.toInt() ?? 0,
      y2: (json['y2'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'x1': x1, 'y1': y1, 'x2': x2, 'y2': y2};
}

class DetectionItem {
  final int? foodId;
  final String? foodName;
  final String yoloClass;
  final double confidence;
  final bool lowConfidence;
  final int? classId;
  final String? className;
  final BoundingBox? boundingBox;
  final String status;
  final String? error;
  final double? caloriesPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatPer100g;
  final bool hasNutritionData;

  DetectionItem({
    this.foodId,
    this.foodName,
    required this.yoloClass,
    required this.confidence,
    this.lowConfidence = false,
    this.classId,
    this.className,
    this.boundingBox,
    this.status = 'mapped',
    this.error,
    this.caloriesPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatPer100g,
    this.hasNutritionData = false,
  });

  String get displayName => foodName ?? className ?? yoloClass;

  factory DetectionItem.fromJson(Map<String, dynamic> json) {
    final bboxJson = json['bounding_box'] ?? json['bbox'];
    return DetectionItem(
      foodId: json['food_id'] as int?,
      foodName: json['food_name'] as String?,
      yoloClass: (json['yolo_class'] ?? json['class_name'] ?? '') as String,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      lowConfidence: json['low_confidence'] as bool? ?? false,
      classId: json['class_id'] as int?,
      className: json['class_name'] as String?,
      boundingBox: bboxJson != null
          ? BoundingBox.fromJson(bboxJson as Map<String, dynamic>)
          : null,
      status: json['status'] as String? ?? 'mapped',
      error: json['error'] as String?,
      caloriesPer100g: (json['calories_kcal_per_100g'] as num?)?.toDouble(),
      proteinPer100g: (json['protein_g_per_100g'] as num?)?.toDouble(),
      carbsPer100g: (json['carbs_g_per_100g'] as num?)?.toDouble(),
      fatPer100g: (json['fat_g_per_100g'] as num?)?.toDouble(),
      hasNutritionData: json['has_nutrition_data'] as bool? ?? false,
    );
  }
}
