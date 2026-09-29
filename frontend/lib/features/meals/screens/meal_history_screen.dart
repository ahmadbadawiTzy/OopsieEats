import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/features/meals/providers/meal_history_provider.dart';
import 'package:nutriview/shared/widgets/error_view.dart';
import 'package:nutriview/shared/widgets/loading_indicator.dart';

class MealHistoryScreen extends StatefulWidget {
  const MealHistoryScreen({super.key});

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
      appBar: AppBar(
        title: const Text('Riwayat Makan'),
        actions: [
          if (history.filterDate != null)
            IconButton(
              icon: const Icon(Icons.clear_rounded, size: 22),
              tooltip: 'Hapus Filter Tanggal',
              onPressed: () => history.clearFilter(),
            ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, size: 20),
            tooltip: 'Filter Tanggal',
            onPressed: _pickFilterDate,
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
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.no_meals_rounded,
                                size: 32,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum Ada Catatan Makan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              history.filterDate != null
                                  ? 'Tidak ada catatan makan pada tanggal yang dipilih.'
                                  : 'Mulai scan atau catat makanan pertama Anda hari ini!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      itemCount: history.meals.length,
                      itemBuilder: (context, index) {
                        final meal = history.meals[index];
                        DateTime? parsedDate;
                        try {
                          parsedDate = DateTime.parse(meal.consumedAt);
                        } catch (_) {}

                        final timeDisplay = parsedDate != null
                            ? DateFormat('d MMM yyyy, HH:mm').format(parsedDate)
                            : meal.consumedDate;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.mealDetail,
                                arguments: meal.id,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryGreenLight,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          meal.mealTypeLabel,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.primaryGreenDark,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textLight),
                                          const SizedBox(width: 4),
                                          Text(
                                            timeDisplay,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '${meal.totals.caloriesKcal} kkal',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textDark,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Protein: ${meal.totals.proteinG}g • Karbo: ${meal.totals.carbsG}g • Lemak: ${meal.totals.fatG}g',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
