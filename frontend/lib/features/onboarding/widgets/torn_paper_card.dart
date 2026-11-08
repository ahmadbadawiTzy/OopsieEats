import 'package:flutter/material.dart';
import 'package:oopsieeats/features/onboarding/models/onboarding_tokens.dart';

/// Renders a Neo-Brutalism card with a deterministic torn paper jagged top edge
/// and thick black border, matching the single-source-of-truth prototype.
class TornPaperCard extends StatelessWidget {
  final Widget child;
  final double jagHeight;
  final double borderWidth;
  final Color backgroundColor;
  final Color borderColor;

  const TornPaperCard({
    super.key,
    required this.child,
    this.jagHeight = 18.0,
    this.borderWidth = 3.5,
    this.backgroundColor = OnboardingTokens.cream,
    this.borderColor = OnboardingTokens.black,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TornPaperPainter(
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        borderWidth: borderWidth,
        jagHeight: jagHeight,
      ),
      child: Padding(
        padding: EdgeInsets.only(top: jagHeight + 10.0),
        child: child,
      ),
    );
  }
}

class _TornPaperPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double jagHeight;

  const _TornPaperPainter({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.jagHeight,
  });

  Path _createJaggedPath(Size size, double jagYOffset) {
    final path = Path();
    const int n = 34;
    int seed = 7;

    double rnd() {
      seed = (seed * 9301 + 49297) % 233280;
      return seed / 233280.0;
    }

    // Start top-left
    path.moveTo(0, jagYOffset + (0.55 + rnd() * 0.38) * jagHeight);

    for (int i = 0; i <= n; i++) {
      final double x = (i / n) * size.width;
      final double baseFactor = (i % 2 == 1) ? 0.18 : 0.55;
      final double y = jagYOffset + (baseFactor + rnd() * 0.38) * jagHeight;
      path.lineTo(x, y);
    }

    // Close down to the bottom
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;

    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // 1. Draw black background silhouette (shifted up by borderWidth)
    final blackPath = _createJaggedPath(size, 0.0);
    canvas.drawPath(blackPath, borderPaint);

    // 2. Draw cream foreground surface (shifted down by borderWidth)
    final creamPath = _createJaggedPath(size, borderWidth);
    canvas.drawPath(creamPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _TornPaperPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.jagHeight != jagHeight;
  }
}
