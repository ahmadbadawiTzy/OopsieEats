import 'package:flutter/material.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/features/onboarding/models/onboarding_tokens.dart';
import 'package:oopsieeats/features/onboarding/widgets/nutrition_callout_card.dart';
import 'package:oopsieeats/features/onboarding/widgets/torn_paper_card.dart';

/// Slide 2: Nutrition Awareness ("Setiap Gigitan Punya Arti!")
/// Neo-Brutalism Overkill — Green, Mint, Yellow, Orange, SkyBlue & Lavender Specimen Board:
/// - Vivid Yellow (`NeoTokens.vividYellow`) stage with architectural blueprint grid
/// - Concentric Primary Green (`NeoTokens.primaryGreen`) + Mint Green (`NeoTokens.mintGreen`) target halo
/// - Lavender (`NeoTokens.lavender`) geometric triangle + White circle accent
/// - 4 Specimen `NutritionCalloutCard`s (`KARBOHIDRAT` in `orangeCarb`, `PROTEIN` in `primaryGreen`, `VITAMIN` in `skyBlue`, `ENERGI` in `lavender`)
/// - High-res die-cut portrait sticker (`onboarding_2_sticker.png`) with strict Face Safe Zone `[0.27w..0.72w] × [0.20h..0.50h]`
class SlideNutritionAwareness extends StatelessWidget {
  const SlideNutritionAwareness({super.key});

