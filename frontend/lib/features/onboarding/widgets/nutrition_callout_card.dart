import 'package:flutter/material.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/features/onboarding/models/onboarding_tokens.dart';

/// Neo-Brutalist nutrition specimen callout card used on Slide 2.
/// Features a colored header tag, inner specimen box with corner bracket ticks,
/// crisp food image, bold label, and optional macro telemetry pill.
class NutritionCalloutCard extends StatelessWidget {
  final String tag;
  final Color tagColor;
  final Color tagTextColor;
  final String foodName;
  final String imageAsset;
  final double rotation;
  final String? macroValue;
  final Color? macroPillColor;

  const NutritionCalloutCard({
    super.key,
    required this.tag,
    required this.tagColor,
    this.tagTextColor = NeoTokens.black,
    required this.foodName,
    required this.imageAsset,
    this.rotation = 0.0,
    this.macroValue,
    this.macroPillColor,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        decoration: BoxDecoration(
          color: NeoTokens.white,
          borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colored Header Tag
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 3.5,
                horizontal: 4.0,
              ),
              decoration: BoxDecoration(
                color: tagColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3.5),
                ),
                border: const Border(
                  bottom: BorderSide(
                    color: NeoTokens.black,
                    width: OnboardingTokens.borderWidthThin,
                  ),
                ),
              ),
              child: Text(
                tag,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: tagTextColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  height: 1.1,
                ),
              ),
            ),

            // Specimen Content
            Padding(
              padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Inner bordered specimen frame with corner ticks
                  Container(
                    height: 44.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: NeoTokens.warmBackground,
                      borderRadius: BorderRadius.circular(3.0),
                      border: Border.all(
                        color: NeoTokens.black,
                        width: NeoTokens.borderWidthThin,
                      ),
                    ),
                    child: CustomPaint(
                      painter: _CornerTicksPainter(),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Image.asset(
                          imageAsset,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    foodName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: NeoTokens.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                      height: 1.1,
                    ),
                  ),
                  if (macroValue != null) ...[
                    const SizedBox(height: 2.5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: macroPillColor ?? NeoTokens.mintGreen,
                        borderRadius: BorderRadius.circular(3.0),
                        border: Border.all(
                          color: NeoTokens.black,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        macroValue!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: NeoTokens.black,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerTicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NeoTokens.black
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const double pad = 3.0;
    const double len = 4.0;

    // Top-left
    canvas.drawLine(
      const Offset(pad, pad),
      const Offset(pad + len, pad),
      paint,
    );
    canvas.drawLine(
      const Offset(pad, pad),
      const Offset(pad, pad + len),
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(size.width - pad, pad),
      Offset(size.width - pad - len, pad),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - pad, pad),
      Offset(size.width - pad, pad + len),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(pad, size.height - pad),
      Offset(pad + len, size.height - pad),
      paint,
    );
    canvas.drawLine(
      Offset(pad, size.height - pad),
      Offset(pad, size.height - pad - len),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - pad, size.height - pad),
      Offset(size.width - pad - len, size.height - pad),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - pad, size.height - pad),
      Offset(size.width - pad, size.height - pad - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
