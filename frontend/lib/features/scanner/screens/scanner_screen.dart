import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/data/models/food.dart';
import 'package:nutriview/data/repositories/food_repository.dart';
import 'package:nutriview/features/scanner/providers/scan_flow_provider.dart';
import 'package:nutriview/features/scanner/screens/food_search_modal.dart';
import 'package:nutriview/shared/neo/neo.dart';

/// Clean, honest Neo-Brutalist Food Scanner & Intake Hub.
/// Replaces misleading fake optical viewfinder with clear, functional action paths:
/// 1. Native Camera Capture (launches device camera)
/// 2. Photo Gallery Selection (picks existing photo)
/// 3. Manual Food Database Search (direct TKPI search)
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
      backgroundColor: Colors.transparent,
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
      backgroundColor: NeoTokens.warmBackground,
      appBar: AppBar(
        backgroundColor: NeoTokens.warmBackground,
        foregroundColor: NeoTokens.ink,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: NeoIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Kembali',
            size: 38,
            iconSize: 20,
            shadowOffset: const Offset(2, 2),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        title: const Text(
          'Pindai Makanan',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
            color: NeoTokens.ink,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(color: NeoTokens.ink, height: 1.5),
        ),
      ),
      body: SafeArea(
        child: flow.isProcessing
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(NeoTokens.space24),
                  child: Container(
                    padding: const EdgeInsets.all(NeoTokens.space24),
                    decoration: BoxDecoration(
                      color: NeoTokens.lime,
                      borderRadius: BorderRadius.circular(
                        NeoTokens.radiusMedium,
                      ),
                      border: Border.all(
                        color: NeoTokens.ink,
                        width: NeoTokens.borderWidthThick,
                      ),
                      boxShadow: NeoTokens.neoBoxShadowLarge(),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              NeoTokens.ink,
                            ),
                          ),
                        ),
                        SizedBox(height: NeoTokens.space16),
                        Text(
                          'Menganalisis Makanan...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: NeoTokens.ink,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: NeoTokens.space8),
                        Text(
                          'Model AI sedang memindai foto di perangkat Anda secara aman & privat.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: NeoTokens.ink,
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: NeoTokens.space12),
                        Text(
                          'LOCAL ON-DEVICE INFERENCE · PRIVASI TERJAGA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: NeoTokens.hud,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
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
                    // Error message notification
                    if (flow.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(NeoTokens.space12),
                        decoration: BoxDecoration(
                          color: NeoTokens.alert,
                          borderRadius: BorderRadius.circular(
                            NeoTokens.radiusMedium,
                          ),
                          border: Border.all(
                            color: NeoTokens.ink,
                            width: NeoTokens.borderWidth,
                          ),
                          boxShadow: NeoTokens.neoBoxShadowSmall(),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: NeoTokens.paper,
                              size: 22,
                            ),
                            const SizedBox(width: NeoTokens.space10),
                            Expanded(
                              child: Text(
                                flow.errorMessage!,
                                style: const TextStyle(
                                  color: NeoTokens.paper,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: NeoTokens.space16),
                    ],

                    // Screen Intro / Hero Header
                    Container(
                      padding: const EdgeInsets.all(NeoTokens.space16),
                      decoration: BoxDecoration(
                        color: NeoTokens.paper,
                        borderRadius: BorderRadius.circular(
                          NeoTokens.radiusMedium,
                        ),
                        border: Border.all(
                          color: NeoTokens.ink,
                          width: NeoTokens.borderWidth,
                        ),
                        boxShadow: NeoTokens.neoBoxShadowSmall(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: NeoTokens.hud,
                                  borderRadius: BorderRadius.circular(
                                    NeoTokens.radiusSmall,
                                  ),
                                  border: Border.all(
                                    color: NeoTokens.ink,
                                    width: NeoTokens.borderWidthThin,
                                  ),
                                ),
                                child: const Text(
                                  'PILIH CARA PENCATATAN',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: NeoTokens.paper,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
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
                                    width: NeoTokens.borderWidthThin,
                                  ),
                                ),
                                child: const Text(
                                  'AI + TKPI',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: NeoTokens.ink,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: NeoTokens.space10),
                          const Text(
                            'Catat Makananmu Sekarang',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              letterSpacing: -0.6,
                              color: NeoTokens.ink,
                            ),
                          ),
                          const SizedBox(height: NeoTokens.space4),
                          const Text(
                            'Pilih salah satu cara berikut untuk mengenali makanan atau memasukkan menu ke riwayat gizi harianmu.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: NeoTokens.inkSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: NeoTokens.space16),

                    // Option 1: Native Camera
                    _ScanActionCard(
                      badge: 'REKOMENDASI',
                      badgeColor: NeoTokens.lime,
                      icon: Icons.camera_alt_rounded,
                      iconBg: NeoTokens.lime,
                      title: 'Potret dengan Kamera',
                      description:
                          'Buka kamera ponsel untuk memotret makanan di depanmu. Model AI akan mendeteksi makanan secara otomatis.',
                      buttonText: 'Buka Kamera Ponsel',
                      buttonVariant: NeoButtonVariant.primary,
                      onPressed: () => _pickImage(context, ImageSource.camera),
                    ),
                    const SizedBox(height: NeoTokens.space14),

                    // Option 2: Gallery
                    _ScanActionCard(
                      badge: 'DARI GALERI',
                      badgeColor: NeoTokens.cyan,
                      icon: Icons.photo_library_rounded,
                      iconBg: NeoTokens.cyan,
                      title: 'Pilih dari Galeri Foto',
                      description:
                          'Gunakan foto makanan yang sudah tersimpan di album ponsel Anda untuk dipindai oleh AI.',
                      buttonText: 'Pilih Foto dari Galeri',
                      buttonVariant: NeoButtonVariant.secondary,
                      onPressed: () => _pickImage(context, ImageSource.gallery),
                    ),
                    const SizedBox(height: NeoTokens.space14),

                    // Option 3: Manual TKPI Search
                    _ScanActionCard(
                      badge: 'TANPA FOTO',
                      badgeColor: NeoTokens.hazard,
                      icon: Icons.search_rounded,
                      iconBg: NeoTokens.hazard,
                      title: 'Cari Manual di Database',
                      description:
                          'Ketik nama makanan atau minuman untuk memilih langsung dari ribuan database gizi resmi TKPI.',
                      buttonText: 'Cari Menu Makanan',
                      buttonVariant: NeoButtonVariant.hazard,
                      onPressed: () => _manualAdd(context),
                    ),
                    const SizedBox(height: NeoTokens.space20),

                    // Practical Tips NeoCard
                    NeoCard(
                      backgroundColor: NeoTokens.paper,
                      padding: const EdgeInsets.all(NeoTokens.space16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                size: 20,
                                color: NeoTokens.ink,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'TIPS HASIL DETEKSI MAKSIMAL',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: NeoTokens.ink,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: NeoTokens.space10),
                          _buildTipItem(
                            number: '1',
                            text:
                                'Posisikan piring terlihat utuh dari sudut 45 derajat atau dari atas.',
                          ),
                          const SizedBox(height: 8),
                          _buildTipItem(
                            number: '2',
                            text:
                                'Pastikan pencahayaan terang agar warna dan tekstur makanan jelas.',
                          ),
                          const SizedBox(height: 8),
                          _buildTipItem(
                            number: '3',
                            text:
                                'Foto diproses langsung di ponsel Anda. Data makanan tetap privat.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: NeoTokens.space24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTipItem({required String number, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: NeoTokens.ink,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: NeoTokens.paper,
              fontWeight: FontWeight.w900,
              fontSize: 10.5,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: NeoTokens.inkSecondary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable Neo-Brutalist Action Card for scanner options.
class _ScanActionCard extends StatelessWidget {
  final String badge;
  final Color badgeColor;
  final IconData icon;
  final Color iconBg;
  final String title;
  final String description;
  final String buttonText;
  final NeoButtonVariant buttonVariant;
  final VoidCallback onPressed;

  const _ScanActionCard({
    required this.badge,
    required this.badgeColor,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.buttonVariant,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      backgroundColor: NeoTokens.paper,
      padding: const EdgeInsets.all(NeoTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                  border: Border.all(
                    color: NeoTokens.ink,
                    width: NeoTokens.borderWidth,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: NeoTokens.ink,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Icon(icon, color: NeoTokens.ink, size: 24),
              ),
              const SizedBox(width: NeoTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(
                          NeoTokens.radiusSmall,
                        ),
                        border: Border.all(
                          color: NeoTokens.ink,
                          width: NeoTokens.borderWidthThin,
                        ),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: NeoTokens.ink,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: -0.4,
                        color: NeoTokens.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: NeoTokens.space10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: NeoTokens.inkSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: NeoTokens.space12),
          NeoButton(
            text: buttonText,
            height: 46,
            variant: buttonVariant,
            prefixIcon: icon,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
