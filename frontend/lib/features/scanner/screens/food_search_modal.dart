import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/data/models/food.dart';
import 'package:nutriview/data/repositories/food_repository.dart';
import 'package:nutriview/shared/neo/neo_badge.dart';
import 'package:nutriview/shared/neo/neo_card.dart';
import 'package:nutriview/shared/neo/neo_icon_button.dart';
import 'package:nutriview/shared/widgets/loading_indicator.dart';

class FoodSearchModal extends StatefulWidget {
  final FoodRepository foodRepository;

  const FoodSearchModal({super.key, required this.foodRepository});

  @override
  State<FoodSearchModal> createState() => _FoodSearchModalState();
}

class _FoodSearchModalState extends State<FoodSearchModal> {
  final _searchController = TextEditingController();
  List<FoodItem> _foods = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFoods();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchFoods([String? query]) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await widget.foodRepository.searchFoods(query: query);
      setState(() {
        _foods = items;
      });
    } catch (_) {
      setState(() {
        _error = 'Gagal memuat daftar makanan.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(
        horizontal: NeoTokens.space20,
        vertical: NeoTokens.space12,
      ),
      decoration: const BoxDecoration(
        color: NeoTokens.warmBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(NeoTokens.radiusLarge),
        ),
        border: Border(
          top: BorderSide(
            color: NeoTokens.black,
            width: NeoTokens.borderWidthThick,
          ),
          left: BorderSide(
            color: NeoTokens.black,
            width: NeoTokens.borderWidthThick,
          ),
          right: BorderSide(
            color: NeoTokens.black,
            width: NeoTokens.borderWidthThick,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: NeoTokens.space12),
              decoration: BoxDecoration(
                color: NeoTokens.black,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pilih Makanan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: NeoTokens.black,
                  letterSpacing: -0.4,
                ),
              ),
              NeoIconButton(
                icon: Icons.close_rounded,
                size: 34,
                iconSize: 18,
                shadowOffset: Offset.zero,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: NeoTokens.space12),

          // Neo Search Input
          Container(
            decoration: BoxDecoration(
              color: NeoTokens.white,
              borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
              border: Border.all(
                color: NeoTokens.black,
                width: NeoTokens.borderWidth,
              ),
              boxShadow: const [
                BoxShadow(
                  color: NeoTokens.black,
                  offset: NeoTokens.shadowOffsetSmall,
                  blurRadius: NeoTokens.shadowBlurRadius,
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: NeoTokens.textDark,
              ),
              decoration: InputDecoration(
                hintText: 'Cari makanan, e.g. nasi, ayam...',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: NeoTokens.textLight,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 22,
                  color: NeoTokens.black,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          size: 20,
                          color: NeoTokens.black,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _fetchFoods();
                        },
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
              onChanged: (val) {
                _fetchFoods(val);
              },
            ),
          ),
          const SizedBox(height: NeoTokens.space16),

          Expanded(
            child: _isLoading
                ? const LoadingIndicator(message: 'Mencari makanan...')
                : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: NeoTokens.coralRed,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : _foods.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.search_off_rounded,
                          size: 44,
                          color: NeoTokens.black,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tidak ada makanan yang cocok.',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: NeoTokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _foods.length,
                    itemBuilder: (context, index) {
                      final food = _foods[index];
                      return NeoCard(
                        margin: const EdgeInsets.symmetric(
                          vertical: NeoTokens.space4,
                        ),
                        padding: const EdgeInsets.all(NeoTokens.space12),
                        shadowOffset: NeoTokens.shadowOffsetSmall,
                        onTap: () => Navigator.pop(context, food),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    food.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: NeoTokens.textDark,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${food.caloriesPer100g} kkal • P: ${food.proteinPer100g}g • K: ${food.carbsPer100g}g • L: ${food.fatPer100g}g (per 100g)',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: NeoTokens.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const NeoBadge(
                              label: '+ Pilih',
                              color: NeoBadgeColor.mint,
                              fontSize: 11,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
