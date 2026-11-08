import 'package:flutter/material.dart';
import 'package:oopsieeats/features/onboarding/models/onboarding_tokens.dart';
import 'package:oopsieeats/features/onboarding/widgets/nutrition_callout_card.dart';
import 'package:oopsieeats/features/onboarding/widgets/torn_paper_card.dart';

/// Slide 2: Nutrition Awareness — "Setiap Gigitan Punya Arti!"
class SlideNutritionAwareness extends StatelessWidget {
  const SlideNutritionAwareness({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        final cardHeight = (h * 0.38).clamp(240.0, 310.0);
        final artHeight = h - cardHeight + 25.0;

        return Container(
          color: OnboardingTokens.cream,
          child: Stack(
            children: [
              // 1. Top Art Canvas
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: artHeight,
                child: Container(
                  color: OnboardingTokens.yellow,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Grid lines background
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _GridLinesPainter(
                            lineColor: OnboardingTokens.black.withValues(
                              alpha: 0.12,
                            ),
                            spacing: w * 0.08,
                            lineWidth: 1.2,
                          ),
                        ),
                      ),

                      // Green Circle in center
                      Positioned(
                        left: w * 0.14,
                        top: artHeight * 0.06,
                        width: w * 0.72,
                        height: w * 0.72,
                        child: Container(
                          decoration: BoxDecoration(
                            color: OnboardingTokens.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: OnboardingTokens.black,
                              width: OnboardingTokens.borderWidth,
                            ),
                          ),
                        ),
                      ),

                      // Orange Triangle (mid-left)
                      Positioned(
                        left: -w * 0.12,
                        top: artHeight * 0.40,
                        width: w * 0.38,
                        height: w * 0.38,
                        child: CustomPaint(
                          painter: _TrianglePainter(
                            fillColor: OnboardingTokens.orange,
                            strokeColor: OnboardingTokens.black,
                            strokeWidth: OnboardingTokens.borderWidthThin,
                          ),
                        ),
                      ),

                      // White Circle (bottom-right)
                      Positioned(
                        right: -w * 0.14,
                        bottom: artHeight * 0.06,
                        width: w * 0.42,
                        height: w * 0.42,
                        child: Container(
                          decoration: BoxDecoration(
                            color: OnboardingTokens.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: OnboardingTokens.black,
                              width: OnboardingTokens.borderWidthThin,
                            ),
                          ),
                        ),
                      ),

                      // Dotted connector lines
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _DottedConnectorsPainter(
                            artWidth: w,
                            artHeight: artHeight,
                          ),
                        ),
                      ),

