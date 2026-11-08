import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oopsieeats/core/app_icons.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/data/models/dashboard.dart';
import 'package:oopsieeats/shared/neo/neo_badge.dart';
import 'package:oopsieeats/shared/neo/neo_card.dart';
import 'package:oopsieeats/shared/neo/neo_progress_bar.dart';

/// Customer-First Bento Grid for Macronutrient Balance and Daily Meal Log Count.
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
            Icon(
              AppIcons.pieChart,
              color: NeoTokens.ink,
              size: AppIcons.sizeLarge,
            ),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Keseimbangan Nutrisi',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: NeoTokens.ink,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        const Text(
          'Distribusi protein, karbohidrat, dan lemak harianmu.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: NeoTokens.inkSecondary,
          ),
        ),
        const SizedBox(height: NeoTokens.space10),

        // Bento Row 1: Protein (Cobalt) & Karbohidrat (Tangerine)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MacroBentoCard(
                tag: 'PROTEIN',
                title: 'Protein',
                accentColor: NeoTokens.cobalt,
                accentTextColor: NeoTokens.paper,
                progress: progress.protein,
                icon: AppIcons.fitnessCenter,
              ),
            ),
            const SizedBox(width: NeoTokens.space10),
            Expanded(
              child: _MacroBentoCard(
                tag: 'KARBO',
                title: 'Karbohidrat',
                accentColor: NeoTokens.tangerine,
                accentTextColor: NeoTokens.paper,
                progress: progress.carbs,
                icon: AppIcons.grain,
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
                tag: 'LEMAK',
                title: 'Lemak',
                accentColor: NeoTokens.lilac,
                accentTextColor: NeoTokens.ink,
                progress: progress.fat,
                icon: AppIcons.waterDrop,
              ),
            ),
            const SizedBox(width: NeoTokens.space10),

            // Daily Meal Activity Bento Card
            Expanded(
              child: NeoCard(
                backgroundColor: NeoTokens.paper,
                borderWidth: NeoTokens.borderWidthThin,
                shadowOffset: NeoTokens.shadowOffsetSmall,
                padding: const EdgeInsets.all(NeoTokens.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: NeoTokens.lime,
                              borderRadius: BorderRadius.circular(
                                NeoTokens.radiusSmall,
                              ),
                              border: Border.all(
                                color: NeoTokens.ink,
                                width: NeoTokens.borderWidthThin,
                              ),
                            ),
                            child: const Text(
                              'AKTIVITAS',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: NeoTokens.ink,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        const Icon(
                          AppIcons.fastfood,
                          size: AppIcons.sizeMedium,
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
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$mealCount KALI',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: NeoTokens.ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onViewHistory,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: NeoTokens.recess,
                          borderRadius: BorderRadius.circular(
                            NeoTokens.radiusSmall,
                          ),
                          border: Border.all(
                            color: NeoTokens.ink,
                            width: NeoTokens.borderWidthThin,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: NeoTokens.ink,
                              offset: Offset(1, 1),
                              blurRadius: NeoTokens.shadowBlurRadius,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'RIWAYAT',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: NeoTokens.ink,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              AppIcons.arrowForward,
                              size: AppIcons.sizeMicro,
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
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
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
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: accentTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              NeoBadge(
                label: '${progress.percentage.toStringAsFixed(0)}%',
                customBackgroundColor: isOver
                    ? NeoTokens.alert
                    : NeoTokens.paper,
                customTextColor: isOver ? NeoTokens.paper : NeoTokens.ink,
                fontSize: 10,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              ),
            ],
          ),
          const SizedBox(height: NeoTokens.space8),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: NeoTokens.ink,
              letterSpacing: -0.2,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 2),

          // Values
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
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
