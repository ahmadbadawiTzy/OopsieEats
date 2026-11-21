import 'package:flutter/material.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/features/onboarding/models/onboarding_tokens.dart';

/// Editorial OopsieEats / NutriView brand badge with thick black border,
/// primaryGreen & mintGreen/vividYellow accents, and hard offset shadow.
class BrandBadge extends StatelessWidget {
  const BrandBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.045, // ~ -2.6 degrees editorial tilt
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: NeoTokens.black,
          borderRadius: BorderRadius.circular(NeoTokens.radiusPill),
          border: Border.all(
            color: NeoTokens.white,
            width: NeoTokens.borderWidth,
          ),
          boxShadow: const [
            BoxShadow(
              color: NeoTokens.vividYellow,
              offset: Offset(3.5, 3.5),
              blurRadius: NeoTokens.shadowBlurRadius,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8.0,
              height: 8.0,
              decoration: const BoxDecoration(
                color: OnboardingTokens.primaryGreen,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6.0),
            const Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                  height: 1.0,
                ),
                children: [
                  TextSpan(
                    text: 'Oopsie',
                    style: TextStyle(color: NeoTokens.mintGreen),
                  ),
                  TextSpan(
                    text: 'Eats',
                    style: TextStyle(color: NeoTokens.vividYellow),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
