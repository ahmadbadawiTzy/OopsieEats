import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/data/models/meal.dart';
import 'package:nutriview/features/meals/providers/meal_history_provider.dart';
import 'package:nutriview/shared/neo/neo.dart';
import 'package:nutriview/shared/widgets/error_view.dart';
import 'package:nutriview/shared/widgets/loading_indicator.dart';
import 'package:nutriview/shared/widgets/neo_image_thumbnail.dart';

sealed class _HistoryListItem {}

class _DateHeaderItem extends _HistoryListItem {
  final String dateStr;
  final double totalCalories;
  final int count;

  _DateHeaderItem({
    required this.dateStr,
    required this.totalCalories,
    required this.count,
  });
}

class _MealCardItem extends _HistoryListItem {
  final MealRecord meal;

  _MealCardItem(this.meal);
}

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

  String _formatDateHeader(String yyyyMmDd) {
    try {
      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);
      final yesterdayStr = DateFormat(
        'yyyy-MM-dd',
      ).format(now.subtract(const Duration(days: 1)));

      if (yyyyMmDd == todayStr) {
        return 'HARI INI • ${DateFormat('d MMM yyyy', 'id_ID').format(now).toUpperCase()}';
      } else if (yyyyMmDd == yesterdayStr) {
        final yesterday = now.subtract(const Duration(days: 1));
        return 'KEMARIN • ${DateFormat('d MMM yyyy', 'id_ID').format(yesterday).toUpperCase()}';
      } else {
        final dt = DateTime.parse(yyyyMmDd);
        return DateFormat('EEEE, d MMM yyyy', 'id_ID').format(dt).toUpperCase();
      }
    } catch (_) {
      return yyyyMmDd;
    }
  }

  List<_HistoryListItem> _buildFlattenedItems(List<MealRecord> meals) {
    final Map<String, List<MealRecord>> grouped = {};
    for (final meal in meals) {
      grouped.putIfAbsent(meal.consumedDate, () => []).add(meal);
    }

    final List<_HistoryListItem> flattened = [];
    final sortedDateKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    for (final dateKey in sortedDateKeys) {
      final groupMeals = grouped[dateKey]!;
      final double dayCalories = groupMeals.fold(
        0.0,
        (sum, m) => sum + m.totals.caloriesKcal,
      );

      flattened.add(
        _DateHeaderItem(
          dateStr: dateKey,
          totalCalories: dayCalories,
          count: groupMeals.length,
        ),
      );

      for (final meal in groupMeals) {
        flattened.add(_MealCardItem(meal));
      }
    }

    return flattened;
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<MealHistoryProvider>();

    return Scaffold(
      backgroundColor: NeoTokens.canvas,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isTab,
        leading: widget.isTab ? null : NeoBackButton.leading(context),
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
                icon: AppIcons.clear,
                tooltip: 'Hapus Filter Tanggal',
                size: 40,
                iconSize: AppIcons.sizeControl,
                iconColor: NeoTokens.alert,
                shadowOffset: Offset.zero,
                onPressed: () => history.clearFilter(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: NeoIconButton(
              icon: AppIcons.calendarToday,
              tooltip: 'Filter Tanggal',
              size: 40,
              iconSize: AppIcons.sizeLarge,
              backgroundColor: history.filterDate != null
                  ? NeoTokens.hazard
                  : NeoTokens.paper,
              onPressed: _pickFilterDate,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (history.filterDate != null)
            _buildActiveFilterBanner(context, history),
          Expanded(child: _buildBodyContent(context, history)),
        ],
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

  Widget _buildActiveFilterBanner(
    BuildContext context,
    MealHistoryProvider history,
  ) {
    final formatted = DateFormat(
      'd MMMM yyyy',
      'id_ID',
    ).format(history.filterDate!);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NeoTokens.space16,
        vertical: NeoTokens.space8,
      ),
      decoration: const BoxDecoration(
        color: NeoTokens.hazard,
        border: Border(
          bottom: BorderSide(
            color: NeoTokens.ink,
            width: NeoTokens.borderWidthThin,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            AppIcons.calendarToday,
            size: AppIcons.sizeSmall,
            color: NeoTokens.ink,
          ),
          const SizedBox(width: NeoTokens.space8),
          Expanded(
            child: Text(
              'FILTER: $formatted'.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: NeoTokens.ink,
                letterSpacing: -0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: NeoTokens.space8),
          GestureDetector(
            onTap: () => history.clearFilter(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.clear,
                    size: AppIcons.sizeMicro,
                    color: NeoTokens.alert,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'RESET',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
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

  Widget _buildBodyContent(BuildContext context, MealHistoryProvider history) {
    if (history.isLoading) {
      return const LoadingIndicator(message: 'Memuat riwayat makan...');
    }

    if (history.errorMessage != null) {
      return ErrorView(
        message: history.errorMessage!,
        onRetry: () => history.loadMeals(date: history.filterDate),
      );
    }

    if (history.meals.isEmpty) {
      return Center(
        child: SingleChildScrollView(
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
                    borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                    border: Border.all(
                      color: NeoTokens.ink,
                      width: NeoTokens.borderWidth,
                    ),
                    boxShadow: NeoTokens.neoBoxShadowSmall(),
                  ),
                  child: const Icon(
                    AppIcons.noMeals,
                    size: AppIcons.sizeEmpty,
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
                      : 'Pindai makanan Anda untuk mulai memantau nutrisi harian.',
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
                  prefixIcon: AppIcons.cameraAlt,
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
      );
    }

    final items = _buildFlattenedItems(history.meals);

    return RefreshIndicator(
      color: NeoTokens.ink,
      backgroundColor: NeoTokens.lime,
      onRefresh: () => history.loadMeals(date: history.filterDate),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          NeoTokens.space16,
          NeoTokens.space8,
          NeoTokens.space16,
          100,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item is _DateHeaderItem) {
            return _buildDateGroupHeader(
              item.dateStr,
              item.totalCalories,
              item.count,
            );
          } else if (item is _MealCardItem) {
            return _buildMealCard(context, item.meal);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDateGroupHeader(
    String dateStr,
    double totalCalories,
    int count,
  ) {
    final headerTitle = _formatDateHeader(dateStr);
    return Padding(
      padding: const EdgeInsets.only(
        top: NeoTokens.space14,
        bottom: NeoTokens.space6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: NeoTokens.cobalt,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: NeoTokens.ink,
                      width: 1,
                    ),
                  ),
                ),
                const SizedBox(width: NeoTokens.space8),
                Expanded(
                  child: Text(
                    headerTitle,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: NeoTokens.ink,
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: NeoTokens.space8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: NeoTokens.lime,
              borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
              border: Border.all(
                color: NeoTokens.ink,
                width: NeoTokens.borderWidthThin,
              ),
              boxShadow: const [
                BoxShadow(
                  color: NeoTokens.ink,
                  offset: Offset(1.5, 1.5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(
              '${totalCalories.toStringAsFixed(0)} KKAL',
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
  }

  Widget _buildMealCard(BuildContext context, MealRecord meal) {
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(meal.consumedAt);
    } catch (_) {}

    final timeString = parsedDate != null
        ? DateFormat('HH:mm').format(parsedDate)
        : '';

    // Food names summary
    final String foodTitle;
    if (meal.items.isNotEmpty) {
      foodTitle = meal.items.map((e) => e.foodName).join(', ');
    } else {
      foodTitle = meal.mealTypeLabel;
    }

    // Semantic color for meal type
    final Color badgeBg;
    switch (meal.mealType.toLowerCase()) {
      case 'breakfast':
      case 'sarapan':
        badgeBg = NeoTokens.lime;
        break;
      case 'lunch':
      case 'makan siang':
        badgeBg = NeoTokens.hazard;
        break;
      case 'dinner':
      case 'makan malam':
        badgeBg = NeoTokens.lilac;
        break;
      case 'snack':
      case 'camilan':
      default:
        badgeBg = NeoTokens.cyan;
        break;
    }

    return NeoCard(
      margin: const EdgeInsets.symmetric(vertical: NeoTokens.space6),
      padding: const EdgeInsets.all(NeoTokens.space12),
      shadowOffset: NeoTokens.shadowOffsetSmall,
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.mealDetail,
          arguments: meal.id,
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Food Photo Thumbnail
          NeoImageThumbnail(
            imageMetadata: meal.image,
            size: 64,
            borderRadius: NeoTokens.radiusSmall,
          ),
          const SizedBox(width: NeoTokens.space12),
          // 2. Meal Content & Macros
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Meal Type Tag + Timestamp + Chevron
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(
                          NeoTokens.radiusSmall,
                        ),
                        border: Border.all(
                          color: NeoTokens.ink,
                          width: NeoTokens.borderWidthThin,
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
                    if (timeString.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        AppIcons.accessTime,
                        size: AppIcons.sizeMicro,
                        color: NeoTokens.inkSecondary,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          timeString,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: NeoTokens.inkSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                    const Spacer(),
                    const Icon(
                      AppIcons.chevronRight,
                      size: AppIcons.sizeMedium,
                      color: NeoTokens.ink,
                    ),
                  ],
                ),
                const SizedBox(height: NeoTokens.space6),
                // Food Dishes Title
                Text(
                  foodTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: NeoTokens.ink,
                    height: 1.25,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: NeoTokens.space8),
                // 4 Brutal Stat Pills
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    _buildStatPill(
                      label:
                          '${meal.totals.caloriesKcal.toStringAsFixed(0)} kkal',
                      color: NeoTokens.lime,
                    ),
                    _buildStatPill(
                      label: 'P: ${meal.totals.proteinG.toStringAsFixed(1)}g',
                      color: NeoTokens.cobalt,
                      textColor: NeoTokens.paper,
                    ),
                    _buildStatPill(
                      label: 'C: ${meal.totals.carbsG.toStringAsFixed(1)}g',
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required String label,
    required Color color,
    Color textColor = NeoTokens.ink,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
        border: Border.all(
          color: NeoTokens.ink,
          width: NeoTokens.borderWidthThin,
        ),
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
