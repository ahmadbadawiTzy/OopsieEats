import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/data/models/food.dart';
import 'package:nutriview/data/repositories/food_repository.dart';
import 'package:nutriview/features/scanner/providers/scan_flow_provider.dart';
import 'package:nutriview/features/scanner/screens/food_search_modal.dart';
import 'package:nutriview/shared/widgets/custom_button.dart';
import 'package:nutriview/shared/widgets/loading_indicator.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final flow = context.read<ScanFlowProvider>();
    final success = await flow.pickAndScanImage(source);
    if (success && context.mounted) {
      Navigator.pushNamed(context, AppRoutes.detectionConfirm);
    }
  }

  void _manualAdd(BuildContext context) async {
    final foodRepo = context.read<FoodRepository>();
    final FoodItem? selected = await showModalBottomSheet<FoodItem>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FoodSearchModal(foodRepository: foodRepo),
    );

    if (selected != null && context.mounted) {
      final flow = context.read<ScanFlowProvider>();
      flow.reset();
      flow.addManualItem(selected);
      Navigator.pushNamed(context, AppRoutes.detectionConfirm);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<ScanFlowProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Makanan'),
      ),
      body: SafeArea(
        child: flow.isProcessing
            ? const Center(
                child: LoadingIndicator(
                  message: 'Mendeteksi makanan dari foto...\nMohon tunggu sejenak.',
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryGreenLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 38,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Pindai Makanan Anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ambil foto piring makanan Anda atau pilih dari galeri. '
                      'Sistem akan mengenali jenis makanan secara otomatis untuk Anda konfirmasi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (flow.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRedLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppTheme.errorRed, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                flow.errorMessage!,
                                style: const TextStyle(color: AppTheme.errorRed, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    CustomButton(
                      text: 'Ambil Foto dari Kamera',
                      icon: Icons.camera_alt_rounded,
                      onPressed: () => _pickImage(context, ImageSource.camera),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Pilih dari Galeri',
                      icon: Icons.photo_library_outlined,
                      backgroundColor: Colors.white,
                      textColor: AppTheme.primaryGreen,
                      onPressed: () => _pickImage(context, ImageSource.gallery),
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'ATAU',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.search_rounded, color: AppTheme.primaryGreen, size: 20),
                      label: const Text(
                        'Pilih Makanan Manual',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                          letterSpacing: -0.2,
                        ),
                      ),
                      onPressed: () => _manualAdd(context),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreenLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFC8E6C9)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, color: AppTheme.primaryGreen, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tips: Pastikan pencahayaan cukup dan makanan terlihat jelas dari atas piring. '
                              'Model mendukung kelas makanan utama seperti nasi, ayam goreng, telur, tempe, sayur bening, dll.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryGreenDark,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
