import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';

/// Production Neo-Brutalism Consumer Brand Logo Mark for NutriView.
/// Features a single, bold, iconic nutrition Apple with thick ink borders,
/// rich leaf green accent, warm canvas contrast, and crisp offset drop shadow.
class NutriViewLogoMark extends StatelessWidget {
  final double size;
  final double leafAngle; // In radians, for gentle secondary motion

  const NutriViewLogoMark({super.key, this.size = 120.0, this.leafAngle = 0.0});

  @override
  Widget build(BuildContext context) {
    // Content canonical aspect ratio: 276.0w x 272.0h
    final height = size * (272.0 / 276.0);
    return SizedBox(
      width: size,
      height: height,
      child: CustomPaint(
        size: Size(size, height),
        painter: _AppleLogoPainter(leafAngle: leafAngle),
      ),
    );
  }
}

/// Backwards-compatible alias for existing imports and test references.
typedef NeoSplashBadge = NutriViewLogoMark;

class _AppleLogoPainter extends CustomPainter {
  final double leafAngle;

  const _AppleLogoPainter({this.leafAngle = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Fit drawing tightly into widget size
    // Canonical bounds: X [118..394] (width: 276), Y [114..386] (height: 272)
    const contentWidth = 276.0;
    const contentHeight = 272.0;
    const contentLeft = 118.0;
    const contentTop = 114.0;

    final scale = math.min(
      size.width / contentWidth,
      size.height / contentHeight,
    );
    final dx = (size.width - contentWidth * scale) / 2.0 - contentLeft * scale;
    final dy = (size.height - contentHeight * scale) / 2.0 - contentTop * scale;

    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    const cx = 251.0;
    const cy = 271.0;
    const r = 106.0;

    const strokeWidth = 12.0;
    const shadowOffset = 10.0;

    final inkPaint = Paint()
      ..color = NeoTokens.ink
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = NeoTokens.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final appleBodyPaint = Paint()
      ..color = NeoTokens.lime
      ..style = PaintingStyle.fill;

    final leafBodyPaint = Paint()
      ..color = const Color(0xFF16A34A)
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.85
      ..strokeCap = StrokeCap.round;

    // --- 1. Apple Body Path ---
    const topNotch = Offset(cx, cy - r * 0.65);
    const pTlCrest = Offset(cx - r * 0.60, cy - r * 0.95);
    const pMlCheek = Offset(cx - r * 1.05, cy - r * 0.15);
    const pBlWaist = Offset(cx - r * 0.85, cy + r * 0.60);
    const pBlLobe = Offset(cx - r * 0.35, cy + r * 0.96);
    const bottomNotch = Offset(cx, cy + r * 0.82);
    const pBrLobe = Offset(cx + r * 0.35, cy + r * 0.96);
    const pMrWaist = Offset(cx + r * 0.85, cy + r * 0.60);
    const pMrCheek = Offset(cx + r * 1.05, cy - r * 0.15);
    const pTrCrest = Offset(cx + r * 0.60, cy - r * 0.95);

    final applePath = Path();
    applePath.moveTo(topNotch.dx, topNotch.dy);
    applePath.cubicTo(
      cx - r * 0.20,
      cy - r * 0.90,
      cx - r * 0.45,
      cy - r * 0.98,
      pTlCrest.dx,
      pTlCrest.dy,
    );
    applePath.cubicTo(
      cx - r * 0.85,
      cy - r * 0.90,
      cx - r * 1.05,
      cy - r * 0.60,
      pMlCheek.dx,
      pMlCheek.dy,
    );
    applePath.cubicTo(
      cx - r * 1.05,
      cy + r * 0.25,
      cx - r * 0.95,
      cy + r * 0.40,
      pBlWaist.dx,
      pBlWaist.dy,
    );
    applePath.cubicTo(
      cx - r * 0.75,
      cy + r * 0.82,
      cx - r * 0.55,
      cy + r * 0.96,
      pBlLobe.dx,
      pBlLobe.dy,
    );
    applePath.cubicTo(
      cx - r * 0.20,
      cy + r * 0.96,
      cx - r * 0.08,
      cy + r * 0.84,
      bottomNotch.dx,
      bottomNotch.dy,
    );
    applePath.cubicTo(
      cx + r * 0.08,
      cy + r * 0.84,
      cx + r * 0.20,
      cy + r * 0.96,
      pBrLobe.dx,
      pBrLobe.dy,
    );
    applePath.cubicTo(
      cx + r * 0.55,
      cy + r * 0.96,
      cx + r * 0.75,
      cy + r * 0.82,
      pMrWaist.dx,
      pMrWaist.dy,
    );
    applePath.cubicTo(
      cx + r * 0.95,
      cy + r * 0.40,
      cx + r * 1.05,
      cy + r * 0.25,
      pMrCheek.dx,
      pMrCheek.dy,
    );
    applePath.cubicTo(
      cx + r * 1.05,
      cy - r * 0.60,
      cx + r * 0.85,
      cy - r * 0.90,
      pTrCrest.dx,
      pTrCrest.dy,
    );
    applePath.cubicTo(
      cx + r * 0.45,
      cy - r * 0.98,
      cx + r * 0.20,
      cy - r * 0.90,
      topNotch.dx,
      topNotch.dy,
    );
    applePath.close();

    // --- 2. Stem Path ---
    const stemBase = Offset(cx - r * 0.02, cy - r * 0.62);
    const stemTip = Offset(cx - r * 0.18, cy - r * 1.25);
    final stemPath = Path();
    stemPath.moveTo(stemBase.dx, stemBase.dy);
    stemPath.cubicTo(
      cx - r * 0.10,
      cy - r * 0.95,
      cx - r * 0.22,
      cy - r * 1.15,
      stemTip.dx,
      stemTip.dy,
    );

    // --- 3. Leaf Path ---
    const leafBase = Offset(cx + r * 0.05, cy - r * 0.72);
    const leafTip = Offset(cx + r * 0.78, cy - r * 1.25);
    final leafPath = Path();
    leafPath.moveTo(leafBase.dx, leafBase.dy);
    leafPath.cubicTo(
      cx + r * 0.16,
      cy - r * 1.20,
      cx + r * 0.48,
      cy - r * 1.38,
      leafTip.dx,
      leafTip.dy,
    );
    leafPath.cubicTo(
      cx + r * 0.65,
      cy - r * 0.90,
      cx + r * 0.32,
      cy - r * 0.68,
      leafBase.dx,
      leafBase.dy,
    );
    leafPath.close();

    // Secondary animation transform on leaf
    Path effectiveLeafPath = leafPath;
    if (leafAngle != 0.0) {
      final matrix = Matrix4.identity()
        ..multiply(Matrix4.translationValues(leafBase.dx, leafBase.dy, 0.0))
        ..rotateZ(leafAngle)
        ..multiply(Matrix4.translationValues(-leafBase.dx, -leafBase.dy, 0.0));
      effectiveLeafPath = leafPath.transform(matrix.storage);
    }

    // --- HARD OFFSET DROP SHADOW (+shadowOffset, +shadowOffset) ---
    final shadowTransform = Matrix4.translationValues(
      shadowOffset,
      shadowOffset,
      0,
    );
    final appleShadow = applePath.transform(shadowTransform.storage);
    final leafShadow = effectiveLeafPath.transform(shadowTransform.storage);
    final stemShadow = stemPath.transform(shadowTransform.storage);

    canvas.drawPath(stemShadow, strokePaint..strokeWidth = strokeWidth * 1.2);
    canvas.drawPath(leafShadow, inkPaint);
    canvas.drawPath(appleShadow, inkPaint);

    // --- FOREGROUND ELEMENTS ---
    // Stem
    strokePaint.strokeWidth = strokeWidth * 1.2;
    canvas.drawPath(stemPath, strokePaint);

    // Leaf body & outline
    canvas.drawPath(effectiveLeafPath, leafBodyPaint);
    strokePaint.strokeWidth = strokeWidth;
    canvas.drawPath(effectiveLeafPath, strokePaint);

    // Apple body & outline
    canvas.drawPath(applePath, appleBodyPaint);
    canvas.drawPath(applePath, strokePaint);

    // Graphic Highlight Arc on upper left cheek
    final highlightPath = Path();
    highlightPath.moveTo(cx - r * 0.55, cy - r * 0.55);
    highlightPath.cubicTo(
      cx - r * 0.82,
      cy - r * 0.28,
      cx - r * 0.82,
      cy + r * 0.12,
      cx - r * 0.60,
      cy + r * 0.40,
    );
    canvas.drawPath(highlightPath, highlightPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AppleLogoPainter oldDelegate) {
    return oldDelegate.leafAngle != leafAngle;
  }
}