                      // Ahmad Badawi Sticker (center facing)
                      Positioned(
                        bottom: 0.0,
                        left: w * 0.16,
                        right: w * 0.16,
                        height: artHeight * 0.72,
                        child: Image.asset(
                          'assets/onboarding/photos/onboarding_2_sticker.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                        ),
                      ),

                      // 4 Nutrition Callout Cards (Bounded scale, strict Face Safe Zone clearance)
                      // 1. Top-Left: Karbohidrat (Nasi Goreng)
                      Positioned(
                        left: w * 0.025,
                        top: artHeight * 0.14,
                        child: NutritionCalloutCard(
                          tag: 'KARBOHIDRAT',
                          tagColor: OnboardingTokens.orange,
                          foodName: 'Nasi goreng',
                          imagePath: 'assets/onboarding/food/nasi_goreng.png',
                          width: (w * 0.28).clamp(88.0, 114.0),
                          rotation: -0.07,
                        ),
                      ),

                      // 2. Top-Right: Protein (Sate Ayam)
                      Positioned(
                        right: w * 0.025,
                        top: artHeight * 0.14,
                        child: NutritionCalloutCard(
                          tag: 'PROTEIN',
                          tagColor: OnboardingTokens.yellow,
                          foodName: 'Sate ayam',
                          imagePath: 'assets/onboarding/food/sate.png',
                          width: (w * 0.28).clamp(88.0, 114.0),
                          rotation: 0.087,
                        ),
                      ),

                      // 3. Bottom-Left: Vitamin (Mangga)
                      Positioned(
                        left: w * 0.025,
                        top: artHeight * 0.52,
                        child: NutritionCalloutCard(
                          tag: 'VITAMIN',
                          tagColor: OnboardingTokens.mint,
                          foodName: 'Mangga',
                          imagePath: 'assets/onboarding/food/mangga.png',
                          width: (w * 0.28).clamp(88.0, 114.0),
                          rotation: 0.07,
                        ),
                      ),

                      // 4. Bottom-Right: Energi (Kentang Goreng)
                      Positioned(
                        right: w * 0.025,
                        top: artHeight * 0.52,
                        child: NutritionCalloutCard(
                          tag: 'ENERGI',
                          tagColor: OnboardingTokens.pink,
                          foodName: 'Kentang goreng',
                          imagePath: 'assets/onboarding/food/pisang_goreng.png',
                          width: (w * 0.28).clamp(88.0, 114.0),
                          rotation: -0.087,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Bottom Torn Paper Card
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: cardHeight,
                child: TornPaperCard(
                  jagHeight: 18.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kicker
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: OnboardingTokens.black,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: const Text(
                              '02 · NUTRITION AWARENESS',
                              style: TextStyle(
                                color: OnboardingTokens.cream,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10.0),

                          // Headline with Highlight
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.0,
                                height: 1.05,
                                color: OnboardingTokens.black,
                              ),
                              children: [
                                const TextSpan(text: 'Setiap Gigitan '),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0,
                                      vertical: 1.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: OnboardingTokens.mint,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: const Text(
                                      'Punya Arti!',
                                      style: TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -1.0,
                                        height: 1.05,
                                        color: OnboardingTokens.black,
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
                            'Pahami apa yang kamu konsumsi dan kenali nutrisi yang dibutuhkan tubuhmu.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.38,
                              color: OnboardingTokens.black,
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

/// Custom painter for background grid pattern
class _GridLinesPainter extends CustomPainter {
  final Color lineColor;
  final double spacing;
  final double lineWidth;

  const _GridLinesPainter({
    required this.lineColor,
    required this.spacing,
    required this.lineWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridLinesPainter oldDelegate) => false;
}

/// Triangle painter for Slide 2
class _TrianglePainter extends CustomPainter {
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  const _TrianglePainter({
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) => false;
}

/// Dotted connector lines between figure and callouts
class _DottedConnectorsPainter extends CustomPainter {
  final double artWidth;
  final double artHeight;

  const _DottedConnectorsPainter({
    required this.artWidth,
    required this.artHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = OnboardingTokens.black
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    void drawDottedLine(Offset p1, Offset p2) {
      const dashWidth = 5.0;
      const dashSpace = 4.0;
      final dx = p2.dx - p1.dx;
      final dy = p2.dy - p1.dy;
      final distance = (dx * dx + dy * dy).clamp(0.0, 1000000.0);
      final total = distance > 0 ? (dx * dx + dy * dy) : 1.0;
      final length = (total > 0) ? (total > 0 ? (p2 - p1).distance : 0.0) : 0.0;
      if (length <= 0) return;

      double currentDist = 0.0;
      while (currentDist < length) {
        final startRatio = currentDist / length;
        final endRatio = (currentDist + dashWidth).clamp(0.0, length) / length;
        canvas.drawLine(
          Offset(p1.dx + dx * startRatio, p1.dy + dy * startRatio),
          Offset(p1.dx + dx * endRatio, p1.dy + dy * endRatio),
          paint,
        );
        currentDist += dashWidth + dashSpace;
      }
    }

    // Top-left connector
    drawDottedLine(
      Offset(artWidth * 0.28, artHeight * 0.32),
      Offset(artWidth * 0.42, artHeight * 0.40),
    );
    // Top-right connector
    drawDottedLine(
      Offset(artWidth * 0.72, artHeight * 0.32),
      Offset(artWidth * 0.58, artHeight * 0.40),
    );
    // Bottom-left connector
    drawDottedLine(
      Offset(artWidth * 0.28, artHeight * 0.68),
      Offset(artWidth * 0.42, artHeight * 0.60),
    );
    // Bottom-right connector
    drawDottedLine(
      Offset(artWidth * 0.72, artHeight * 0.68),
      Offset(artWidth * 0.58, artHeight * 0.60),
    );
  }

  @override
  bool shouldRepaint(covariant _DottedConnectorsPainter oldDelegate) => false;
}
