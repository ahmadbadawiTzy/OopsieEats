import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/data/models/food.dart';
import 'package:nutriview/data/repositories/food_repository.dart';
import 'package:nutriview/features/scanner/providers/scan_flow_provider.dart';
import 'package:nutriview/features/scanner/screens/food_search_modal.dart';
import 'package:nutriview/shared/widgets/custom_button.dart';

class DetectionConfirmationScreen extends StatelessWidget {
  const DetectionConfirmationScreen({super.key});

  void _openManualAdd(BuildContext context) async {
    final foodRepo = context.read<FoodRepository>();
    final FoodItem? selected = await showModalBottomSheet<FoodItem>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FoodSearchModal(foodRepository: foodRepo),
    );

    if (selected != null && context.mounted) {
      context.read<ScanFlowProvider>().addManualItem(selected);
    }
  }

  void _openReplace(BuildContext context, int index) async {
    final foodRepo = context.read<FoodRepository>();
    final FoodItem? selected = await showModalBottomSheet<FoodItem>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FoodSearchModal(foodRepository: foodRepo),
    );

    if (selected != null && context.mounted) {
      context.read<ScanFlowProvider>().replaceItem(index, selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<ScanFlowProvider>();
    final items = flow.confirmedItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Makanan'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image preview if present
                  if (flow.imageFile != null) ...[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.file(
                        flow.imageFile!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Item Makanan (${items.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryGreen,
                        ),
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                        label: const Text(
                          'Tambah Manual',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        onPressed: () => _openManualAdd(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (items.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.search_off_rounded,
                                size: 30,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Tidak Ada Makanan Terdeteksi',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Foto mungkin kurang jelas atau makanan belum dikenali otomatis. Tambahkan item secara manual dari basis data kami.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 220,
                              child: CustomButton(
                                text: 'Pilih Makanan Manual',
                                icon: Icons.add_rounded,
                                onPressed: () => _openManualAdd(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreenLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.restaurant_rounded,
                                    color: AppTheme.primaryGreen,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.foodName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textDark,
                                          letterSpacing: -0.1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          if (item.source == 'detected' && item.detectionConfidence != null) ...[
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Deteksi ${(item.detectionConfidence! * 100).toInt()}%',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppTheme.textMuted,
                                                ),
                                              ),
                                            ),
                                            if (item.lowConfidence) ...[
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accentOrangeLight,
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(color: AppTheme.accentOrange),
                                                ),
                                                child: const Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.warning_amber_rounded,
                                                      size: 12,
                                                      color: AppTheme.accentOrange,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Perlu dicek',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w700,
                                                        color: AppTheme.accentOrange,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ] else if (item.source == 'corrected') ...[
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppTheme.accentBlueLight,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'Hasil Koreksi',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.accentBlue,
                                                ),
                                              ),
                                            ),
                                          ] else ...[
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'Manual',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppTheme.textMuted,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.textMuted),
                                  tooltip: 'Ganti makanan',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _openReplace(context, index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppTheme.errorRed),
                                  tooltip: 'Hapus makanan',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => flow.removeItem(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
            ),
            child: SafeArea(
              child: CustomButton(
                text: 'Lanjut ke Input Porsi',
                icon: Icons.arrow_forward_rounded,
                onPressed: items.isEmpty
                    ? null
                    : () {
                        Navigator.pushNamed(context, AppRoutes.portionInput);
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
