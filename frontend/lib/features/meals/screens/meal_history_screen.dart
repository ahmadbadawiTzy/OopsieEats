import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/features/meals/providers/meal_history_provider.dart';
import 'package:nutriview/shared/neo/neo.dart';
import 'package:nutriview/shared/widgets/error_view.dart';
import 'package:nutriview/shared/widgets/loading_indicator.dart';

class MealHistoryScreen extends StatefulWidget {
  final bool isTab;

  const MealHistoryScreen({super.key, this.isTab = false});

  @override
  State<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends State<MealHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealHistoryProvider>().loadMeals();
    });
  }

  Future<void> _pickFilterDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: context.read<MealHistoryProvider>().filterDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null && mounted) {
      context.read<MealHistoryProvider>().loadMeals(date: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<MealHistoryProvider>();

    return Scaffold(
      backgroundColor: NeoTokens.canvas,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isTab,
        elevation: 0,
        backgroundColor: NeoTokens.canvas,
        title: const Text(
          'RIWAYAT MAKAN',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(color: NeoTokens.ink, height: 1.5),
        ),
        actions: [
          if (history.filterDate != null)
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: NeoIconButton(
                icon: Icons.clear_rounded,
                tooltip: 'Hapus Filter Tanggal',
                size: 38,
                iconSize: 20,
                iconColor: NeoTokens.alert,
                shadowOffset: Offset.zero,
                onPressed: () => history.clearFilter(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: NeoIconButton(
              icon: Icons.calendar_today_rounded,
              tooltip: 'Filter Tanggal',
              size: 38,
              iconSize: 18,
              backgroundColor: history.filterDate != null
                  ? NeoTokens.hazard
                  : NeoTokens.paper,
              onPressed: _pickFilterDate,
            ),
          ),
        ],
      ),
      body: history.isLoading
          ? const LoadingIndicator(message: 'Memuat riwayat makan...')
          : history.errorMessage != null
          ? ErrorView(
              message: history.errorMessage!,
              onRetry: () => history.loadMeals(date: history.filterDate),
            )
          : history.meals.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(NeoTokens.space24),
                child: NeoCard(
                  backgroundColor: NeoTokens.paper,
                  padding: const EdgeInsets.all(NeoTokens.space24),
                  shadowOffset: NeoTokens.shadowOffsetMedium,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: NeoTokens.hazard,
                          borderRadius: BorderRadius.circular(
                            NeoTokens.radiusMedium,
                          ),
                          border: Border.all(
                            color: NeoTokens.ink,
                            width: NeoTokens.borderWidth,
                          ),
                          boxShadow: NeoTokens.neoBoxShadowSmall(),
                        ),
                        child: const Icon(
                          Icons.no_meals_rounded,
                          size: 34,
                          color: NeoTokens.ink,
                        ),
                      ),
                      const SizedBox(height: NeoTokens.space16),
                      const Text(
                        'BELUM ADA CATATAN MAKAN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: NeoTokens.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: NeoTokens.space8),
                      Text(
                        history.filterDate != null
                            ? 'Tidak ada catatan makan pada tanggal yang dipilih.'
                            : 'Pindai makanan Anda untuk mulai mencatat.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: NeoTokens.inkSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: NeoTokens.space20),
                      NeoButton(
                        text: 'SCAN SEKARANG',
                        prefixIcon: Icons.camera_alt_rounded,
                        variant: NeoButtonVariant.primary,
                        height: 48,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.scanner);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                NeoTokens.space16,
                NeoTokens.space12,
                NeoTokens.space16,
                100,
              ),
              itemCount: history.meals.length,
              itemBuilder: (context, index) {
                final meal = history.meals[index];
                DateTime? parsedDate;
                try {
                  parsedDate = DateTime.parse(meal.consumedAt);
                } catch (_) {}

                final timeDisplay = parsedDate != null
                    ? DateFormat(
                        'd MMM yyyy, HH:mm',
                        'id_ID',
                      ).format(parsedDate)
                    : meal.consumedDate;

                return NeoCard(
                  margin: const EdgeInsets.symmetric(
                    vertical: NeoTokens.space6,
                  ),
                  padding: const EdgeInsets.all(NeoTokens.space14),
                  shadowOffset: NeoTokens.shadowOffsetSmall,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.mealDetail,
                      arguments: meal.id,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: NeoTokens.lime,
                              borderRadius: BorderRadius.circular(
                                NeoTokens.radiusSmall,
                              ),
                              border: Border.all(
                                color: NeoTokens.ink,
                                width: 2.0,
                              ),
                            ),
                            child: Text(
                              meal.mealTypeLabel.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: NeoTokens.ink,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 13,
                                color: NeoTokens.ink,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                timeDisplay,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: NeoTokens.inkSecondary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: NeoTokens.ink,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: NeoTokens.space10),
                      // 4 Brutal Stat Pills
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildStatPill(
                            label:
                                '${meal.totals.caloriesKcal.toStringAsFixed(0)} KKAL',
                            color: NeoTokens.lime,
                          ),
                          _buildStatPill(
                            label:
                                'P: ${meal.totals.proteinG.toStringAsFixed(1)}g',
                            color: NeoTokens.cobalt,
                            textColor: NeoTokens.paper,
                          ),
                          _buildStatPill(
                            label:
                                'C: ${meal.totals.carbsG.toStringAsFixed(1)}g',
                            color: NeoTokens.tangerine,
                          ),
                          _buildStatPill(
                            label: 'F: ${meal.totals.fatG.toStringAsFixed(1)}g',
                            color: NeoTokens.lilac,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: widget.isTab
          ? null
          : NeoBottomNav(
              activeTab: NeoNavTab.history,
              onTabSelected: (tab) {
                if (tab == NeoNavTab.home) {
                  Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
                } else if (tab == NeoNavTab.article) {
                  Navigator.pushReplacementNamed(context, AppRoutes.articles);
                } else if (tab == NeoNavTab.profile) {
                  Navigator.pushReplacementNamed(context, AppRoutes.profile);
                }
              },
              onScanPressed: () {
                Navigator.pushNamed(context, AppRoutes.scanner);
              },
            ),
    );
  }

  Widget _buildStatPill({
    required String label,
    required Color color,
    Color textColor = NeoTokens.ink,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
        border: Border.all(color: NeoTokens.ink, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    );
  }
}
