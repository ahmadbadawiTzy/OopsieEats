import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/data/models/meal.dart';
import 'package:nutriview/shared/neo/neo_badge.dart';
import 'package:nutriview/shared/neo/neo_card.dart';

/// Customer-First Today's Intake Section for NutriView.
/// Displays today's meal records with loading skeleton, empty state, and error handling.
class TodaysIntakeSection extends StatelessWidget {
  final List<MealRecord> meals;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onScanPressed;
  final ValueChanged<int> onMealTapped;
  final VoidCallback onViewAllHistory;

  const TodaysIntakeSection({
    super.key,
    required this.meals,
    required this.isLoading,
    this.errorMessage,
    required this.onRetry,
    required this.onScanPressed,
    required this.onMealTapped,
    required this.onViewAllHistory,
  });

  String _formatMealTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return '';
    }
  }

  NeoBadgeColor _getMealTypeBadgeColor(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
      case 'sarapan':
        return NeoBadgeColor.yellow;
      case 'lunch':
      case 'makan_siang':
      case 'siang':
        return NeoBadgeColor.mint;
      case 'dinner':
      case 'makan_malam':
      case 'malam':
        return NeoBadgeColor.sky;
      default:
        return NeoBadgeColor.coral;
    }
  }

  String _translateMealType(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return 'SARAPAN';
      case 'lunch':
        return 'MAKAN SIANG';
      case 'dinner':
        return 'MAKAN MALAM';
      case 'snack':
        return 'SNACK';
      default:
        return type.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Row(
                children: [
                  Icon(
                    AppIcons.restaurant,
                    color: NeoTokens.ink,
                    size: AppIcons.sizeLarge,
                  ),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Makanan Hari Ini',
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
            ),
            if (meals.isNotEmpty) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onViewAllHistory,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: NeoTokens.paper,
                    borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                    border: Border.all(
                      color: NeoTokens.ink,
                      width: NeoTokens.borderWidthThin,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: NeoTokens.ink,
                        offset: Offset(1.5, 1.5),
                        blurRadius: NeoTokens.shadowBlurRadius,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
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
          ],
        ),
        const SizedBox(height: 2),
        const Text(
          'Yang sudah kamu konsumsi hari ini.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: NeoTokens.inkSecondary,
          ),
        ),
        const SizedBox(height: NeoTokens.space10),

        // States: Loading, Error, Empty, List
        if (isLoading) ...[
          _buildSkeletonCard(),
          const SizedBox(height: 8),
          _buildSkeletonCard(),
        ] else if (errorMessage != null) ...[
          NeoCard(
            backgroundColor: NeoTokens.recess,
            padding: const EdgeInsets.all(NeoTokens.space16),
            child: Column(
              children: [
                const Icon(
                  AppIcons.error,
                  color: NeoTokens.alert,
                  size: AppIcons.sizeState,
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: NeoTokens.ink,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
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
                    child: const Text(
                      'COBA LAGI',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: NeoTokens.ink,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (meals.isEmpty) ...[
          NeoCard(
            backgroundColor: NeoTokens.paper,
            padding: const EdgeInsets.all(NeoTokens.space20),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: NeoTokens.recess,
                    borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                    border: Border.all(
                      color: NeoTokens.ink,
                      width: NeoTokens.borderWidthThin,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      AppIcons.flatware,
                      color: NeoTokens.inkMuted,
                      size: AppIcons.sizeHeader,
                    ),
                  ),
                ),
                const SizedBox(height: NeoTokens.space12),
                const Text(
                  'BELUM ADA ASUPAN MAKAN',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: NeoTokens.ink,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Belum ada makanan yang dicatat untuk hari ini. Mulai pantau kalori harianmu sekarang.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: NeoTokens.inkSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: NeoTokens.space12),
                GestureDetector(
                  onTap: onScanPressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: NeoTokens.lime,
                      borderRadius: BorderRadius.circular(
                        NeoTokens.radiusSmall,
                      ),
                      border: Border.all(
                        color: NeoTokens.ink,
                        width: NeoTokens.borderWidth,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: NeoTokens.ink,
                          offset: NeoTokens.shadowOffsetSmall,
                          blurRadius: NeoTokens.shadowBlurRadius,
                        ),
                      ],
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.cameraAlt,
                            size: AppIcons.sizeMedium,
                            color: NeoTokens.ink,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'CATAT MAKANAN SEKARANG',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: NeoTokens.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // List of meals
          ...meals.map((meal) {
            final timeStr = _formatMealTime(meal.consumedAt);
            final itemsNames = meal.items.map((i) => i.foodName).join(', ');

            return NeoCard(
              margin: const EdgeInsets.only(bottom: NeoTokens.space8),
              padding: const EdgeInsets.all(NeoTokens.space12),
              onTap: () => onMealTapped(meal.id),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Meal Type & Time Indicator
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: NeoTokens.recess,
                      borderRadius: BorderRadius.circular(
                        NeoTokens.radiusSmall,
                      ),
                      border: Border.all(
                        color: NeoTokens.ink,
                        width: NeoTokens.borderWidthThin,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        AppIcons.lunchDining,
                        color: NeoTokens.ink,
                        size: AppIcons.sizeToolbar,
                      ),
                    ),
                  ),
                  const SizedBox(width: NeoTokens.space12),

                  // Meal Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            NeoBadge(
                              label: _translateMealType(meal.mealType),
                              color: _getMealTypeBadgeColor(meal.mealType),
                              fontSize: 9,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1.5,
                              ),
                            ),
                            if (timeStr.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                timeStr,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: NeoTokens.inkMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          itemsNames.isNotEmpty
                              ? itemsNames
                              : 'Catatan Makanan',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: NeoTokens.ink,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Calories Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
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
                      boxShadow: const [
                        BoxShadow(
                          color: NeoTokens.ink,
                          offset: Offset(1.5, 1.5),
                          blurRadius: NeoTokens.shadowBlurRadius,
                        ),
                      ],
                    ),
                    child: Text(
                      '+${meal.totals.caloriesKcal.toStringAsFixed(0)} kkal',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: NeoTokens.ink,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: NeoTokens.paper,
        borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
        border: Border.all(color: NeoTokens.ink, width: NeoTokens.borderWidth),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: NeoTokens.recess,
              borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 80, height: 12, color: NeoTokens.recess),
                const SizedBox(height: 6),
                Container(width: 150, height: 10, color: NeoTokens.recess),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
