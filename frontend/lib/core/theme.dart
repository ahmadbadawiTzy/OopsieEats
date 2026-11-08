import 'package:flutter/material.dart';
import 'package:oopsieeats/core/neo_tokens.dart';

/// AppTheme configuration for NutriView.
/// Re-engineered with authentic Neo-Brutalism design system foundations:
/// - Crisp thick borders (2.5px)
/// - Hard offset shadows without blur (Offset(4, 4))
/// - Punchy high-contrast surfaces
/// - Preserves backward-compatible color constants for existing features and tests.
class AppTheme {
  // Brand Colors (Neo-Brutalist Tuned)
  static const Color primaryGreen = NeoTokens.primaryGreen;
  static const Color primaryGreenLight = NeoTokens.mintGreen;
  static const Color primaryGreenDark = Color(0xFF0F5132);
  static const Color secondaryGreen = Color(0xFF16A34A);

  // Status & Accent Colors
  static const Color accentOrange = NeoTokens.orangeCarb;
  static const Color accentOrangeLight = Color(0xFFFFF3CD);
  static const Color accentBlue = NeoTokens.skyBlue;
  static const Color accentBlueLight = Color(0xFFE0F2FE);
  static const Color accentPurple = NeoTokens.lavender;
  static const Color accentPurpleLight = Color(0xFFF3E8FF);
  static const Color errorRed = NeoTokens.coralRed;
  static const Color errorRedLight = Color(0xFFFFE5E5);

  // Neutral Colors
  static const Color backgroundLight = NeoTokens.warmBackground;
  static const Color surfaceWhite = NeoTokens.white;
  static const Color borderSubtle = NeoTokens.black;
  static const Color borderMedium = NeoTokens.black;
  static const Color textDark = NeoTokens.textDark;
  static const Color textMuted = NeoTokens.textMuted;
  static const Color textLight = NeoTokens.textLight;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      canvasColor: NeoTokens.white,
      cardColor: NeoTokens.white,
      scaffoldBackgroundColor: NeoTokens.warmBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: NeoTokens.primaryGreen,
        brightness: Brightness.light,
        primary: NeoTokens.primaryGreen,
        onPrimary: NeoTokens.white,
        primaryContainer: NeoTokens.mintGreen,
        onPrimaryContainer: NeoTokens.black,
        secondary: NeoTokens.vividYellow,
        onSecondary: NeoTokens.black,
        surface: NeoTokens.white,
        onSurface: NeoTokens.black,
        error: NeoTokens.coralRed,
        onError: NeoTokens.white,
        errorContainer: errorRedLight,
        onErrorContainer: NeoTokens.black,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: NeoTokens.white,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
          side: const BorderSide(
            color: NeoTokens.black,
            width: NeoTokens.borderWidth,
          ),
        ),
        textStyle: const TextStyle(
          color: NeoTokens.black,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: NeoTokens.warmBackground,
        foregroundColor: NeoTokens.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: NeoTokens.black,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: NeoTokens.black, size: 24),
      ),
      cardTheme: CardThemeData(
        color: NeoTokens.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
          side: const BorderSide(
            color: NeoTokens.black,
            width: NeoTokens.borderWidth,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NeoTokens.vividYellow,
          foregroundColor: NeoTokens.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
            side: const BorderSide(
              color: NeoTokens.black,
              width: NeoTokens.borderWidth,
            ),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NeoTokens.black,
          backgroundColor: NeoTokens.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          side: const BorderSide(
            color: NeoTokens.black,
            width: NeoTokens.borderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NeoTokens.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          color: NeoTokens.textLight,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
          borderSide: const BorderSide(
            color: NeoTokens.black,
            width: NeoTokens.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
          borderSide: const BorderSide(
            color: NeoTokens.black,
            width: NeoTokens.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
          borderSide: const BorderSide(
            color: NeoTokens.black,
            width: NeoTokens.borderWidthThick,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
          borderSide: const BorderSide(
            color: NeoTokens.coralRed,
            width: NeoTokens.borderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
          borderSide: const BorderSide(
            color: NeoTokens.coralRed,
            width: NeoTokens.borderWidthThick,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: NeoTokens.black,
        thickness: 2,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: NeoTokens.warmBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoTokens.radiusLarge),
          side: const BorderSide(
            color: NeoTokens.black,
            width: NeoTokens.borderWidth,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: NeoTokens.warmBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(NeoTokens.radiusLarge),
          ),
          side: BorderSide(
            color: NeoTokens.black,
            width: NeoTokens.borderWidth,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NeoTokens.darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: NeoTokens.mintGreen,
        brightness: Brightness.dark,
        primary: NeoTokens.mintGreen,
        onPrimary: NeoTokens.black,
        surface: NeoTokens.surfaceDark,
        onSurface: NeoTokens.white,
        error: NeoTokens.coralRed,
        onError: NeoTokens.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: NeoTokens.darkBackground,
        foregroundColor: NeoTokens.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: NeoTokens.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: NeoTokens.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
          side: const BorderSide(
            color: NeoTokens.white,
            width: NeoTokens.borderWidth,
          ),
        ),
      ),
    );
  }
}
