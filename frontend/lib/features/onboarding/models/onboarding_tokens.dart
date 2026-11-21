import 'package:flutter/material.dart';
import 'package:oopsieeats/core/neo_tokens.dart';

/// Design tokens for the NutriView Onboarding Carousel.
/// Strictly derived from the authoritative [NeoTokens] brand palette:
/// - [NeoTokens.primaryGreen] (`#16A34A`) — Primary brand color
/// - [NeoTokens.mintGreen] (`#CCFF00`) — Secondary brand & highlight
/// - [NeoTokens.vividYellow] (`#FFD600`) — High-impact CTA & visual accents
/// - [NeoTokens.orangeCarb] (`#FF6B00`) — Nutrition-related accents
/// - [NeoTokens.skyBlue] (`#1D4ED8`) & [NeoTokens.cyan] (`#06B6D4`) — Information accents
/// - [NeoTokens.lavender] (`#C4B5FD`) — Secondary decorative accents
/// - [NeoTokens.coralRed] (`#EF4444`) — Error and warning accents
/// - [NeoTokens.warmBackground] (`#FBF9F4`) — Main warm background
/// - [NeoTokens.white] (`#FFFFFF`) — Surface
/// - [NeoTokens.black] (`#111111`) — Outlines, typography, and hard shadows
class OnboardingTokens {
  OnboardingTokens._();

  // Official NutriView Brand Palette (Single Source of Truth from NeoTokens)
  static const Color primaryGreen = NeoTokens.primaryGreen;
  static const Color mintGreen = NeoTokens.mintGreen;
  static const Color vividYellow = NeoTokens.vividYellow;
  static const Color orangeCarb = NeoTokens.orangeCarb;
  static const Color skyBlue = NeoTokens.skyBlue;
  static const Color cyan = NeoTokens.cyan;
  static const Color lavender = NeoTokens.lavender;
  static const Color coralRed = NeoTokens.coralRed;
  static const Color warmBackground = NeoTokens.warmBackground;
  static const Color recess = NeoTokens.recess;
  static const Color white = NeoTokens.white;
  static const Color black = NeoTokens.black;

  // Semantic Aliases for Onboarding Slide Compositions
  static const Color green = NeoTokens.primaryGreen;
  static const Color mint = NeoTokens.mintGreen;
  static const Color lime = NeoTokens.mintGreen;
  static const Color yellow = NeoTokens.vividYellow;
  static const Color orange = NeoTokens.orangeCarb;
  static const Color blue = NeoTokens.skyBlue;
  static const Color purple = NeoTokens.lavender;
  static const Color coral = NeoTokens.coralRed;
  static const Color cream = NeoTokens.warmBackground;

  // Borders & Hard Shadows (Consistent with NeoTokens)
  static const double borderWidth = NeoTokens.borderWidthThick; // 2.8px
  static const double borderWidthThin = NeoTokens.borderWidth; // 2.0px
  static const double borderWidthThick = NeoTokens.borderWidthThick; // 2.8px

  static const Offset shadowOffset = NeoTokens.shadowOffsetMedium; // Offset(4, 4)
  static const Offset shadowOffsetSmall = NeoTokens.shadowOffset; // Offset(3, 3)
  static const Offset shadowOffsetLarge = NeoTokens.shadowOffsetLarge; // Offset(5, 5)
  static const double shadowBlur = NeoTokens.shadowBlurRadius; // 0.0

  // Radii (Consistent with NeoTokens)
  static const double radiusSmall = NeoTokens.radiusSmall; // 6.0
  static const double radiusMedium = NeoTokens.radiusMedium; // 10.0
  static const double radiusLarge = NeoTokens.radiusLarge; // 14.0
  static const double radiusPill = NeoTokens.radiusPill; // 999.0

  // Pre-configured Hard Shadows
  static const List<BoxShadow> hardShadow = [
    BoxShadow(
      color: NeoTokens.black,
      offset: NeoTokens.shadowOffsetMedium,
      blurRadius: NeoTokens.shadowBlurRadius,
    ),
  ];

  static const List<BoxShadow> hardShadowSmall = [
    BoxShadow(
      color: NeoTokens.black,
      offset: NeoTokens.shadowOffset,
      blurRadius: NeoTokens.shadowBlurRadius,
    ),
  ];

  static const List<BoxShadow> hardShadowLarge = [
    BoxShadow(
      color: NeoTokens.black,
      offset: NeoTokens.shadowOffsetLarge,
      blurRadius: NeoTokens.shadowBlurRadius,
    ),
  ];
}
