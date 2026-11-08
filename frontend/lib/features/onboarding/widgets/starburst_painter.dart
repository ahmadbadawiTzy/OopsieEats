import 'package:flutter/material.dart';
import 'package:oopsieeats/features/onboarding/models/onboarding_tokens.dart';

/// 22-point comic explosion starburst for Slide 1 background.
class StarburstWidget extends StatelessWidget {
  final double size;

  const StarburstWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _StarburstPainter()),
    );
  }
}

class _StarburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Normalization ratio to 200x200 viewBox
    final double sx = size.width / 200.0;
    final double sy = size.height / 200.0;

    final rawPoints = [
      const Offset(100, 4),
      const Offset(118, 36),
      const Offset(152, 18),
      const Offset(152, 56),
      const Offset(190, 56),
      const Offset(170, 88),
      const Offset(198, 112),
      const Offset(164, 126),
      const Offset(176, 162),
      const Offset(140, 158),
      const Offset(128, 194),
      const Offset(100, 172),
      const Offset(72, 194),
      const Offset(60, 158),
      const Offset(24, 162),
      const Offset(36, 126),
      const Offset(2, 112),
      const Offset(30, 88),
      const Offset(10, 56),
      const Offset(48, 56),
      const Offset(48, 18),
      const Offset(82, 36),
    ];

    Path buildPath(double dx, double dy) {
      final path = Path();
      for (int i = 0; i < rawPoints.length; i++) {
        final pt = Offset(rawPoints[i].dx * sx + dx, rawPoints[i].dy * sy + dy);
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();
      return path;
    }

    // 1. Draw black drop shadow
    final shadowPath = buildPath(5.0 * sx, 5.0 * sy);
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = OnboardingTokens.black
        ..style = PaintingStyle.fill,
    );

    // 2. Draw yellow fill
    final mainPath = buildPath(0, 0);
    canvas.drawPath(
      mainPath,
      Paint()
        ..color = OnboardingTokens.yellow
        ..style = PaintingStyle.fill,
    );

    // 3. Draw black stroke border
    canvas.drawPath(
      mainPath,
      Paint()
        ..color = OnboardingTokens.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5 * sx
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Sunburst rays and center orange sun for Slide 3 background.
class SunburstWidget extends StatelessWidget {
  final double size;

  const SunburstWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SunburstPainter()),
    );
  }
}

class _SunburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double sx = size.width / 200.0;
    final double sy = size.height / 200.0;

    final rayPaint = Paint()
      ..color = OnboardingTokens.yellow
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = OnboardingTokens.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * sx
      ..strokeJoin = StrokeJoin.round;

    final sunFill = Paint()
      ..color = OnboardingTokens.orange
      ..style = PaintingStyle.fill;

    final rays = [
      [const Offset(100, 100), const Offset(80, 0), const Offset(120, 0)],
      [const Offset(100, 100), const Offset(170, 14), const Offset(196, 44)],
      [const Offset(100, 100), const Offset(200, 76), const Offset(200, 118)],
      [const Offset(100, 100), const Offset(0, 76), const Offset(0, 118)],
      [const Offset(100, 100), const Offset(30, 14), const Offset(4, 44)],
    ];

    for (final ray in rays) {
      final path = Path()
        ..moveTo(ray[0].dx * sx, ray[0].dy * sy)
        ..lineTo(ray[1].dx * sx, ray[1].dy * sy)
        ..lineTo(ray[2].dx * sx, ray[2].dy * sy)
        ..close();

      canvas.drawPath(path, rayPaint);
      canvas.drawPath(path, strokePaint);
    }

    // Center sun
    final center = Offset(100 * sx, 100 * sy);
    final radius = 34 * sx;
    canvas.drawCircle(center, radius, sunFill);
    canvas.drawCircle(center, radius, strokePaint..strokeWidth = 3.5 * sx);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 4-point comic star confetti
class StarConfetti extends StatelessWidget {
  final double size;
  final double rotation;

  const StarConfetti({super.key, this.size = 28.0, this.rotation = 0.0});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _StarConfettiPainter()),
      ),
    );
  }
}

class _StarConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..quadraticBezierTo(w * 0.5, h * 0.5, w, h * 0.5)
      ..quadraticBezierTo(w * 0.5, h * 0.5, w * 0.5, h)
      ..quadraticBezierTo(w * 0.5, h * 0.5, 0, h * 0.5)
      ..quadraticBezierTo(w * 0.5, h * 0.5, w * 0.5, 0)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = OnboardingTokens.yellow
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = OnboardingTokens.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
