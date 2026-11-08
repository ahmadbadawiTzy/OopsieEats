import 'package:flutter/material.dart';

/// Design tokens specifically tailored for NutriView Onboarding Redesign.
/// Perfectly synced with `docs/onboarding_redesign/onboarding_preview.html`.
class OnboardingTokens {
  OnboardingTokens._();

  // Core Neo-Brutalist Palette
  static const Color green = Color(0xFF17C964); // Slide 1 canvas & active dot
  static const Color mint = Color(0xFFB9F3D2); // Slide 3 canvas & highlight
  static const Color yellow = Color(0xFFFFD23F); // Slide 2 canvas & CTA button
  static const Color orange = Color(0xFFFF7A1A); // Final CTA & accent
  static const Color cream = Color(
    0xFFFFF5DF,
  ); // Bottom torn paper card surface
  static const Color white = Color(0xFFFFFFFF); // Clean white elements
  static const Color black = Color(0xFF0A0A0A); // High-contrast structural ink
  static const Color pink = Color(0xFFFFB3C1); // Energy callout chip

  // Border & Shadow metrics
  static const double borderWidth = 2.5;
  static const double borderWidthThin = 1.8;
  static const Offset shadowOffset = Offset(3.5, 3.5);
  static const Offset shadowOffsetSmall = Offset(2.0, 2.0);
  static const Offset shadowOffsetLarge = Offset(5.0, 5.0);

  // Reusable Shadow Generator
  static List<BoxShadow> neoShadow([
    Offset offset = shadowOffset,
    Color color = black,
  ]) => [BoxShadow(color: color, offset: offset, blurRadius: 0.0)];

  // Reusable Border Generator
  static Border neoBorder([double width = borderWidth, Color color = black]) =>
      Border.all(color: color, width: width);
}
