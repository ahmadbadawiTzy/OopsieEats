import 'package:flutter/material.dart';
import 'package:oopsieeats/features/onboarding/models/onboarding_tokens.dart';

/// Editorial NutriView brand badge with black pill, green wordmark,
/// white secondary, and clean offset shadow rotated -3 degrees.
class BrandBadge extends StatelessWidget {
  const BrandBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.052, // approx -3 degrees
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: OnboardingTokens.black,
          borderRadius: BorderRadius.circular(999.0),
          boxShadow: const [
            BoxShadow(
              color: OnboardingTokens.white,
              offset: Offset(3.0, 3.0),
              blurRadius: 0.0,
            ),
          ],
        ),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
              height: 1.0,
            ),
            children: [
              TextSpan(
                text: 'Oopsie',
                style: TextStyle(color: OnboardingTokens.green),
              ),
              TextSpan(
                text: 'Eats',
                style: TextStyle(color: OnboardingTokens.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
