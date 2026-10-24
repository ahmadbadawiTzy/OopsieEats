import 'package:flutter/material.dart';

/// Central design tokens for the NutriView Neo-Brutalism Design System.
/// Follows genuine Neo-Brutalist principles:
/// - Crisp, thick near-black borders (2.5px)
/// - Hard offset shadows without blur (Offset(4, 4))
/// - Flat, high-contrast surfaces (Warm off-white, Vivid Yellow, Mint Green, Coral, Sky Blue, Lilac)
/// - Expressive typography and tactile micro-interactions
class NeoTokens {
  NeoTokens._();

  // Backgrounds & Surfaces (Editorial Neo-Brutalism)
  static const Color canvas = Color(0xFFFBF9F4); // Warm editorial off-white
  static const Color paper = Color(0xFFFFFFFF); // Sterile white surface
  static const Color hud = Color(0xFF121212); // Deep dark HUD
  static const Color recess = Color(0xFFF0ECE1); // Recessed container
  static const Color surfaceDark = Color(0xFF181818);

  // Backward-compatible surface aliases
  static const Color warmBackground = canvas;
  static const Color darkBackground = hud;
  static const Color white = paper;
  static const Color surfaceMuted = recess;

  // Inks, Borders & Text
  static const Color ink = Color(
    0xFF111111,
  ); // Pitch black structural borders & text
  static const Color inkSecondary = Color(
    0xFF4A4A4A,
  ); // Sub-data and secondary copy
  static const Color inkMuted = Color(
    0xFF737373,
  ); // Telemetry microcopy and captions

  // Backward-compatible ink aliases
  static const Color black = ink;
  static const Color textDark = ink;
  static const Color textMuted = inkSecondary;
  static const Color textLight = inkMuted;

  // High-Voltage Brand & Nutrition Accents
  static const Color lime = Color(
    0xFFCCFF00,
  ); // Acid Lime (Hero energy, triggers)
  static const Color hazard = Color(
    0xFFFFD600,
  ); // Hazard Yellow (Highlights, date chips)
  static const Color cobalt = Color(
    0xFF1D4ED8,
  ); // Deep Cobalt (Protein, CTA, profile)
  static const Color alert = Color(0xFFEF4444); // Alert Red (Danger, delete)
  static const Color tangerine = Color(
    0xFFFF6B00,
  ); // Industrial Tangerine (Carbs)
  static const Color lilac = Color(0xFFC4B5FD); // Bio Lilac / Lavender (Fat)
  static const Color cyan = Color(0xFF06B6D4); // Cyan / Sky (Water, gallery)
  static const Color primaryGreen = Color(0xFF16A34A);

  // Backward-compatible accent aliases
  static const Color acidLime = lime;
  static const Color electricLime = lime;
  static const Color mintGreen = lime;
  static const Color vividYellow = hazard;
  static const Color hazardYellow = hazard;
  static const Color electricBlue = cobalt;
  static const Color cobaltBlue = cobalt;
  static const Color skyBlue = cobalt;
  static const Color coralRed = alert;
  static const Color alertRed = alert;
  static const Color orangeCarb = tangerine;
  static const Color lavender = lilac;

  // Border & Shadow Specs (Refined Neo-Brutalist Hierarchy)
  static const double borderWidth = 2.0;
  static const double borderWidthThin = 1.5;
  static const double borderWidthThick = 2.8;

  static const Offset shadowOffset = Offset(3, 3);
  static const Offset shadowOffsetSmall = Offset(2, 2);
  static const Offset shadowOffsetMedium = Offset(4, 4);
  static const Offset shadowOffsetLarge = Offset(5, 5);
  static const Offset shadowOffsetPressed = Offset(1, 1);

  static const double shadowBlurRadius = 0.0;

  // Radii
  static const double radiusSharp = 0.0;
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 10.0;
  static const double radiusLarge = 14.0;
  static const double radiusPill = 999.0;

  // BoxShadow Generators
  static List<BoxShadow> neoBoxShadow({
    Offset offset = shadowOffset,
    Color color = ink,
  }) => [BoxShadow(color: color, offset: offset, blurRadius: shadowBlurRadius)];

  static List<BoxShadow> neoBoxShadowSmall({Color color = ink}) =>
      neoBoxShadow(offset: shadowOffsetSmall, color: color);

  static List<BoxShadow> neoBoxShadowMedium({Color color = ink}) =>
      neoBoxShadow(offset: shadowOffsetMedium, color: color);

  static List<BoxShadow> neoBoxShadowLarge({Color color = ink}) =>
      neoBoxShadow(offset: shadowOffsetLarge, color: color);

  static List<BoxShadow> neoBoxShadowPressed({Color color = ink}) =>
      neoBoxShadow(offset: shadowOffsetPressed, color: color);

  // Border Generator
  static Border neoBorder({Color color = ink, double width = borderWidth}) =>
      Border.all(color: color, width: width);

  // Spacing System (8-point grid & half steps)
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space56 = 56.0;
  static const double space64 = 64.0;
}
