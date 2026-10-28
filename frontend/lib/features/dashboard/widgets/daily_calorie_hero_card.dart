import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/data/models/dashboard.dart';
import 'package:nutriview/shared/neo/neo_badge.dart';
import 'package:nutriview/shared/neo/neo_card.dart';
import 'package:nutriview/shared/neo/neo_progress_bar.dart';
import 'package:nutriview/core/app_icons.dart';

/// Overkill Neo-Brutalist Daily Calorie Centerpiece Card.
/// Displays Target, Consumed, and Remaining / Exceeded calories with
/// big statistics typography, high-contrast badges, and heavy visual progress bar.
class DailyCalorieHeroCard extends StatelessWidget {
  final NutrientProgress progress;
  final bool isProfileIncomplete;
  final VoidCallback onCompleteProfile;

  const DailyCalorieHeroCard({
    super.key,
    required this.progress,
    this.isProfileIncomplete = false,
    required this.onCompleteProfile,
  });

  @override
  Widget build(BuildContext context) {
    if (isProfileIncomplete || progress.target <= 0) {
      return NeoCard(
        backgroundColor: NeoTokens.hazard,
        padding: const EdgeInsets.all(NeoTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: NeoTokens.ink,
                    borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                  ),
                  child: const Icon(
                    AppIcons.warningAmber,
                    color: NeoTokens.hazard,
                    size: AppIcons.sizeControl,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'TARGET BELUM DIATUR',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: NeoTokens.ink,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: NeoTokens.space10),
            const Text(
              'Target kalori belum dapat dihitung secara akurat karena data fisik profil Anda belum lengkap. Lengkapi profil untuk mendapatkan rekomendasi gizi harian yang tepat.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: NeoTokens.ink,
                height: 1.4,
              ),
            ),
            const SizedBox(height: NeoTokens.space12),
            GestureDetector(
              onTap: onCompleteProfile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: NeoTokens.paper,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                  border: Border.all(
                    color: NeoTokens.ink,
                    width: NeoTokens.borderWidth,
                  ),
                  boxShadow: NeoTokens.neoBoxShadowSmall(),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.personAddAlt,
                      size: AppIcons.sizeLarge,
                      color: NeoTokens.ink,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'LENGKAPI PROFIL SEKARANG',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: NeoTokens.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final target = progress.target;
    final consumed = progress.consumed;
    final isOver = consumed > target;
    final remaining = max(0.0, target - consumed);
    final excess = max(0.0, consumed - target);
    final percentage = progress.percentage;

    // Status label and colors
    String statusLabel;
    Color statusBg;
    Color statusTextColor;
    if (consumed == 0) {
      statusLabel = 'BELUM MULAI';
      statusBg = NeoTokens.recess;
      statusTextColor = NeoTokens.ink;
    } else if (!isOver && percentage < 90) {
      statusLabel = 'SEDANG BERJALAN';
      statusBg = NeoTokens.lime;
      statusTextColor = NeoTokens.ink;
    } else if (!isOver && percentage >= 90) {
      statusLabel = 'TARGET TERCAPAI';
      statusBg = NeoTokens.lime;
      statusTextColor = NeoTokens.ink;
    } else {
      statusLabel = 'MELEBIHI TARGET';
      statusBg = NeoTokens.alert;
      statusTextColor = NeoTokens.paper;
    }

    final double visualFraction = target > 0
        ? min(1.0, consumed / target)
        : 0.0;

    return NeoCard(
      backgroundColor: NeoTokens.paper,
      borderWidth: NeoTokens.borderWidth,
      shadowOffset: NeoTokens.shadowOffsetMedium,
      padding: const EdgeInsets.all(NeoTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Index & Status Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    AppIcons.localFire,
                    color: NeoTokens.ink,
                    size: AppIcons.sizeControl,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '[01] KEBUTUHAN KALORI',
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
              NeoBadge(
                label: statusLabel,
                customBackgroundColor: statusBg,
                customTextColor: statusTextColor,
                fontSize: 10,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ],
          ),
          const SizedBox(height: NeoTokens.space16),

          // 3-Column Statistical Numbers
          Row(
            children: [
              // 1. Target Harian
              Expanded(
                child: _buildStatColumn(
                  label: 'TARGET HARIAN',
                  value: target.toStringAsFixed(0),
                  unit: 'kkal',
                  color: NeoTokens.ink,
                ),
              ),
              Container(
                width: 2,
                height: 48,
                color: NeoTokens.ink.withValues(alpha: 0.15),
              ),
              // 2. Sudah Masuk
              Expanded(
                child: _buildStatColumn(
                  label: 'SUDAH MASUK',
                  value: consumed.toStringAsFixed(0),
                  unit: 'kkal',
                  color: isOver ? NeoTokens.alert : NeoTokens.ink,
                ),
              ),
              Container(
                width: 2,
                height: 48,
                color: NeoTokens.ink.withValues(alpha: 0.15),
              ),
              // 3. Sisa / Kelebihan
              Expanded(
                child: _buildStatColumn(
                  label: isOver ? 'KELEBIHAN' : 'SISA TARGET',
                  value: isOver
                      ? '+${excess.toStringAsFixed(0)}'
                      : remaining.toStringAsFixed(0),
                  unit: 'kkal',
                  color: isOver ? NeoTokens.alert : NeoTokens.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: NeoTokens.space16),

          // Massive Brutalist Progress Bar
          NeoProgressBar(
            value: visualFraction,
            height: 18,
            fillColor: isOver ? NeoTokens.alert : NeoTokens.lime,
            backgroundColor: NeoTokens.recess,
            borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
          ),
          const SizedBox(height: NeoTokens.space10),

          // Progress Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOver
                    ? 'Konsumsi melampaui batas harian (+${excess.toStringAsFixed(0)} kkal)'
                    : 'Tersisa ${remaining.toStringAsFixed(0)} kkal untuk mencapai target',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isOver ? NeoTokens.alert : NeoTokens.inkSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isOver ? NeoTokens.alert : NeoTokens.lime,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                  border: Border.all(
                    color: NeoTokens.ink,
                    width: NeoTokens.borderWidthThin,
                  ),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    color: isOver ? NeoTokens.paper : NeoTokens.ink,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: NeoTokens.inkMuted,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: NeoTokens.inkSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
