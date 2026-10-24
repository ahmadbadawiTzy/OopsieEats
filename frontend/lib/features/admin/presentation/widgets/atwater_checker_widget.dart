import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';

class AtwaterCheckerWidget extends StatelessWidget {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const AtwaterCheckerWidget({
    super.key,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    final double calcCals = (4.0 * protein) + (4.0 * carbs) + (9.0 * fat);
    final double totalMacros = protein + carbs + fat;

    double deviationPercent = 0.0;
    if (calories > 0) {
      deviationPercent = ((calories - calcCals).abs() / calories) * 100.0;
    } else if (calcCals > 0) {
      deviationPercent = 100.0;
    }

    Color statusColor;
    String statusTitle;
    String statusDesc;
    IconData statusIcon;

    if (totalMacros > 100.0) {
      statusColor = NeoTokens.alert;
      statusTitle = 'TOTAL MAKRO MELEBIHI 100G';
      statusDesc =
          'Jumlah protein, karbohidrat, dan lemak (${totalMacros.toStringAsFixed(1)}g) tidak logis per 100g.';
      statusIcon = Icons.error_outline;
    } else if (calories <= 0 && calcCals <= 0) {
      statusColor = NeoTokens.inkSecondary;
      statusTitle = 'MENUNGGU INPUT NILAI GIZI';
      statusDesc = 'Masukkan angka kalori dan makronutrien per 100g.';
      statusIcon = Icons.info_outline;
    } else if (deviationPercent <= 15.0) {
      statusColor = NeoTokens.lime;
      statusTitle = 'AKURAT & KONSISTEN (≤ 15%)';
      statusDesc = 'Nilai kalori selaras dengan formula deterministik Atwater.';
      statusIcon = Icons.check_circle_outline;
    } else if (deviationPercent <= 30.0) {
      statusColor = NeoTokens.hazard;
      statusTitle = 'PERINGATAN DEVIASI (15% - 30%)';
      statusDesc = 'Deviasi wajar akibat kadar air, serat larut, atau abu. Pastikan sumber data benar.';
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusColor = NeoTokens.alert;
      statusTitle = 'KOREKSI MUTLAK (> 30%)';
      statusDesc = 'Kalori input berbeda drastis dari estimasi makro. Validasi akan menolak jika disimpan.';
      statusIcon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(NeoTokens.space12),
      decoration: BoxDecoration(
        color: NeoTokens.paper,
        borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
        border: Border.all(
          color: NeoTokens.ink,
          width: NeoTokens.borderWidth,
        ),
        boxShadow: NeoTokens.neoBoxShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(NeoTokens.space8),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                  border: Border.all(
                    color: NeoTokens.ink,
                    width: NeoTokens.borderWidthThin,
                  ),
                ),
                child: Icon(statusIcon, color: NeoTokens.ink, size: 20),
              ),
              const SizedBox(width: NeoTokens.space10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ATWATER ENERGY CHECKER',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: NeoTokens.inkSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusTitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: NeoTokens.ink,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: NeoTokens.space8),
          Text(
            statusDesc,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: NeoTokens.inkSecondary,
            ),
          ),
          const SizedBox(height: NeoTokens.space10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: NeoTokens.recess,
              borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
              border: Border.all(
                color: NeoTokens.ink,
                width: NeoTokens.borderWidthThin,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kalori Input',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${calories.toStringAsFixed(1)} kkal',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.compare_arrows, size: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kalkulasi Atwater (4P+4C+9F)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${calcCals.toStringAsFixed(1)} kkal',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Deviasi',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${deviationPercent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: deviationPercent > 30.0
                            ? NeoTokens.alert
                            : NeoTokens.ink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
