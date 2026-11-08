import 'package:flutter/material.dart';
import 'package:oopsieeats/features/onboarding/models/onboarding_tokens.dart';

/// Polaroid-style callout card used on Slide 2 for nutrient breakdown.
class NutritionCalloutCard extends StatelessWidget {
  final String tag;
  final Color tagColor;
  final String foodName;
  final String imagePath;
  final double width;
  final double rotation;

  const NutritionCalloutCard({
    super.key,
    required this.tag,
    required this.tagColor,
    required this.foodName,
    required this.imagePath,
    this.width = 95.0,
    this.rotation = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: OnboardingTokens.white,
          border: Border.all(
            color: OnboardingTokens.black,
            width: OnboardingTokens.borderWidthThin,
          ),
          boxShadow: const [
            BoxShadow(
              color: OnboardingTokens.black,
              offset: Offset(3.0, 3.0),
              blurRadius: 0.0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Tag Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 2.5,
              ),
              decoration: BoxDecoration(
                color: tagColor,
                border: const Border(
                  bottom: BorderSide(
                    color: OnboardingTokens.black,
                    width: OnboardingTokens.borderWidthThin,
                  ),
                ),
              ),
              child: Text(
                tag,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: OnboardingTokens.black,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ),

            // 2. Image container with focus corners
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                height: width * 0.55,
                decoration: BoxDecoration(
                  color: OnboardingTokens.cream,
                  border: Border.all(color: OnboardingTokens.black, width: 1.0),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Corner focus ticks
                    const Positioned(
                      top: 2,
                      left: 2,
                      child: _FocusCorner(isTop: true, isLeft: true),
                    ),
                    const Positioned(
                      top: 2,
                      right: 2,
                      child: _FocusCorner(isTop: true, isLeft: false),
                    ),
                    const Positioned(
                      bottom: 2,
                      left: 2,
                      child: _FocusCorner(isTop: false, isLeft: true),
                    ),
                    const Positioned(
                      bottom: 2,
                      right: 2,
                      child: _FocusCorner(isTop: false, isLeft: false),
                    ),

                    // Food image
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Image.asset(imagePath, fit: BoxFit.contain),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Food Name
            Padding(
              padding: const EdgeInsets.only(
                left: 4.0,
                right: 4.0,
                bottom: 4.0,
              ),
              child: Text(
                foodName,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: OnboardingTokens.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusCorner extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const _FocusCorner({required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    const size = 5.0;
    const thickness = 1.4;
    const color = OnboardingTokens.black;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: 0,
            right: 0,
            child: Container(height: thickness, color: color),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(width: thickness, color: color),
          ),
        ],
      ),
    );
  }
}
