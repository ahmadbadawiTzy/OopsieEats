import 'package:flutter/material.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/features/onboarding/models/onboarding_tokens.dart';
import 'package:oopsieeats/features/onboarding/widgets/starburst_painter.dart';
import 'package:oopsieeats/features/onboarding/widgets/torn_paper_card.dart';

/// Slide 1: Food Discovery ("Kenali Isi Piringmu!")
/// Neo-Brutalism Overkill — Green & Mint Dominant Composition:
/// - Primary Green (`NeoTokens.primaryGreen`) stage with black dot-matrix pattern
/// - Mint Green (`NeoTokens.mintGreen`) diagonal corner strip + rotated collage frame
/// - 22-point Vivid Yellow (`NeoTokens.vividYellow`) explosion starburst behind subject
/// - Lavender (`NeoTokens.lavender`) bottom-left accent circle
/// - High-res die-cut portrait sticker (`onboarding_1_sticker.png`) holding real Nasi Goreng
/// - 10 floating Indonesian food items strictly outside the Face Safe Zone `[0.24w..0.70w] × [0.18h..0.48h]`
class SlideFoodDiscovery extends StatelessWidget {
  const SlideFoodDiscovery({super.key});

  @override
  Widget build(BuildContext context) {
    final disableAnimations = NeoMotion.isAnimationDisabled(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight;
        final double artHeight = h * 0.65;
        final double cardHeight = h * 0.38;

        return Container(
          color: NeoTokens.primaryGreen,
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
                      // Dotted Background Pattern
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _DotGridPainter(
                            dotColor: NeoTokens.black.withValues(alpha: 0.22),
                            spacing: 18.0,
                            radius: 1.7,
                          ),
                        ),
                      ),

                      // Top-Right Mint Green Diagonal Strip
                      Positioned(
                        top: -20,
                        right: -20,
                        width: w * 0.44,
                        height: artHeight * 0.24,
                        child: Transform.rotate(
                          angle: -0.18,
                          child: Container(
                            decoration: BoxDecoration(
                              color: NeoTokens.mintGreen,
                              border: Border.all(
                                color: NeoTokens.black,
                                width: OnboardingTokens.borderWidthThick,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: NeoTokens.black,
                                  offset: NeoTokens.shadowOffsetMedium,
                                  blurRadius: NeoTokens.shadowBlurRadius,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Bottom-Left Lavender Accent Circle
                      Positioned(
                        left: -w * 0.16,
                        bottom: -artHeight * 0.08,
                        width: w * 0.56,
                        height: w * 0.56,
                        child: Container(
                          decoration: BoxDecoration(
                            color: NeoTokens.lavender,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: NeoTokens.black,
                              width: OnboardingTokens.borderWidthThick,
                            ),
                          ),
                        ),
                      ),

                      // Right Rotated Mint Green Collage Frame
                      Positioned(
                        right: -w * 0.08,
                        top: artHeight * 0.36,
                        width: w * 0.36,
                        height: artHeight * 0.28,
                        child: Transform.rotate(
                          angle: 0.22,
                          child: Container(
                            decoration: BoxDecoration(
                              color: NeoTokens.mintGreen,
                              borderRadius: BorderRadius.circular(
                                NeoTokens.radiusSmall,
                              ),
                              border: Border.all(
                                color: NeoTokens.black,
                                width: OnboardingTokens.borderWidthThick,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: NeoTokens.black,
                                  offset: NeoTokens.shadowOffsetMedium,
                                  blurRadius: NeoTokens.shadowBlurRadius,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Central Vivid Yellow Explosion Starburst
                      Positioned(
                        top: artHeight * 0.03,
                        left: w * 0.05,
                        right: w * 0.05,
                        height: artHeight * 0.68,
                        child: CustomPaint(
                          painter: StarburstPainter(
                            fillColor: NeoTokens.vividYellow,
                            borderColor: NeoTokens.black,
                            points: 22,
                            innerRadiusRatio: 0.72,
                            borderWidth: OnboardingTokens.borderWidthThick,
                            shadowOffset: const Offset(6.0, 6.0),
                          ),
                        ),
                      ),

                      // Floating Food Stickers (Strict Face Safe Zone: [0.24w..0.70w] × [0.18h..0.48h])
                      // Left Column (right edge < 0.24w)
                      _floatingFood(
                        image: 'assets/onboarding/food/nasi_goreng.png',
                        left: w * 0.015,
                        top: artHeight * 0.10,
                        width: (w * 0.21).clamp(56.0, 82.0),
                        rotation: -0.16,
                        badgeColor: NeoTokens.warmBackground,
                      ),
                      _floatingFood(
                        image: 'assets/onboarding/food/ayam_goreng.png',
                        left: w * 0.01,
                        top: artHeight * 0.26,
                        width: (w * 0.19).clamp(50.0, 74.0),
                        rotation: 0.14,
                      ),
                      _floatingFood(
                        image: 'assets/onboarding/food/bakso.png',
                        left: w * 0.01,
                        top: artHeight * 0.41,
                        width: (w * 0.20).clamp(52.0, 76.0),
                        rotation: -0.14,
                        badgeColor: NeoTokens.vividYellow,
                      ),
                      _floatingFood(
                        image: 'assets/onboarding/food/martabak.png',
                        left: w * 0.015,
                        top: artHeight * 0.62,
                        width: (w * 0.21).clamp(54.0, 80.0),
                        rotation: -0.12,
                        badgeColor: NeoTokens.white,
                      ),

                      // Right Column (left >= 0.72w)
                      _floatingFood(
                        image: 'assets/onboarding/food/sate.png',
                        left: w * 0.72,
                        top: artHeight * 0.09,
                        width: (w * 0.24).clamp(64.0, 92.0),
                        rotation: 0.16,
                        badgeColor: NeoTokens.warmBackground,
                      ),
                      _floatingFood(
                        image: 'assets/onboarding/food/pisang_goreng.png',
                        left: w * 0.73,
                        top: artHeight * 0.27,
                        width: (w * 0.21).clamp(56.0, 80.0),
                        rotation: 0.20,
                      ),
                      _floatingFood(
                        image: 'assets/onboarding/food/klepon.png',
                        left: w * 0.76,
                        top: artHeight * 0.47,
                        width: (w * 0.18).clamp(48.0, 68.0),
                        rotation: 0.14,
                        badgeColor: NeoTokens.orangeCarb,
                      ),
                      _floatingFood(
                        image: 'assets/onboarding/food/rendang.png',
                        left: w * 0.75,
                        top: artHeight * 0.63,
                        width: (w * 0.19).clamp(50.0, 72.0),
                        rotation: -0.12,
                      ),

                      // Top Accent Garnishes (strictly above Face Safe Zone, bottom < 0.18h)
                      _floatingFood(
                        image: 'assets/onboarding/food/cabai.png',
                        left: w * 0.42,
                        top: artHeight * 0.08,
                        width: (w * 0.12).clamp(34.0, 44.0),
                        rotation: -0.17,
                        maxHeight: 38.0,
                      ),
                      _floatingFood(
                        image: 'assets/onboarding/food/tomat.png',
                        left: w * 0.57,
                        top: artHeight * 0.015,
                        width: (w * 0.11).clamp(34.0, 42.0),
                        rotation: 0.28,
                        maxHeight: 38.0,
                      ),

                      // High-Resolution Die-Cut Portrait Sticker (Pose with Real Nasi Goreng Plate)
                      Positioned(
                        bottom: 0.0,
                        left: w * 0.12,
                        right: w * 0.06,
                        height: artHeight * 0.79,
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
                            'assets/onboarding/photos/onboarding_1_sticker.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),

                      // Brutalist Plate Telemetry Callout Tag (anchored below Face Safe Zone near plate)
                      Positioned(
                        left: w * 0.04,
                        bottom: artHeight * 0.06,
                        child: Transform.rotate(
                          angle: -0.06,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
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
                                  blurRadius: NeoTokens.shadowBlurRadius,
                                ),
                              ],
                            ),
                            child: const Text(
                              '• AI SCAN • 420 KKAL',
                              style: TextStyle(
                                color: NeoTokens.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
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
                  accentColor: NeoTokens.mintGreen,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kicker Row with Official Brand Accent Stamp
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
                                  '01 · FOOD DISCOVERY',
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
                                  '• DETEKSI INSTAN',
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

                          // Headline with Neo-Brutalist Bordered Highlight Box
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
                                const TextSpan(text: 'Kenali Isi '),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 2.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: NeoTokens.vividYellow,
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
                                      'Piringmu!',
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
                            'Temukan berbagai makanan favoritmu dan kenali kandungan nutrisi lengkap di balik setiap hidangan.',
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

  Widget _floatingFood({
    required String image,
    required double left,
    required double top,
    required double width,
    required double rotation,
    double? maxHeight,
    Color? badgeColor,
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
          child: badgeColor != null
              ? Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                    border: Border.all(
                      color: NeoTokens.black,
                      width: 1.8,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: NeoTokens.black,
                        offset: Offset(2.5, 2.5),
                        blurRadius: NeoTokens.shadowBlurRadius,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    image,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                )
              : Image.asset(
                  image,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
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
  final double radius;

  _DotGridPainter({
    required this.dotColor,
    required this.spacing,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) => false;
}
