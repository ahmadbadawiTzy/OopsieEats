import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/data/models/dashboard.dart';
import 'package:nutriview/shared/neo/neo_badge.dart';
import 'package:nutriview/shared/neo/neo_card.dart';
import 'package:nutriview/shared/neo/neo_progress_bar.dart';

/// Overkill Neo-Brutalist Bento Grid for Macronutrient Ratios and Daily Meal Tracking.
class MacroBentoGrid extends StatelessWidget {
  final DashboardProgress progress;
  final int mealCount;
  final VoidCallback onViewHistory;

  const MacroBentoGrid({
    super.key,
    required this.progress,
    required this.mealCount,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        const Row(
          children: [
            Icon(Icons.pie_chart_rounded, color: NeoTokens.ink, size: 18),
            SizedBox(width: 6),
            Text(
              '[03] RINGKASAN MAKRONUTRIEN',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: NeoTokens.ink,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: NeoTokens.space10),

        // Bento Row 1: Protein (Cobalt) & Karbohidrat (Tangerine)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MacroBentoCard(
                tag: '[PRO]',
                title: 'PROTEIN',
                accentColor: NeoTokens.cobalt,
                accentTextColor: NeoTokens.paper,
                progress: progress.protein,
                icon: Icons.fitness_center_rounded,
              ),
            ),
            const SizedBox(width: NeoTokens.space10),
            Expanded(
              child: _MacroBentoCard(
                tag: '[CHO]',
                title: 'KARBOHIDRAT',
                accentColor: NeoTokens.tangerine,
                accentTextColor: NeoTokens.ink,
                progress: progress.carbs,
                icon: Icons.grain_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: NeoTokens.space10),

        // Bento Row 2: Lemak (Lilac) & Daily Meal Logging Summary
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MacroBentoCard(
                tag: '[FAT]',
                title: 'LEMAK',
                accentColor: NeoTokens.lilac,
                accentTextColor: NeoTokens.ink,
                progress: progress.fat,
                icon: Icons.water_drop_rounded,
              ),
            ),
            const SizedBox(width: NeoTokens.space10),
            // Daily Meal Activity Bento Card
            Expanded(
              child: NeoCard(
                backgroundColor: NeoTokens.recess,
                borderWidth: NeoTokens.borderWidthThin,
                shadowOffset: NeoTokens.shadowOffsetSmall,
                padding: const EdgeInsets.all(NeoTokens.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: NeoTokens.hud,
                            borderRadius: BorderRadius.circular(
                              NeoTokens.radiusSmall,
                            ),
                          ),
                          child: const Text(
                            '[LOG]',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: NeoTokens.paper,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.fastfood_rounded,
                          size: 16,
                          color: NeoTokens.ink,
                        ),
                      ],
                    ),
                    const SizedBox(height: NeoTokens.space8),
                    const Text(
                      'LOG MAKAN HARI INI',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: NeoTokens.ink,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$mealCount KALI',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: NeoTokens.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onViewHistory,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: NeoTokens.paper,
                          borderRadius: BorderRadius.circular(
                            NeoTokens.radiusSmall,
                          ),
                          border: Border.all(
                            color: NeoTokens.ink,
                            width: NeoTokens.borderWidthThin,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'RIWAYAT',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: NeoTokens.ink,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 11,
                              color: NeoTokens.ink,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MacroBentoCard extends StatelessWidget {
  final String tag;
  final String title;
  final Color accentColor;
  final Color accentTextColor;
  final NutrientProgress progress;
  final IconData icon;

  const _MacroBentoCard({
    required this.tag,
    required this.title,
    required this.accentColor,
    required this.accentTextColor,
    required this.progress,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isOver = progress.percentage > 100;
    final double visualFraction = progress.target > 0
        ? min(1.0, max(0.0, progress.consumed / progress.target))
        : 0.0;

    return NeoCard(
      backgroundColor: NeoTokens.paper,
      borderWidth: NeoTokens.borderWidthThin,
      shadowOffset: NeoTokens.shadowOffsetSmall,
      padding: const EdgeInsets.all(NeoTokens.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag & Percentage Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                  border: Border.all(
                    color: NeoTokens.ink,
                    width: NeoTokens.borderWidthThin,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: accentTextColor,
                  ),
                ),
              ),
              NeoBadge(
                label: '${progress.percentage.toStringAsFixed(0)}%',
                customBackgroundColor: isOver
                    ? NeoTokens.alert
                    : NeoTokens.paper,
                customTextColor: isOver ? NeoTokens.paper : NeoTokens.ink,
                fontSize: 9.5,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              ),
            ],
          ),
          const SizedBox(height: NeoTokens.space8),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: NeoTokens.ink,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),

          // Values
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${progress.consumed.toStringAsFixed(1)}g',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: NeoTokens.ink,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/ ${progress.target.toStringAsFixed(0)}g',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: NeoTokens.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: NeoTokens.space8),

          // Mini Progress Bar
          NeoProgressBar(
            value: visualFraction,
            height: 8,
            fillColor: isOver ? NeoTokens.alert : accentColor,
            backgroundColor: NeoTokens.recess,
            borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
          ),
        ],
      ),
    );
  }
}
