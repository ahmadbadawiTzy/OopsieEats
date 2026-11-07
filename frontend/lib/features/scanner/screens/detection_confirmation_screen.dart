import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/data/models/food.dart';
import 'package:nutriview/data/repositories/food_repository.dart';
import 'package:nutriview/features/scanner/providers/scan_flow_provider.dart';
import 'package:nutriview/features/scanner/screens/food_search_modal.dart';
import 'package:nutriview/shared/neo/neo_back_button.dart';
import 'package:nutriview/shared/neo/neo_badge.dart';
import 'package:nutriview/shared/neo/neo_button.dart';
import 'package:nutriview/shared/neo/neo_card.dart';
import 'package:nutriview/shared/neo/neo_icon_button.dart';
import 'package:nutriview/shared/neo/neo_section_header.dart';
import 'package:nutriview/core/app_icons.dart';

class DetectionConfirmationScreen extends StatelessWidget {
  const DetectionConfirmationScreen({super.key});

  void _openManualAdd(BuildContext context) async {
    final foodRepo = context.read<FoodRepository>();
    final FoodItem? selected = await showModalBottomSheet<FoodItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
      backgroundColor: Colors.transparent,
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
      backgroundColor: NeoTokens.warmBackground,
      appBar: AppBar(
        leading: NeoBackButton.leading(context),
        title: const Text('Konfirmasi Makanan'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: NeoTokens.black, height: 2),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: NeoTokens.space16,
                vertical: NeoTokens.space12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image preview with bounding box overlay if present
                  if (flow.imageFile != null || flow.imageBytes != null) ...[
                    NeoCard(
                      padding: EdgeInsets.zero,
                      backgroundColor: NeoTokens.black,
                      child: Stack(
                        children: [
                          Container(
                            height: 220,
                            width: double.infinity,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                NeoTokens.radiusMedium,
                              ),
                            ),
                            child: flow.imageBytes != null
                                ? Image.memory(
                                    flow.imageBytes!,
                                    height: 220,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                  )
                                : Image.file(
                                    flow.imageFile!,
                                    height: 220,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                          if (flow.rawDetections.isNotEmpty)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  NeoTokens.radiusMedium,
                                ),
                                child: CustomPaint(
                                  painter: BoundingBoxOverlayPainter(
                                    detections: flow.rawDetections,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: NeoTokens.space12),

                    // Detection count NeoCard
                    NeoCard(
                      backgroundColor: NeoTokens.mintGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shadowOffset: NeoTokens.shadowOffsetSmall,
                      child: Row(
                        children: [
                          const Icon(
                            AppIcons.autoAwesome,
                            size: AppIcons.sizeControl,
                            color: NeoTokens.black,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Ditemukan ${flow.rawDetections.isNotEmpty ? flow.rawDetections.length : items.length} makanan dari foto',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: NeoTokens.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: NeoTokens.space16),
                  ],

                  NeoSectionHeader(
                    title: 'Item Makanan (${items.length})',
                    accentColor: NeoTokens.vividYellow,
                    trailing: NeoBadge(
                      label: '+ Tambah Manual',
                      color: NeoBadgeColor.yellow,
                      hasShadow: true,
                      onTap: () => _openManualAdd(context),
                    ),
                  ),
                  const SizedBox(height: NeoTokens.space8),

                  if (items.isEmpty)
                    NeoCard(
                      backgroundColor: NeoTokens.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 40.0,
                        horizontal: 20.0,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: NeoTokens.surfaceMuted,
                              borderRadius: BorderRadius.circular(
                                NeoTokens.radiusMedium,
                              ),
                              border: Border.all(
                                color: NeoTokens.black,
                                width: NeoTokens.borderWidth,
                              ),
                            ),
                            child: const Icon(
                              AppIcons.searchOff,
                              size: AppIcons.sizeStateLarge,
                              color: NeoTokens.black,
                            ),
                          ),
                          const SizedBox(height: NeoTokens.space16),
                          const Text(
                            'Makanan Belum Teridentifikasi',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: NeoTokens.textDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: NeoTokens.space8),
                          const Text(
                            'Foto mungkin kurang jelas atau makanan belum dikenali otomatis. Tambahkan item secara manual dari basis data kami.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: NeoTokens.textMuted,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: NeoTokens.space20),
                          SizedBox(
                            width: 230,
                            child: NeoButton(
                              text: 'Pilih Makanan Manual',
                              prefixIcon: AppIcons.add,
                              variant: NeoButtonVariant.primary,
                              onPressed: () => _openManualAdd(context),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final detectedItem = items[index];
                        return NeoCard(
                          margin: const EdgeInsets.symmetric(
                            vertical: NeoTokens.space4,
                          ),
                          padding: const EdgeInsets.all(NeoTokens.space12),
                          shadowOffset: NeoTokens.shadowOffsetSmall,
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: NeoTokens.mintGreen,
                                  borderRadius: BorderRadius.circular(
                                    NeoTokens.radiusSmall,
                                  ),
                                  border: Border.all(
                                    color: NeoTokens.black,
                                    width: NeoTokens.borderWidthThin,
                                  ),
                                ),
                                child: const Icon(
                                  AppIcons.restaurant,
                                  color: NeoTokens.black,
                                  size: AppIcons.sizeToolbar,
                                ),
                              ),
                              const SizedBox(width: NeoTokens.space12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      detectedItem.foodName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: NeoTokens.textDark,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        if (detectedItem.source == 'detected' &&
                                            detectedItem.detectionConfidence !=
                                                null) ...[
                                          NeoBadge(
                                            label:
                                                'Deteksi ${(detectedItem.detectionConfidence! * 100).toInt()}%',
                                            color: NeoBadgeColor.white,
                                            fontSize: 11,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                          ),
                                          if (detectedItem.lowConfidence)
                                            const NeoBadge(
                                              label: 'Perlu dicek',
                                              icon: AppIcons.warningAmber,
                                              color: NeoBadgeColor.yellow,
                                              fontSize: 11,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                            ),
                                          if (detectedItem.isUnmapped)
                                            const NeoBadge(
                                              label: 'Belum Terdaftar',
                                              icon: AppIcons.helpOutline,
                                              color: NeoBadgeColor.coral,
                                              fontSize: 11,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                            ),
                                        ] else if (detectedItem.source ==
                                            'corrected') ...[
                                          const NeoBadge(
                                            label: 'Hasil Koreksi',
                                            color: NeoBadgeColor.sky,
                                            fontSize: 11,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                          ),
                                        ] else ...[
                                          const NeoBadge(
                                            label: 'Manual',
                                            color: NeoBadgeColor.white,
                                            fontSize: 11,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (detectedItem.hasNutritionData) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: NeoTokens.surfaceMuted,
                                          borderRadius: BorderRadius.circular(
                                            NeoTokens.radiusSmall,
                                          ),
                                          border: Border.all(
                                            color: NeoTokens.black,
                                            width: NeoTokens.borderWidthThin,
                                          ),
                                        ),
                                        child: Text(
                                          '${detectedItem.caloriesPer100g?.round() ?? 0} kkal · P: ${detectedItem.proteinPer100g?.toStringAsFixed(1) ?? "0"}g · K: ${detectedItem.carbsPer100g?.toStringAsFixed(1) ?? "0"}g · L: ${detectedItem.fatPer100g?.toStringAsFixed(1) ?? "0"}g / 100g',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: NeoTokens.textDark,
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: NeoTokens.coralRed.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            NeoTokens.radiusSmall,
                                          ),
                                          border: Border.all(
                                            color: NeoTokens.coralRed,
                                            width: NeoTokens.borderWidthThin,
                                          ),
                                        ),
                                        child: const Text(
                                          'Gizi belum tersedia · Ketuk ganti untuk memilih dari database',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: NeoTokens.coralRed,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              NeoIconButton(
                                icon: AppIcons.edit,
                                tooltip: 'Ganti makanan',
                                size: 36,
                                iconSize: AppIcons.sizeLarge,
                                shadowOffset: Offset.zero,
                                onPressed: () => _openReplace(context, index),
                              ),
                              const SizedBox(width: 6),
                              NeoIconButton(
                                icon: AppIcons.delete,
                                tooltip: 'Hapus makanan',
                                size: 36,
                                iconSize: AppIcons.sizeLarge,
                                iconColor: NeoTokens.coralRed,
                                shadowOffset: Offset.zero,
                                onPressed: () => flow.removeItem(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  if (items.isNotEmpty) ...[
                    const SizedBox(height: NeoTokens.space12),
                    NeoCard(
                      backgroundColor: NeoTokens.surfaceMuted,
                      padding: const EdgeInsets.all(NeoTokens.space12),
                      shadowOffset: NeoTokens.shadowOffsetSmall,
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            AppIcons.info,
                            size: AppIcons.sizeControl,
                            color: NeoTokens.black,
                          ),
                          SizedBox(width: NeoTokens.space12),
                          Expanded(
                            child: Text(
                              'Catatan: Pemindai mengenali jenis makanan dari foto. Porsi dan gramatur dapat disesuaikan pada langkah berikutnya agar perhitungan gizi lebih akurat.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: NeoTokens.textDark,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(NeoTokens.space16),
            decoration: const BoxDecoration(
              color: NeoTokens.warmBackground,
              border: Border(top: BorderSide(color: NeoTokens.black, width: 2)),
            ),
            child: SafeArea(
              child: NeoButton(
                text: 'Lanjut ke Input Porsi',
                suffixIcon: AppIcons.arrowForward,
                variant: NeoButtonVariant.primary,
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

class BoundingBoxOverlayPainter extends CustomPainter {
  final List<DetectionItem> detections;

  BoundingBoxOverlayPainter({required this.detections});

  @override
  void paint(Canvas canvas, Size size) {
    if (detections.isEmpty) return;

    int maxX = 0;
    int maxY = 0;
    for (final d in detections) {
      if (d.boundingBox != null) {
        if (d.boundingBox!.x2 > maxX) maxX = d.boundingBox!.x2;
        if (d.boundingBox!.y2 > maxY) maxY = d.boundingBox!.y2;
      }
    }

    final double refW = maxX > 0 ? maxX.toDouble() : 640.0;
    final double refH = maxY > 0 ? maxY.toDouble() : 640.0;
    final double scaleX = size.width / refW;
    final double scaleY = size.height / refH;

    final boxBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = NeoTokens.black;

    final boxFillPaint = Paint()..style = PaintingStyle.fill;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final colors = [
      NeoTokens.mintGreen,
      NeoTokens.vividYellow,
      NeoTokens.skyBlue,
      NeoTokens.lavender,
      NeoTokens.orangeCarb,
      NeoTokens.coralRed,
    ];

    for (int i = 0; i < detections.length; i++) {
      final det = detections[i];
      final box = det.boundingBox;
      if (box == null) continue;

      final color = colors[i % colors.length];
      boxFillPaint.color = color.withValues(alpha: 0.25);

      final rect = Rect.fromLTRB(
        (box.x1 * scaleX).clamp(0.0, size.width),
        (box.y1 * scaleY).clamp(0.0, size.height),
        (box.x2 * scaleX).clamp(0.0, size.width),
        (box.y2 * scaleY).clamp(0.0, size.height),
      );

      // Draw box with Neo styling
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect,
          const Radius.circular(NeoTokens.radiusSmall),
        ),
        boxFillPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect,
          const Radius.circular(NeoTokens.radiusSmall),
        ),
        boxBorderPaint,
      );

      // Label chip with black border
      final label = '${det.displayName} ${(det.confidence * 100).toInt()}%';
      final textSpan = TextSpan(
        text: label,
        style: const TextStyle(
          color: NeoTokens.black,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      );
      textPainter.text = textSpan;
      textPainter.layout();

      final labelBgRect = Rect.fromLTWH(
        rect.left,
        (rect.top - 22).clamp(0.0, size.height - 22),
        textPainter.width + 12,
        22,
      );

      final labelBgPaint = Paint()..color = color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelBgRect, const Radius.circular(4)),
        labelBgPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelBgRect, const Radius.circular(4)),
        boxBorderPaint,
      );
      textPainter.paint(
        canvas,
        Offset(labelBgRect.left + 6, labelBgRect.top + 3),
      );
    }
  }

  @override
  bool shouldRepaint(covariant BoundingBoxOverlayPainter oldDelegate) {
    return oldDelegate.detections != detections;
  }
}
