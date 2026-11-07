import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/data/models/meal.dart';
import 'package:nutriview/data/repositories/meal_repository.dart';
import 'package:nutriview/shared/neo/neo_back_button.dart';
import 'package:nutriview/shared/neo/neo_badge.dart';
import 'package:nutriview/shared/neo/neo_card.dart';
import 'package:nutriview/shared/neo/neo_section_header.dart';
import 'package:nutriview/shared/widgets/error_view.dart';
import 'package:nutriview/shared/widgets/loading_indicator.dart';
import 'package:nutriview/shared/widgets/neo_image_thumbnail.dart';

class MealDetailScreen extends StatefulWidget {
  final int mealId;

  const MealDetailScreen({super.key, required this.mealId});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  MealRecord? _meal;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = context.read<MealRepository>();
      final result = await repo.getMealDetail(widget.mealId);
      setState(() {
        _meal = result;
      });
    } catch (_) {
      setState(() {
        _error = 'Gagal memuat detail catatan makan.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTime(String isoString) {
    try {
      final parsedDateTime = DateTime.parse(isoString);
      return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(parsedDateTime);
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTokens.warmBackground,
      appBar: AppBar(
        leading: NeoBackButton.leading(context),
        title: const Text('Detail Catatan Makan'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: NeoTokens.black, height: 2),
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat detail...')
          : _error != null
          ? ErrorView(message: _error!, onRetry: _loadDetail)
          : _meal == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(NeoTokens.space24),
                child: NeoCard(
                  child: const Text(
                    'Data tidak ditemukan.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: NeoTokens.textDark,
                    ),
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: NeoTokens.space16,
                vertical: NeoTokens.space16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_meal!.image != null) ...[
                    NeoImageHeroCard(
                      imageMetadata: _meal!.image!,
                    ),
                    const SizedBox(height: NeoTokens.space16),
                  ],
                  NeoCard(
                    backgroundColor: NeoTokens.mintGreen,
                    padding: const EdgeInsets.all(NeoTokens.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            NeoBadge(
                              label: _meal!.mealTypeLabel,
                              color: NeoBadgeColor.yellow,
                              fontSize: 12,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                            ),
                            Text(
                              _formatTime(_meal!.consumedAt),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: NeoTokens.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: NeoTokens.space16),
                        Row(
                          children: [
                            Expanded(
                              child: _macroItem(
                                'Kalori',
                                '${_meal!.totals.caloriesKcal}',
                                'kkal',
                                NeoTokens.vividYellow,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _macroItem(
                                'Protein',
                                '${_meal!.totals.proteinG}',
                                'g',
                                NeoTokens.skyBlue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _macroItem(
                                'Karbo',
                                '${_meal!.totals.carbsG}',
                                'g',
                                NeoTokens.orangeCarb,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _macroItem(
                                'Lemak',
                                '${_meal!.totals.fatG}',
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
                    title: 'Item Makanan (${_meal!.items.length})',
                    accentColor: NeoTokens.vividYellow,
                  ),
                  const SizedBox(height: NeoTokens.space8),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _meal!.items.length,
                    itemBuilder: (context, index) {
                      final mealItem = _meal!.items[index];
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
                                      fontSize: 15,
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
