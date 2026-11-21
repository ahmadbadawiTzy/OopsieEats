import 'package:flutter/material.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/features/onboarding/models/onboarding_tokens.dart';

/// Custom painter and container for the jagged torn-paper editorial copy deck.
/// Renders a triple-layer Neo-Brutalist jagged divider:
/// 1. Mint Green (`NeoTokens.mintGreen`) offset accent ridge
/// 2. Pitch Black (`NeoTokens.black`) thick structural border
/// 3. Warm Editorial Background (`NeoTokens.warmBackground`) copy deck surface
class TornPaperCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color accentColor;
  final double jagHeight;

  const TornPaperCard({
    super.key,
    required this.child,
    this.backgroundColor = OnboardingTokens.warmBackground,
    this.accentColor = OnboardingTokens.mintGreen,
    this.jagHeight = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TornPaperPainter(
        backgroundColor: backgroundColor,
        borderColor: NeoTokens.black,
        accentColor: accentColor,
        borderWidth: OnboardingTokens.borderWidthThick,
        jagHeight: jagHeight,
      ),
      child: Padding(
        padding: EdgeInsets.only(top: jagHeight + 14.0),
        child: child,
      ),
    );
  }
}

class TornPaperPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final Color accentColor;
  final double borderWidth;
  final double jagHeight;

  TornPaperPainter({
    required this.backgroundColor,
    required this.borderColor,
    required this.accentColor,
    required this.borderWidth,
    required this.jagHeight,
  });

  // Normalized jagged points (x fraction, y fraction of jagHeight)
  static const List<Offset> _jagPoints = [
    Offset(0.00, 0.72),
    Offset(0.04, 0.15),
    Offset(0.09, 0.85),
    Offset(0.14, 0.20),
    Offset(0.19, 0.90),
    Offset(0.24, 0.10),
    Offset(0.29, 0.80),
    Offset(0.35, 0.25),
    Offset(0.41, 0.92),
    Offset(0.46, 0.12),
    Offset(0.52, 0.84),
    Offset(0.57, 0.18),
    Offset(0.63, 0.88),
    Offset(0.68, 0.08),
    Offset(0.74, 0.82),
    Offset(0.79, 0.22),
    Offset(0.85, 0.95),
    Offset(0.90, 0.14),
    Offset(0.95, 0.86),
    Offset(1.00, 0.30),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Mint-Green Offset Accent Ridge above the black tear line
    final accentPath = Path();
    accentPath.moveTo(0, _jagPoints.first.dy * jagHeight - 4.5);
    for (int i = 1; i < _jagPoints.length; i++) {
      accentPath.lineTo(
        _jagPoints[i].dx * size.width,
        _jagPoints[i].dy * jagHeight - 4.5,
      );
    }
    accentPath.lineTo(size.width, size.height);
    accentPath.lineTo(0, size.height);
    accentPath.close();

    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(accentPath, accentPaint);

    // 2. Main Warm Cream Card Fill
    final fillPath = Path();
    final borderPath = Path();

    fillPath.moveTo(0, _jagPoints.first.dy * jagHeight);
    borderPath.moveTo(0, _jagPoints.first.dy * jagHeight);

    for (int i = 1; i < _jagPoints.length; i++) {
      final double px = _jagPoints[i].dx * size.width;
      final double py = _jagPoints[i].dy * jagHeight;
      fillPath.lineTo(px, py);
      borderPath.lineTo(px, py);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // 3. Thick Pitch-Black Structural Jagged Stroke
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth + 0.6
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.miter;

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant TornPaperPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.jagHeight != jagHeight;
  }
}
