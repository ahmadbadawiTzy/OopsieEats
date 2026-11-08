import 'package:flutter/material.dart';
import 'package:oopsieeats/core/app_icons.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/shared/neo/neo.dart';

class FoodDetailModal extends StatelessWidget {
  final Map<String, dynamic> food;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const FoodDetailModal({
    super.key,
    required this.food,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> food,
    required VoidCallback onEdit,
    required VoidCallback onToggleStatus,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FoodDetailModal(
        food: food,
        onEdit: onEdit,
        onToggleStatus: onToggleStatus,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nutrition = (food['nutrition'] as Map<String, dynamic>?) ?? {};
    final double cal =
        (nutrition['calories_kcal'] as num?)?.toDouble() ??
        (food['calories_kcal_per_100g'] as num?)?.toDouble() ??
        0.0;
    final double pro =
        (nutrition['protein_g'] as num?)?.toDouble() ??
        (food['protein_g_per_100g'] as num?)?.toDouble() ??
        0.0;
    final double carb =
        (nutrition['carbs_g'] as num?)?.toDouble() ??
        (food['carbs_g_per_100g'] as num?)?.toDouble() ??
        0.0;
    final double fat =
        (nutrition['fat_g'] as num?)?.toDouble() ??
        (food['fat_g_per_100g'] as num?)?.toDouble() ??
        0.0;

    final bool isActive = food['is_active'] == true;
    final String yoloClass = food['yolo_class'] as String? ?? '-';
    final String source =
        nutrition['source'] as String? ??
        food['source'] as String? ??
        'Kemenkes TKPI';

    final double calcAtwater = (4.0 * pro) + (4.0 * carb) + (9.0 * fat);
    final double deviation = cal > 0
        ? ((cal - calcAtwater).abs() / cal) * 100
        : 0.0;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: NeoTokens.warmBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: NeoTokens.ink, width: 3),
          left: BorderSide(color: NeoTokens.ink, width: 3),
          right: BorderSide(color: NeoTokens.ink, width: 3),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: NeoTokens.ink,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  (food['name'] as String? ?? 'Detail Pangan').toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: NeoTokens.ink,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(AppIcons.close, color: NeoTokens.ink),
                tooltip: 'Tutup',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(color: NeoTokens.ink, thickness: 2),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  // Status and YOLO Row
                  Row(
                    children: [
                      NeoBadge(
                        label: isActive ? 'STATUS: AKTIF' : 'STATUS: NONAKTIF',
                        color: isActive
                            ? NeoBadgeColor.mint
                            : NeoBadgeColor.coral,
                      ),
                      const SizedBox(width: 8),
                      if (yoloClass != '-')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                AppIcons.smartToy,
                                size: AppIcons.sizeSmall,
                                color: NeoTokens.ink,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'YOLO: $yoloClass',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Nutrition Bento Grid
                  const Text(
                    'KOMPOSISI MAKRONUTRIEN (PER 100G)',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: NeoTokens.inkSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMacroBox(
                          label: 'ENERGI',
                          value: '${cal.toStringAsFixed(1)} kkal',
                          color: NeoTokens.lime,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMacroBox(
                          label: 'PROTEIN',
                          value: '${pro.toStringAsFixed(1)} g',
                          color: const Color(0xFFBAE6FD),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMacroBox(
                          label: 'KARBOHIDRAT',
                          value: '${carb.toStringAsFixed(1)} g',
                          color: const Color(0xFFFED7AA),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMacroBox(
                          label: 'LEMAK',
                          value: '${fat.toStringAsFixed(1)} g',
                          color: const Color(0xFFE9D5FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Atwater Verification
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: NeoTokens.paper,
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
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              AppIcons.balance,
                              size: AppIcons.sizeMedium,
                              color: NeoTokens.ink,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'VERIFIKASI FISIKA GIZI ATWATER',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Estimasi Atwater: ${calcAtwater.toStringAsFixed(1)} kkal | Deviasi: ${deviation.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: deviation <= 15
                                ? NeoTokens.primaryGreen
                                : NeoTokens.coralRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Metadata Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: NeoTokens.recess,
                      borderRadius: BorderRadius.circular(
                        NeoTokens.radiusSmall,
                      ),
                      border: Border.all(
                        color: NeoTokens.inkSecondary,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMetaRow('ID Pangan', '${food['id']}'),
                        _buildMetaRow('Sumber Rujukan', source),
                        if (food['created_at'] != null)
                          _buildMetaRow('Dibuat Pada', '${food['created_at']}'),
                        if (food['updated_at'] != null)
                          _buildMetaRow('Diperbarui', '${food['updated_at']}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: NeoButton(
                          text: 'Edit Nutrisi',
                          prefixIcon: AppIcons.edit,
                          variant: NeoButtonVariant.primary,
                          onPressed: () {
                            Navigator.of(context).pop();
                            onEdit();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NeoButton(
                          text: isActive ? 'Nonaktifkan' : 'Aktifkan',
                          prefixIcon: isActive
                              ? AppIcons.visibilityOff
                              : AppIcons.visibility,
                          variant: NeoButtonVariant.secondary,
                          onPressed: () {
                            Navigator.of(context).pop();
                            onToggleStatus();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  NeoButton(
                    text: 'Hapus Makanan Permanen',
                    prefixIcon: AppIcons.deleteForever,
                    variant: NeoButtonVariant.danger,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete();
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
        border: Border.all(
          color: NeoTokens.ink,
          width: NeoTokens.borderWidthThin,
        ),
        boxShadow: const [
          BoxShadow(color: NeoTokens.ink, offset: Offset(2, 2), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: NeoTokens.ink,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: NeoTokens.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: NeoTokens.inkSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: NeoTokens.ink,
            ),
          ),
        ],
      ),
    );
  }
}
