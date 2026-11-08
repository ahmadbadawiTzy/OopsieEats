import 'package:flutter/material.dart';
import 'package:oopsieeats/core/app_icons.dart';
import 'package:oopsieeats/features/onboarding/models/onboarding_tokens.dart';
import 'package:oopsieeats/features/onboarding/widgets/starburst_painter.dart';
import 'package:oopsieeats/features/onboarding/widgets/torn_paper_card.dart';

/// Slide 3: Healthy Habits — "Mulai dari Piringmu, Ubah Kebiasaanmu!"
class SlideHealthyHabits extends StatelessWidget {
  const SlideHealthyHabits({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        final cardHeight = (h * 0.40).clamp(260.0, 320.0);
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
                  color: OnboardingTokens.mint,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Background Dot Grid
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _DotGridPainter(
                            dotColor: OnboardingTokens.black.withValues(
                              alpha: 0.12,
                            ),
                            spacing: w * 0.052,
                            dotRadius: 1.5,
                          ),
                        ),
                      ),

                      // Sunburst rays & sun (top-left)
                      Positioned(
                        left: -w * 0.30,
                        top: -artHeight * 0.12,
                        child: SunburstWidget(size: w * 1.30),
                      ),

                      // Star confetti
                      const Positioned(
                        left: 24,
                        top: 200,
                        child: StarConfetti(size: 28.0, rotation: -0.2),
                      ),
                      Positioned(
                        right: w * 0.35,
                        top: 14,
                        child: const StarConfetti(size: 28.0, rotation: 0.25),
                      ),
                      Positioned(
                        left: w * 0.44,
                        top: 8,
                        child: const StarConfetti(size: 18.0, rotation: -0.35),
                      ),

                      // Ahmad Badawi Sticker (smiling, positioned on the left)
                      Positioned(
                        bottom: 0.0,
                        left: -w * 0.04,
                        right: w * 0.18,
                        height: artHeight * 0.74,
                        child: Image.asset(
                          'assets/onboarding/photos/onboarding_3_sticker.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                        ),
                      ),

                      // "Riwayat Makan" Sticky Note Card (top right)
                      Positioned(
                        right: w * 0.04,
                        top: artHeight * 0.12,
                        width: (w * 0.38).clamp(132.0, 160.0),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Transform.rotate(
                              angle: 0.07, // ~4 degrees
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 10.0,
                                ),
                                decoration: BoxDecoration(
                                  color: OnboardingTokens.white,
                                  border: Border.all(
                                    color: OnboardingTokens.black,
                                    width: OnboardingTokens.borderWidthThin,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: OnboardingTokens.black,
                                      offset: Offset(3.5, 3.5),
                                      blurRadius: 0.0,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'RIWAYAT MAKAN',
                                      style: TextStyle(
                                        color: OnboardingTokens.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),
                                    _mealRow('Sarapan', OnboardingTokens.green),
                                    const SizedBox(height: 4.0),
                                    _mealRow(
                                      'Makan siang',
                                      OnboardingTokens.green,
                                    ),
                                    const SizedBox(height: 4.0),
                                    _mealRow(
                                      'Makan malam',
                                      OnboardingTokens.yellow,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Yellow Washi Tape on top edge
                            Positioned(
                              top: -8,
                              left: 20,
                              child: Transform.rotate(
                                angle: -0.10,
                                child: Container(
                                  width: 44,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: OnboardingTokens.yellow.withValues(
                                      alpha: 0.9,
                                    ),
                                    border: const Border(
                                      left: BorderSide(
                                        color: OnboardingTokens.black,
                                        width: 1.0,
                                        style: BorderStyle.solid,
                                      ),
                                      right: BorderSide(
                                        color: OnboardingTokens.black,
                                        width: 1.0,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 4-Bar Nutrition Intake Chart (bottom right)
                      Positioned(
                        right: w * 0.05,
                        bottom: artHeight * 0.04,
                        width: w * 0.24,
                        height: artHeight * 0.32,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _chartBar(0.32, OnboardingTokens.yellow),
                            const SizedBox(width: 4.0),
                            _chartBar(0.56, OnboardingTokens.orange),
                            const SizedBox(width: 4.0),
                            _chartBar(0.84, OnboardingTokens.green),
                            const SizedBox(width: 4.0),
                            _chartBar(1.00, OnboardingTokens.white),
                          ],
                        ),
                      ),

                      // Floating Fruits (Strict Face Safe Zone & Bounded Scale)
                      // Mangga (top-left, high above face)
                      _floatingFood(
                        image: 'assets/onboarding/food/mangga.png',
                        left: w * 0.02,
                        top: artHeight * 0.08,
                        width: (w * 0.15).clamp(40.0, 56.0),
                        rotation: -0.24,
                        maxHeight: 48.0,
                      ),
                      // Semangka (mid-right)
                      _floatingFood(
                        image: 'assets/onboarding/food/semangka.png',
                        left: w * 0.67,
                        top: artHeight * 0.38,
                        width: (w * 0.17).clamp(48.0, 68.0),
                        rotation: 0.24,
                        maxHeight: 52.0,
                      ),
                      // Tomat (top-right)
                      _floatingFood(
                        image: 'assets/onboarding/food/tomat.png',
                        left: w * 0.79,
                        top: artHeight * 0.02,
                        width: (w * 0.14).clamp(38.0, 52.0),
                        rotation: 0.28,
                        maxHeight: 46.0,
                      ),
                      // Cabai (bottom-left, near waist)
                      _floatingFood(
                        image: 'assets/onboarding/food/cabai.png',
                        left: w * 0.02,
                        top: artHeight * 0.64,
                        width: (w * 0.16).clamp(42.0, 58.0),
                        rotation: -0.35,
                        maxHeight: 50.0,
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
                            '03 · HEALTHY HABITS',
                            style: TextStyle(
                              color: OnboardingTokens.cream,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),

                        // Headline with two Highlights
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                              height: 1.10,
                              color: OnboardingTokens.black,
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
                                    color: OnboardingTokens.yellow,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: const Text(
                                    'Piringmu,',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.8,
                                      height: 1.10,
                                      color: OnboardingTokens.black,
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
                                    color: OnboardingTokens.mint,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: const Text(
                                    'Kebiasaanmu!',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.8,
                                      height: 1.10,
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
                          'Simpan riwayat makanan dan pantau perjalanan pola makanmu menjadi lebih baik.',
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

  Widget _mealRow(String title, Color boxColor) {
    return Row(
      children: [
        Container(
          width: 14.0,
          height: 14.0,
          decoration: BoxDecoration(
            color: boxColor,
            border: Border.all(color: OnboardingTokens.black, width: 1.5),
          ),
          child: const Center(
            child: Icon(
              AppIcons.check,
              size: AppIcons.sizeMicro,
              color: OnboardingTokens.black,
            ),
          ),
        ),
        const SizedBox(width: 5.0),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: OnboardingTokens.black,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chartBar(double heightFraction, Color color) {
    return Expanded(
      child: FractionallySizedBox(
        heightFactor: heightFraction,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: OnboardingTokens.black,
              width: OnboardingTokens.borderWidthThin,
            ),
            boxShadow: const [
              BoxShadow(
                color: OnboardingTokens.black,
                offset: Offset(2.0, 2.0),
                blurRadius: 0.0,
              ),
            ],
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
