import 'package:flutter/material.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/data/models/food.dart';
import 'package:nutriview/data/repositories/food_repository.dart';
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
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pilih Makanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                  letterSpacing: -0.3,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 22),
                visualDensity: VisualDensity.compact,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textDark,
            ),
            decoration: InputDecoration(
              hintText: 'Cari makanan, e.g. nasi, ayam...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _fetchFoods();
                      },
                    )
                  : null,
            ),
            onChanged: (val) {
              _fetchFoods(val);
            },
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _isLoading
                ? const LoadingIndicator(message: 'Mencari makanan...')
                : _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppTheme.errorRed, fontSize: 13),
                        ),
                      )
                    : _foods.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off_rounded, size: 40, color: AppTheme.textLight),
                                SizedBox(height: 8),
                                Text(
                                  'Tidak ada makanan yang cocok.',
                                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _foods.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.borderSubtle),
                            itemBuilder: (context, index) {
                              final food = _foods[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                title: Text(
                                  food.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    '${food.caloriesPer100g} kkal • P: ${food.proteinPer100g}g • K: ${food.carbsPer100g}g • L: ${food.fatPer100g}g (per 100g)',
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                  ),
                                ),
                                trailing: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryGreen, size: 22),
                                onTap: () {
                                  Navigator.pop(context, food);
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
