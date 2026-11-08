import 'package:flutter/material.dart';
import 'package:oopsieeats/features/onboarding/models/onboarding_tokens.dart';
import 'package:oopsieeats/features/onboarding/widgets/starburst_painter.dart';
import 'package:oopsieeats/features/onboarding/widgets/torn_paper_card.dart';

/// Slide 1: Food Discovery — "Kenali Isi Piringmu!"
class SlideFoodDiscovery extends StatelessWidget {
  const SlideFoodDiscovery({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Card takes proportional lower portion
        final cardHeight = (h * 0.38).clamp(240.0, 310.0);
        final artHeight = h - cardHeight + 25.0; // Overlap with torn edge

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
                  color: OnboardingTokens.green,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Background Dot Grid
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _DotGridPainter(
                            dotColor: OnboardingTokens.black.withValues(
                              alpha: 0.15,
                            ),
                            spacing: w * 0.052,
                            dotRadius: 1.5,
                          ),
                        ),
                      ),

                      // Yellow Starburst
                      Positioned(
                        left: w * 0.10,
                        top: artHeight * 0.10,
                        child: StarburstWidget(size: w * 0.78),
                      ),

                      // Orange Circle (bottom left)
                      Positioned(
                        left: -w * 0.14,
                        bottom: -w * 0.08,
                        child: Container(
                          width: w * 0.48,
                          height: w * 0.48,
                          decoration: BoxDecoration(
                            color: OnboardingTokens.orange,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: OnboardingTokens.black,
                              width: OnboardingTokens.borderWidthThin,
                            ),
                          ),
                        ),
                      ),

                      // Mint Rotated Square (mid right)
                      Positioned(
                        right: -w * 0.10,
                        top: artHeight * 0.42,
                        child: Transform.rotate(
                          angle: 0.31, // 18 degrees
                          child: Container(
                            width: w * 0.32,
                            height: w * 0.32,
                            decoration: BoxDecoration(
                              color: OnboardingTokens.mint,
                              border: Border.all(
                                color: OnboardingTokens.black,
                                width: OnboardingTokens.borderWidthThin,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Floating Indonesian Foods (Strict Face Safe Zone & Bounded Scale)
                      // Nasi Goreng (top-left)
                      _floatingFood(
                        image: 'assets/onboarding/food/nasi_goreng.png',
                        left: w * 0.02,
                        top: artHeight * 0.12,
                        width: (w * 0.25).clamp(65.0, 95.0),
                        rotation: -0.21,
                      ),
                      // Sate (top-right)
                      _floatingFood(
                        image: 'assets/onboarding/food/sate.png',
                        left: w * 0.70,
                        top: artHeight * 0.10,
                        width: (w * 0.26).clamp(75.0, 100.0),
                        rotation: 0.17,
                      ),
                      // Bakso (mid-left)
                      _floatingFood(
                        image: 'assets/onboarding/food/bakso.png',
                        left: -w * 0.01,
                        top: artHeight * 0.40,
                        width: (w * 0.22).clamp(60.0, 85.0),
                        rotation: -0.14,
                      ),
                      // Pisang Goreng (mid-right)
                      _floatingFood(
                        image: 'assets/onboarding/food/pisang_goreng.png',
                        left: w * 0.70,
                        top: artHeight * 0.26,
                        width: (w * 0.24).clamp(68.0, 92.0),
                        rotation: 0.17,
                      ),
                      // Martabak (bottom-left)
                      _floatingFood(
                        image: 'assets/onboarding/food/martabak.png',
                        left: -w * 0.03,
                        top: artHeight * 0.64,
                        width: (w * 0.22).clamp(60.0, 85.0),
                        rotation: -0.17,
                      ),
                      // Klepon (mid-right bottom)
                      _floatingFood(
                        image: 'assets/onboarding/food/klepon.png',
                        left: w * 0.78,
                        top: artHeight * 0.48,
                        width: (w * 0.18).clamp(50.0, 70.0),
                        rotation: 0.14,
                      ),
                      // Cabai (high above head)
                      _floatingFood(
                        image: 'assets/onboarding/food/cabai.png',
                        left: w * 0.36,
                        top: artHeight * 0.01,
                        width: (w * 0.13).clamp(36.0, 48.0),
                        rotation: -0.17,
                        maxHeight: 42.0,
                      ),
                      // Tomat (high above head)
                      _floatingFood(
                        image: 'assets/onboarding/food/tomat.png',
                        left: w * 0.58,
                        top: artHeight * 0.01,
                        width: (w * 0.12).clamp(36.0, 46.0),
                        rotation: 0.31,
                        maxHeight: 42.0,
                      ),
                      // Mangga (far left, clear of face safe zone)
                      _floatingFood(
                        image: 'assets/onboarding/food/mangga.png',
                        left: w * 0.05,
                        top: artHeight * 0.26,
                        width: (w * 0.14).clamp(42.0, 54.0),
                        rotation: -0.31,
                      ),

                      // Ahmad Badawi Sticker (die-cut portrait, pose with plate)
                      Positioned(
                        bottom: 0.0,
                        left: w * 0.13,
                        right: w * 0.07,
                        height: artHeight * 0.78,
                        child: Image.asset(
                          'assets/onboarding/photos/onboarding_1_sticker.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
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
                              '01 · FOOD DISCOVERY',
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
                                const TextSpan(text: 'Kenali Isi '),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0,
                                      vertical: 1.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: OnboardingTokens.yellow,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: const Text(
                                      'Piringmu!',
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
                            'Temukan berbagai makanan dan kenali kandungan nutrisi di balik setiap hidangan.',
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

  Widget _floatingFood({
    required String image,
    required double left,
    required double top,
    required double width,
    required double rotation,
    double? maxHeight,
  }) {
    final clampedWidth = width.clamp(32.0, 110.0);
    final clampedHeight = (maxHeight ?? (clampedWidth * 1.2)).clamp(
      32.0,
      120.0,
    );

    return Positioned(
      left: left,
      top: top,
      width: clampedWidth,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: clampedWidth,
          maxHeight: clampedHeight,
        ),
        child: Transform.rotate(
          angle: rotation,
          child: Image.asset(
            image,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the dotted background pattern
class _DotGridPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;
  final double dotRadius;

  const _DotGridPainter({
    required this.dotColor,
    required this.spacing,
    required this.dotRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) => false;
}
