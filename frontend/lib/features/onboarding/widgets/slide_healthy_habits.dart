import 'package:flutter/material.dart';
import 'package:oopsieeats/core/app_icons.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/features/onboarding/models/onboarding_tokens.dart';
import 'package:oopsieeats/features/onboarding/widgets/starburst_painter.dart';
import 'package:oopsieeats/features/onboarding/widgets/torn_paper_card.dart';

/// Slide 3: Healthy Habits ("Mulai dari Piringmu, Ubah Kebiasaanmu!")
/// Neo-Brutalism Overkill — Mint Green, Primary Green, Vivid Yellow, Orange, SkyBlue & Lavender:
/// - Mint Green (`NeoTokens.mintGreen`) stage with black dot-matrix pattern
/// - Radial `SunburstWidget` with Primary Green (`NeoTokens.primaryGreen`) center sun & Vivid Yellow (`NeoTokens.vividYellow`) rays
/// - Pinned `RIWAYAT MAKAN` sticky checklist note (`NeoTokens.primaryGreen` header, yellow washi tape)
/// - Framed 4-bar Neo-Brutalist nutrition progress chart card (`TARGET 100%` in `vividYellow`, `orangeCarb`, `primaryGreen`, `cyan`)
/// - 5 fresh fruits & veggies (`mangga`, `semangka`, `tomat`, `wortel`, `cabai`) strictly outside Face Safe Zone `[0.28w..0.72w] × [0.22h..0.52h]`
class SlideHealthyHabits extends StatelessWidget {
  const SlideHealthyHabits({super.key});

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
          color: NeoTokens.mintGreen,
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
                            dotColor: NeoTokens.black.withValues(alpha: 0.16),
                            spacing: 18.0,
                            radius: 1.6,
                          ),
                        ),
                      ),

                      // Top-Left Radial Sunburst Rays & Primary Green Sun
                      Positioned(
                        left: -w * 0.08,
                        top: -artHeight * 0.06,
                        child: SunburstWidget(
                          size: w * 1.15,
                          sunColor: NeoTokens.primaryGreen,
                          rayColor: NeoTokens.vividYellow,
                        ),
                      ),

                      // Decorative 4-Point Sparkle Stars
                      Positioned(
                        left: w * 0.44,
                        top: artHeight * 0.02,
                        child: const _SparkleStar(
                          size: 22,
                          color: NeoTokens.vividYellow,
                        ),
                      ),
                      Positioned(
                        left: w * 0.58,
                        top: artHeight * 0.025,
                        child: const _SparkleStar(
                          size: 32,
                          color: NeoTokens.vividYellow,
                        ),
                      ),
                      Positioned(
                        left: w * 0.06,
                        top: artHeight * 0.36,
                        child: const _SparkleStar(
                          size: 28,
                          color: NeoTokens.vividYellow,
                        ),
                      ),

                      // High-Resolution Die-Cut Portrait Sticker (Slide 3)
                      Positioned(
                        bottom: 0.0,
                        left: w * 0.02,
                        width: w * 0.78,
                        height: artHeight * 0.77,
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
                            'assets/onboarding/photos/onboarding_3_sticker.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),

                      // Pinned "RIWAYAT MAKAN" Sticky Note Card (top-right)
                      Positioned(
                        right: w * 0.03,
                        top: artHeight * 0.11,
                        width: (w * 0.41).clamp(138.0, 174.0),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Transform.rotate(
                              angle: 0.055,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  10.0,
                                  11.0,
                                  10.0,
                                  10.0,
                                ),
                                decoration: BoxDecoration(
                                  color: NeoTokens.white,
                                  borderRadius: BorderRadius.circular(
                                    NeoTokens.radiusSmall,
                                  ),
                                  border: Border.all(
                                    color: NeoTokens.black,
                                    width: OnboardingTokens.borderWidth,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: NeoTokens.black,
                                      offset: NeoTokens.shadowOffsetMedium,
                                      blurRadius: NeoTokens.shadowBlurRadius,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6.0,
                                        vertical: 2.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: NeoTokens.primaryGreen,
                                        borderRadius: BorderRadius.circular(3.0),
                                        border: Border.all(
                                          color: NeoTokens.black,
                                          width: 1.2,
                                        ),
                                      ),
                                      child: const Text(
                                        'RIWAYAT MAKAN',
                                        style: TextStyle(
                                          color: NeoTokens.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 7.0),
                                    _mealRow(
                                      'Sarapan',
                                      NeoTokens.mintGreen,
                                    ),
                                    const SizedBox(height: 4.5),
                                    _mealRow(
                                      'Makan siang',
                                      NeoTokens.mintGreen,
                                    ),
                                    const SizedBox(height: 4.5),
                                    _mealRow(
                                      'Makan malam',
                                      NeoTokens.vividYellow,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Vivid Yellow Washi Tape on top edge
                            Positioned(
                              top: -7,
                              left: 24,
                              child: Transform.rotate(
                                angle: -0.09,
                                child: Container(
                                  width: 48,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: NeoTokens.vividYellow,
                                    border: Border.all(
                                      color: NeoTokens.black,
                                      width: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 4-Bar Brutalist Nutrition Progress Chart Card (bottom-right)
                      Positioned(
                        right: w * 0.04,
                        bottom: artHeight * 0.04,
                        width: (w * 0.28).clamp(96.0, 124.0),
                        height: artHeight * 0.34,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 8.0),
                          decoration: BoxDecoration(
                            color: NeoTokens.warmBackground,
                            borderRadius: BorderRadius.circular(
                              NeoTokens.radiusSmall,
                            ),
                            border: Border.all(
                              color: NeoTokens.black,
                              width: OnboardingTokens.borderWidth,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: NeoTokens.black,
                                offset: NeoTokens.shadowOffsetMedium,
                                blurRadius: NeoTokens.shadowBlurRadius,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2.0,
                                ),
                                decoration: BoxDecoration(
                                  color: NeoTokens.black,
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                                child: const Text(
                                  'TARGET 100%',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: NeoTokens.vividYellow,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _chartBar(0.42, NeoTokens.vividYellow),
                                    const SizedBox(width: 4.0),
                                    _chartBar(0.64, NeoTokens.orangeCarb),
                                    const SizedBox(width: 4.0),
                                    _chartBar(0.84, NeoTokens.primaryGreen),
                                    const SizedBox(width: 4.0),
                                    _chartBar(1.00, NeoTokens.cyan),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Floating Fresh Fruits & Veggies (Strict Face Safe Zone [0.28w..0.72w] × [0.22h..0.52h])
                      // Mangga (top-left, high above face)
                      _floatingFood(
                        image: 'assets/onboarding/food/mangga.png',
                        left: w * 0.02,
                        top: artHeight * 0.08,
                        width: (w * 0.15).clamp(40.0, 56.0),
                        rotation: -0.24,
                        maxHeight: 48.0,
                      ),
                      // Semangka (mid-right, clear of face)
                      _floatingFood(
                        image: 'assets/onboarding/food/semangka.png',
                        left: w * 0.74,
                        top: artHeight * 0.38,
                        width: (w * 0.16).clamp(44.0, 62.0),
                        rotation: 0.22,
                        maxHeight: 48.0,
                      ),
                      // Tomat (top-right)
                      _floatingFood(
                        image: 'assets/onboarding/food/tomat.png',
                        left: w * 0.79,
                        top: artHeight * 0.015,
                        width: (w * 0.13).clamp(36.0, 50.0),
                        rotation: 0.28,
                        maxHeight: 44.0,
                      ),
                      // Wortel (bottom-left, near shoulder/waist)
                      _floatingFood(
                        image: 'assets/onboarding/food/wortel.png',
                        left: w * 0.015,
                        top: artHeight * 0.50,
                        width: (w * 0.15).clamp(40.0, 54.0),
                        rotation: -0.28,
                        maxHeight: 46.0,
                      ),
                      // Cabai (bottom-left lower)
                      _floatingFood(
                        image: 'assets/onboarding/food/cabai.png',
                        left: w * 0.02,
                        top: artHeight * 0.65,
                        width: (w * 0.15).clamp(40.0, 56.0),
                        rotation: -0.35,
                        maxHeight: 48.0,
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
                  accentColor: NeoTokens.vividYellow,
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
                                  '03 · HEALTHY HABITS',
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
                                  color: NeoTokens.vividYellow,
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(
                                    color: NeoTokens.black,
                                    width: 1.6,
                                  ),
                                ),
                                child: const Text(
                                  '• KONSISTEN SETIAP HARI',
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
                          const SizedBox(height: 8.0),

                          // Headline with Two Bordered Neo-Brutalist Highlights
                          Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.8,
                                height: 1.12,
                                color: NeoTokens.black,
                              ),
                              children: [
                                const TextSpan(text: 'Mulai dari '),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0,
                                      vertical: 1.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: NeoTokens.vividYellow,
                                      borderRadius: BorderRadius.circular(4.0),
                                      border: Border.all(
                                        color: NeoTokens.black,
                                        width: 1.6,
                                      ),
                                    ),
                                    child: const Text(
                                      'Piringmu,',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.8,
                                        height: 1.10,
                                        color: NeoTokens.black,
                                      ),
                                    ),
                                  ),
                                ),
                                const TextSpan(text: '\nUbah '),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0,
                                      vertical: 1.0,
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
                                      'Kebiasaanmu!',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.8,
                                        height: 1.10,
                                        color: NeoTokens.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8.0),

                          // Subtitle
                          const Text(
                            'Simpan riwayat makanan dan pantau perjalanan pola makanmu menjadi lebih sehat setiap hari.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.34,
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

  Widget _mealRow(String title, Color boxColor) {
    return Row(
      children: [
        Container(
          width: 14.0,
          height: 14.0,
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(2.5),
            border: Border.all(color: NeoTokens.black, width: 1.5),
          ),
          child: const Center(
            child: Icon(
              AppIcons.check,
              size: AppIcons.sizeMicro,
              color: NeoTokens.black,
            ),
          ),
        ),
        const SizedBox(width: 6.0),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: NeoTokens.black,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chartBar(double heightFactor, Color color) {
    return Expanded(
      child: FractionallySizedBox(
        heightFactor: heightFactor,
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.5),
            border: Border.all(
              color: NeoTokens.black,
              width: OnboardingTokens.borderWidthThin,
            ),
          ),
        ),
      ),
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
    final clampedWidth = width.clamp(32.0, 96.0);
    final clampedHeight = (maxHeight ?? (clampedWidth * 1.15)).clamp(
      32.0,
      96.0,
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
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

class _SparkleStar extends StatelessWidget {
  final double size;
  final Color color;

  const _SparkleStar({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SparklePainter(color: color)),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final Color color;

  _SparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double rOuter = size.width / 2;
    final double rInner = size.width * 0.16;

    final path = Path()
      ..moveTo(cx, 0)
      ..lineTo(cx + rInner, cy - rInner)
      ..lineTo(size.width, cy)
      ..lineTo(cx + rInner, cy + rInner)
      ..lineTo(cx, size.height)
      ..lineTo(cx - rInner, cy + rInner)
      ..lineTo(0, cy)
      ..lineTo(cx - rInner, cy - rInner)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = NeoTokens.black
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(Offset(cx, cy), rOuter * 0.08, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => false;
}

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
