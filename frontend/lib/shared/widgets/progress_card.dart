import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/data/models/dashboard.dart';

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

  IconData _getIconForTitle(String t) {
    final lower = t.toLowerCase();
    if (lower.contains('kalori') || lower.contains('energi')) {
      return Icons.local_fire_department_rounded;
    } else if (lower.contains('protein')) {
      return Icons.egg_alt_outlined;
    } else if (lower.contains('karbo')) {
      return Icons.grain_rounded;
    } else if (lower.contains('lemak')) {
      return Icons.water_drop_outlined;
    }
    return Icons.pie_chart_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    // UI limits progress bar visually between 0.0 and 1.0 (PRD §13.9)
    final double visualFraction = progress.target > 0
        ? min(1.0, max(0.0, progress.consumed / progress.target))
        : 0.0;

    final isOver = progress.percentage > 100;
    final effectiveColor = isOver ? AppTheme.accentOrange : barColor;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: effectiveColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconForTitle(title),
                    size: 18,
                    color: effectiveColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isOver ? AppTheme.accentOrangeLight : AppTheme.primaryGreenLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${progress.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isOver ? AppTheme.accentOrange : AppTheme.primaryGreenDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: visualFraction,
                minHeight: 8,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terkonsumsi: ${progress.consumed.toStringAsFixed(1)} $unit',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMuted,
                  ),
                ),
                Text(
                  'Target: ${progress.target.toStringAsFixed(1)} $unit',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
