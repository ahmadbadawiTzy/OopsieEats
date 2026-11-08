export 'package:oopsieeats/data/models/profile.dart' show DailyTarget;

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

class MealImageMetadata {
  final String provider;
  final String bucket;
  final String path;
  final String? mimeType;
  final int? sizeBytes;
  final int? width;
  final int? height;

  const MealImageMetadata({
    this.provider = 'supabase',
    this.bucket = 'food-history-images',
    required this.path,
    this.mimeType,
    this.sizeBytes,
    this.width,
    this.height,
  });

  factory MealImageMetadata.fromJson(Map<String, dynamic> json) {
    return MealImageMetadata(
      provider: json['provider'] as String? ?? 'supabase',
      bucket: json['bucket'] as String? ?? 'food-history-images',
      path: json['path'] as String? ?? '',
      mimeType: json['mime_type'] as String?,
      sizeBytes: (json['size_bytes'] as num?)?.toInt(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'bucket': bucket,
    'path': path,
    if (mimeType != null) 'mime_type': mimeType,
    if (sizeBytes != null) 'size_bytes': sizeBytes,
    if (width != null) 'width': width,
    if (height != null) 'height': height,
  };
}

class MealRecord {
  final int id;
  final String mealType;
  final String consumedAt;
  final String consumedDate;
  final List<MealItem> items;
  final MealNutritionTotals totals;
  final String createdAt;
  final MealImageMetadata? image;

  MealRecord({
    required this.id,
    required this.mealType,
    required this.consumedAt,
    required this.consumedDate,
    required this.items,
    required this.totals,
    required this.createdAt,
    this.image,
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
      totals: MealNutritionTotals.fromJson(
        json['totals'] as Map<String, dynamic>,
      ),
      createdAt: json['created_at'] as String? ?? '',
      image: json['image'] != null
          ? MealImageMetadata.fromJson(
              Map<String, dynamic>.from(json['image'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'meal_type': mealType,
    'consumed_at': consumedAt,
    'consumed_date': consumedDate,
    'items': items
        .map(
          (i) => {
            'id': i.id,
            'food_id': i.foodId,
            'food_name': i.foodName,
            'portion_grams': i.portionGrams,
            'calories_kcal': i.caloriesKcal,
            'protein_g': i.proteinG,
            'carbs_g': i.carbsG,
            'fat_g': i.fatG,
            'source': i.source,
            if (i.detectionConfidence != null)
              'detection_confidence': i.detectionConfidence,
          },
        )
        .toList(),
    'totals': {
      'calories_kcal': totals.caloriesKcal,
      'protein_g': totals.proteinG,
      'carbs_g': totals.carbsG,
      'fat_g': totals.fatG,
    },
    'created_at': createdAt,
    if (image != null) 'image': image!.toJson(),
  };

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
