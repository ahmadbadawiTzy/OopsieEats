import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oopsieeats/core/config.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/core/routes.dart';
import 'package:oopsieeats/features/scanner/providers/scan_flow_provider.dart';
import 'package:oopsieeats/shared/neo/neo_back_button.dart';
import 'package:oopsieeats/shared/neo/neo_badge.dart';
import 'package:oopsieeats/shared/neo/neo_button.dart';
import 'package:oopsieeats/shared/neo/neo_card.dart';
import 'package:oopsieeats/shared/neo/neo_section_header.dart';
import 'package:oopsieeats/core/app_icons.dart';

class MealResultScreen extends StatelessWidget {
  const MealResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<ScanFlowProvider>();
    final meal = flow.savedMealRecord;

    if (meal == null) {
      return Scaffold(
        backgroundColor: NeoTokens.warmBackground,
        appBar: AppBar(
          leading: NeoBackButton.leading(context),
          title: const Text('Hasil Analisis'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: Container(color: NeoTokens.black, height: 2),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(NeoTokens.space24),
            child: NeoCard(
              backgroundColor: NeoTokens.white,
              padding: const EdgeInsets.all(NeoTokens.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tidak ada catatan makan yang baru disimpan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: NeoTokens.textDark,
                    ),
                  ),
                  const SizedBox(height: NeoTokens.space20),
                  NeoButton(
                    text: 'Ke Dashboard',
                    variant: NeoButtonVariant.primary,
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.dashboard,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: NeoTokens.warmBackground,
      appBar: AppBar(
        title: const Text('Hasil Perhitungan Gizi'),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: NeoTokens.black, height: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: NeoTokens.space16,
          vertical: NeoTokens.space20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: NeoTokens.mintGreen,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                  border: Border.all(
                    color: NeoTokens.black,
                    width: NeoTokens.borderWidth,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: NeoTokens.black,
                      offset: NeoTokens.shadowOffset,
                      blurRadius: NeoTokens.shadowBlurRadius,
                    ),
                  ],
                ),
                child: const Icon(
                  AppIcons.checkCircle,
                  color: NeoTokens.black,
                  size: AppIcons.sizeBrand,
                ),
              ),
            ),
            const SizedBox(height: NeoTokens.space16),
            const Text(
              'Catatan Makan Tersimpan!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: NeoTokens.black,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: NeoTokens.space6),
            Center(
              child: NeoBadge(
                label: 'Waktu Makan: ${meal.mealTypeLabel}',
                color: NeoBadgeColor.yellow,
                hasShadow: true,
                fontSize: 12,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
              ),
            ),
            const SizedBox(height: NeoTokens.space20),

            // Summary Card
            NeoCard(
              backgroundColor: NeoTokens.mintGreen,
              padding: const EdgeInsets.all(NeoTokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Gizi Makanan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: NeoTokens.black,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: NeoTokens.space14),
                  Row(
                    children: [
                      Expanded(
                        child: _macroItem(
                          'Kalori',
                          '${meal.totals.caloriesKcal}',
                          'kkal',
                          NeoTokens.vividYellow,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _macroItem(
                          'Protein',
                          '${meal.totals.proteinG}',
                          'g',
                          NeoTokens.skyBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _macroItem(
                          'Karbo',
                          '${meal.totals.carbsG}',
                          'g',
                          NeoTokens.orangeCarb,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _macroItem(
                          'Lemak',
                          '${meal.totals.fatG}',
                          'g',
                          NeoTokens.lavender,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: NeoTokens.space20),

            NeoSectionHeader(
              title: 'Rincian Item Makanan (${meal.items.length})',
              accentColor: NeoTokens.vividYellow,
            ),
            const SizedBox(height: NeoTokens.space8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meal.items.length,
              itemBuilder: (context, index) {
                final mealItem = meal.items[index];
                return NeoCard(
                  margin: const EdgeInsets.symmetric(
                    vertical: NeoTokens.space4,
                  ),
                  padding: const EdgeInsets.all(NeoTokens.space14),
                  shadowOffset: NeoTokens.shadowOffsetSmall,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              mealItem.foodName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: NeoTokens.textDark,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          NeoBadge(
                            label: '${mealItem.portionGrams} g',
                            color: NeoBadgeColor.mint,
                            fontSize: 12,
                          ),
                        ],
                      ),
                      const SizedBox(height: NeoTokens.space8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${mealItem.caloriesKcal} kkal',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: NeoTokens.textDark,
                            ),
                          ),
                          Text(
                            'P: ${mealItem.proteinG}g • K: ${mealItem.carbsG}g • L: ${mealItem.fatG}g',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: NeoTokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: NeoTokens.space20),

            // Disclaimer
            NeoCard(
              backgroundColor: NeoTokens.surfaceMuted,
              shadowOffset: NeoTokens.shadowOffsetSmall,
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 12.0,
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    AppIcons.info,
                    size: AppIcons.sizeLarge,
                    color: NeoTokens.black,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppConfig.disclaimerText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: NeoTokens.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: NeoTokens.space24),

            NeoButton(
              text: 'Selesai & Ke Dashboard',
              prefixIcon: AppIcons.checkCircleOutline,
              variant: NeoButtonVariant.primary,
              onPressed: () {
                flow.reset();
                Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroItem(String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
        border: Border.all(
          color: NeoTokens.black,
          width: NeoTokens.borderWidthThin,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: NeoTokens.black,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: NeoTokens.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: NeoTokens.black,
            ),
          ),
        ],
      ),
    );
  }
}