  @override
  Widget build(BuildContext context) {
    final disableAnimations = NeoMotion.isAnimationDisabled(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight;
        final double artHeight = h * 0.65;
        final double cardHeight = h * 0.38;

        final double calloutWidth = (w * 0.255).clamp(84.0, 110.0);

        return Container(
          color: NeoTokens.vividYellow,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // 1. Top Visual Stage
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: artHeight,
                child: ClipRect(
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      // Architectural Blueprint Grid Pattern
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _SquareGridPainter(
                            lineColor: NeoTokens.black.withValues(alpha: 0.14),
                            gridSize: 28.0,
                          ),
                        ),
                      ),

                      // Left Lavender Triangle Shape
                      Positioned(
                        left: -14,
                        top: artHeight * 0.40,
                        width: 96,
                        height: 112,
                        child: CustomPaint(
                          painter: _TrianglePainter(
                            fillColor: NeoTokens.lavender,
                            borderColor: NeoTokens.black,
                            borderWidth: OnboardingTokens.borderWidthThick,
                          ),
                        ),
                      ),

                      // Bottom-Right White Circle Shape
                      Positioned(
                        right: -36,
                        bottom: 18,
                        width: 146,
                        height: 146,
                        child: Container(
                          decoration: BoxDecoration(
                            color: NeoTokens.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: NeoTokens.black,
                              width: OnboardingTokens.borderWidthThick,
                            ),
                          ),
                        ),
                      ),

                      // Concentric Primary Green & Mint Green Target Halo Behind Character
                      Positioned(
                        top: artHeight * 0.06,
                        left: w * 0.13,
                        right: w * 0.13,
                        height: w * 0.74,
                        child: Container(
                          decoration: BoxDecoration(
                            color: NeoTokens.primaryGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: NeoTokens.black,
                              width: OnboardingTokens.borderWidthThick,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: NeoTokens.black,
                                offset: Offset(6.0, 6.0),
                                blurRadius: NeoTokens.shadowBlurRadius,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: w * 0.54,
                              height: w * 0.54,
                              decoration: BoxDecoration(
                                color: NeoTokens.mintGreen,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: NeoTokens.black,
                                  width: OnboardingTokens.borderWidth,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Dashed Connector Lines to Specimen Cards
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _DashedConnectorsPainter(),
                        ),
                      ),

                      // High-Resolution Die-Cut Portrait Sticker (Slide 2)
                      Positioned(
                        bottom: 0.0,
                        left: w * 0.14,
                        right: w * 0.14,
                        height: artHeight * 0.76,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: disableAnimations ? 1.0 : 0.94,
                            end: 1.0,
                          ),
                          duration: disableAnimations
                              ? Duration.zero
                              : NeoMotion.durationMedium,
                          curve: NeoMotion.curveBounce,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              alignment: Alignment.bottomCenter,
                              child: child,
                            );
                          },
                          child: Image.asset(
                            'assets/onboarding/photos/onboarding_2_sticker.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),

                      // 4 Specimen Callout Cards (Strictly outside Face Safe Zone [0.27w..0.72w] × [0.20h..0.50h])
                      // Top-Left: KARBOHIDRAT (Nasi goreng)
                      Positioned(
                        left: w * 0.02,
                        top: artHeight * 0.12,
                        width: calloutWidth,
                        child: const NutritionCalloutCard(
                          tag: 'KARBOHIDRAT',
                          tagColor: NeoTokens.orangeCarb,
                          tagTextColor: NeoTokens.white,
                          foodName: 'Nasi goreng',
                          macroValue: '45g • 310 kkal',
                          macroPillColor: NeoTokens.vividYellow,
                          imageAsset: 'assets/onboarding/food/nasi_goreng.png',
                          rotation: -0.06,
                        ),
                      ),

                      // Top-Right: PROTEIN (Sate ayam)
                      Positioned(
                        right: w * 0.02,
                        top: artHeight * 0.12,
                        width: calloutWidth,
                        child: const NutritionCalloutCard(
                          tag: 'PROTEIN',
                          tagColor: NeoTokens.primaryGreen,
                          tagTextColor: NeoTokens.white,
                          foodName: 'Sate ayam',
                          macroValue: '28g • Tinggi Pro',
                          macroPillColor: NeoTokens.mintGreen,
                          imageAsset: 'assets/onboarding/food/sate.png',
                          rotation: 0.06,
                        ),
                      ),

                      // Mid-Left: VITAMIN (Mangga)
                      Positioned(
                        left: w * 0.02,
                        top: artHeight * 0.51,
                        width: calloutWidth,
                        child: const NutritionCalloutCard(
                          tag: 'VITAMIN',
                          tagColor: NeoTokens.skyBlue,
                          tagTextColor: NeoTokens.white,
                          foodName: 'Mangga',
                          macroValue: 'Vit C • Serat',
                          macroPillColor: NeoTokens.mintGreen,
                          imageAsset: 'assets/onboarding/food/mangga.png',
                          rotation: 0.05,
                        ),
                      ),

                      // Mid-Right: ENERGI (Kentang/Pisang goreng)
                      Positioned(
                        right: w * 0.02,
                        top: artHeight * 0.51,
                        width: calloutWidth,
                        child: const NutritionCalloutCard(
                          tag: 'ENERGI',
                          tagColor: NeoTokens.lavender,
                          tagTextColor: NeoTokens.black,
                          foodName: 'Kentang goreng',
                          macroValue: '180 kkal',
                          macroPillColor: NeoTokens.vividYellow,
                          imageAsset:
                              'assets/onboarding/food/pisang_goreng.png',
                          rotation: -0.05,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Bottom Torn Paper Editorial Copy Card
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: cardHeight,
                child: TornPaperCard(
                  jagHeight: 18.0,
                  accentColor: NeoTokens.primaryGreen,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kicker Row
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 6.0,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: NeoTokens.black,
                                  borderRadius: BorderRadius.circular(4.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: NeoTokens.primaryGreen,
                                      offset: Offset(2.5, 2.5),
                                      blurRadius: NeoTokens.shadowBlurRadius,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '02 · NUTRITION AWARENESS',
                                  style: TextStyle(
                                    color: NeoTokens.warmBackground,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: NeoTokens.mintGreen,
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(
                                    color: NeoTokens.black,
                                    width: 1.6,
                                  ),
                                ),
                                child: const Text(
                                  '• DATA GIZI TKPI',
                                  style: TextStyle(
                                    color: NeoTokens.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),

                          // Headline with Mint Green Highlight Box
                          Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.0,
                                height: 1.06,
                                color: NeoTokens.black,
                              ),
                              children: [
                                const TextSpan(text: 'Setiap Gigitan '),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 2.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: NeoTokens.mintGreen,
                                      borderRadius: BorderRadius.circular(
                                        NeoTokens.radiusSmall,
                                      ),
                                      border: Border.all(
                                        color: NeoTokens.black,
                                        width: OnboardingTokens.borderWidthThin,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: NeoTokens.black,
                                          offset: NeoTokens.shadowOffset,
                                          blurRadius:
                                              NeoTokens.shadowBlurRadius,
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'Punya Arti!',
                                      style: TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -1.0,
                                        height: 1.05,
                                        color: NeoTokens.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10.0),

                          // Subtitle
                          const Text(
                            'Pahami rincian kalori, protein, karbohidrat, dan vitamin yang dibutuhkan tubuhmu setiap hari.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                              color: NeoTokens.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SquareGridPainter extends CustomPainter {
  final Color lineColor;
  final double gridSize;

  _SquareGridPainter({required this.lineColor, required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SquareGridPainter oldDelegate) => false;
}

class _TrianglePainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;

  _TrianglePainter({
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.55, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height * 0.85)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..strokeWidth = borderWidth
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) => false;
}

class _DashedConnectorsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NeoTokens.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width * 0.5, size.height * 0.42);
    final targets = [
      Offset(size.width * 0.22, size.height * 0.26),
      Offset(size.width * 0.78, size.height * 0.26),
      Offset(size.width * 0.22, size.height * 0.62),
      Offset(size.width * 0.78, size.height * 0.62),
    ];

    for (final target in targets) {
      _drawDashedLine(canvas, center, target, paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 5.0;
    const double dashSpace = 4.0;
    final double dx = p2.dx - p1.dx;
    final double dy = p2.dy - p1.dy;
    final double distance = Offset(dx, dy).distance;
    if (distance == 0) return;

    final double ux = dx / distance;
    final double uy = dy / distance;
    double current = 0;

    while (current < distance) {
      final double end = (current + dashWidth).clamp(0.0, distance);
      canvas.drawLine(
        Offset(p1.dx + ux * current, p1.dy + uy * current),
        Offset(p1.dx + ux * end, p1.dy + uy * end),
        paint,
      );
      current += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
