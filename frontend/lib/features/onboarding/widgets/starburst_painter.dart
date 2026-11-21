import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/features/onboarding/models/onboarding_tokens.dart';

/// Custom painter for the multi-point Neo-Brutalist starburst / explosion shape
/// used behind the hero character on Slide 1.
class StarburstPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final int points;
  final double innerRadiusRatio;
  final double borderWidth;
  final Offset shadowOffset;

  StarburstPainter({
    this.fillColor = OnboardingTokens.vividYellow,
    this.borderColor = OnboardingTokens.black,
    this.points = 20,
    this.innerRadiusRatio = 0.72,
    this.borderWidth = OnboardingTokens.borderWidthThick,
    this.shadowOffset = const Offset(6.0, 6.0),
  });

  Path _buildStarPath(Size size, Offset offset) {
    final path = Path();
    final double cx = size.width / 2 + offset.dx;
    final double cy = size.height / 2 + offset.dy;
    final double outerR = math.min(size.width, size.height) / 2 - 8.0;
    final double innerR = outerR * innerRadiusRatio;
    final int totalVertices = points * 2;

    for (int i = 0; i < totalVertices; i++) {
      final double r = (i.isEven) ? outerR : innerR;
      final double angle = (i * math.pi / points) - (math.pi / 2);
      final double x = cx + r * math.cos(angle);
      final double y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Hard offset shadow
    final shadowPath = _buildStarPath(size, shadowOffset);
    final shadowPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(shadowPath, shadowPaint);

    // Main fill
    final mainPath = _buildStarPath(size, Offset.zero);
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(mainPath, fillPaint);

    // Thick border
    final strokePaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.miter;
    canvas.drawPath(mainPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant StarburstPainter oldDelegate) => false;
}

/// Custom painter for the radial comic sunburst rays + primaryGreen/vividYellow sun on Slide 3.
class SunburstWidget extends StatelessWidget {
  final double size;
  final Color sunColor;
  final Color rayColor;

  const SunburstWidget({
    super.key,
    required this.size,
    this.sunColor = NeoTokens.primaryGreen,
    this.rayColor = NeoTokens.vividYellow,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SunburstPainter(
          sunColor: sunColor,
          rayColor: rayColor,
        ),
      ),
    );
  }
}

class _SunburstPainter extends CustomPainter {
  final Color sunColor;
  final Color rayColor;

  _SunburstPainter({
    required this.sunColor,
    required this.rayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.36, size.height * 0.42);
    final maxR = math.max(size.width, size.height) * 0.85;
    const int rayCount = 12;
    const double sweepAngle = (2 * math.pi) / (rayCount * 2);

    final rayFill = Paint()
      ..color = rayColor
      ..style = PaintingStyle.fill;

    final borderStroke = Paint()
      ..color = NeoTokens.black
      ..strokeWidth = OnboardingTokens.borderWidthThick
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < rayCount; i++) {
      final startAngle = i * 2 * sweepAngle;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: maxR),
          startAngle,
          sweepAngle,
          false,
        )
        ..close();

      canvas.drawPath(path, rayFill);
      canvas.drawPath(path, borderStroke);
    }

    // Center circle sun with hard black offset shadow
    final sunRadius = size.width * 0.22;
    canvas.drawCircle(
      center + const Offset(5.0, 5.0),
      sunRadius,
      Paint()..color = NeoTokens.black,
    );
    canvas.drawCircle(
      center,
      sunRadius,
      Paint()..color = sunColor,
    );
    canvas.drawCircle(
      center,
      sunRadius,
      Paint()
        ..color = NeoTokens.black
        ..strokeWidth = OnboardingTokens.borderWidthThick + 0.8
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter oldDelegate) => false;
}
