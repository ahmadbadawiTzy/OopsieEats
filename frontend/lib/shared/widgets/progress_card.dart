import 'package:flutter/material.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/data/models/dashboard.dart';
import 'package:nutriview/shared/neo/neo_stat_card.dart';

/// Legacy-compatible ProgressCard upgraded with Neo-Brutalist presentation.
class ProgressCard extends StatelessWidget {
  final String title;
  final NutrientProgress progress;
  final String unit;
  final Color barColor;

  const ProgressCard({
    super.key,
    required this.title,
    required this.progress,
    required this.unit,
    this.barColor = AppTheme.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return NeoStatCard(
      title: title,
      progress: progress,
      unit: unit,
      barColor: barColor,
    );
  }
}
