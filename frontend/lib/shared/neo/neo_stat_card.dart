import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/data/models/dashboard.dart';
import 'package:nutriview/shared/neo/neo_badge.dart';
import 'package:nutriview/shared/neo/neo_card.dart';
import 'package:nutriview/shared/neo/neo_progress_bar.dart';
import 'package:nutriview/core/app_icons.dart';

/// Neo-Brutalist Nutrition Metric / Stat Card.
/// Displays nutrient intake with bold high-contrast hierarchy,
/// distinct accent colors, and tactile Neo-Brutalist card styling.
class NeoStatCard extends StatelessWidget {
  final String title;
  final NutrientProgress progress;
  final String unit;
  final Color barColor;
  final IconData? customIcon;

  const NeoStatCard({
    super.key,
    required this.title,
    required this.progress,
    required this.unit,
    this.barColor = NeoTokens.mintGreen,
    this.customIcon,
  });

  IconData _getIconForTitle(String t) {
    if (customIcon != null) return customIcon!;
    final lower = t.toLowerCase();
    if (lower.contains('kalori') || lower.contains('energi')) {
      return AppIcons.localFire;
    } else if (lower.contains('protein')) {
      return AppIcons.eggAlt;
    } else if (lower.contains('karbo')) {
      return AppIcons.grain;
    } else if (lower.contains('lemak')) {
      return AppIcons.waterDrop;
    }
    return AppIcons.pieChartOutline;
  }

  @override
  Widget build(BuildContext context) {
    final double visualFraction = progress.target > 0
        ? min(1.0, max(0.0, progress.consumed / progress.target))
        : 0.0;

    final isOver = progress.percentage > 100;
    final effectiveBarColor = isOver ? NeoTokens.coralRed : barColor;

    return NeoCard(
      margin: const EdgeInsets.symmetric(vertical: NeoTokens.space8),
      padding: const EdgeInsets.all(NeoTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: effectiveBarColor,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                  border: Border.all(
                    color: NeoTokens.black,
                    width: NeoTokens.borderWidthThin,
                  ),
                ),
                child: Icon(
                  _getIconForTitle(title),
                  size: AppIcons.sizeControl,
                  color: NeoTokens.black,
                ),
              ),
              const SizedBox(width: NeoTokens.space12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: NeoTokens.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              NeoBadge(
                label: '${progress.percentage.toStringAsFixed(1)}%',
                customBackgroundColor: isOver
                    ? NeoTokens.coralRed
                    : effectiveBarColor,
                customTextColor: isOver ? NeoTokens.white : NeoTokens.black,
                fontSize: 12,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ],
          ),
          const SizedBox(height: NeoTokens.space12),
          NeoProgressBar(
            value: visualFraction,
            fillColor: effectiveBarColor,
            height: 12,
          ),
          const SizedBox(height: NeoTokens.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terkonsumsi: ${progress.consumed.toStringAsFixed(1)} $unit',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: NeoTokens.textDark,
                ),
              ),
              Text(
                'Target: ${progress.target.toStringAsFixed(1)} $unit',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: NeoTokens.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
