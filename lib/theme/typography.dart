import 'package:flutter/material.dart';
import 'package:luminalink/theme/colors.dart';

/// LuminaLink Typography System
///
/// Follows Material Design 3 typography scale with custom font choices
/// for a warm, approachable, and highly legible reading experience.
class LuminaTypography {
  LuminaTypography._();

  /// Base font family - San Francisco on iOS, Roboto on Android
  static const String fontFamily = 'Roboto';

  /// Alternative font family for emphasis (optional)
  static const String displayFontFamily = 'Roboto';

  // ============================================================================
  // LIGHT THEME TYPOGRAPHY
  // ============================================================================

  static TextTheme lightTextTheme = TextTheme(
    // Display styles - Used for large, impactful text
    displayLarge: TextStyle(
      fontFamily: displayFontFamily,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 64 / 57,
      color: LuminaColors.textPrimaryLight,
    ),
    displayMedium: TextStyle(
      fontFamily: displayFontFamily,
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 52 / 45,
      color: LuminaColors.textPrimaryLight,
    ),
    displaySmall: TextStyle(
      fontFamily: displayFontFamily,
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 44 / 36,
      color: LuminaColors.textPrimaryLight,
    ),

    // Headline styles - Section headers, card titles
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 40 / 32,
      color: LuminaColors.textPrimaryLight,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 36 / 28,
      color: LuminaColors.textPrimaryLight,
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 32 / 24,
      color: LuminaColors.textPrimaryLight,
    ),

    // Title styles - Prominent titles, app bar titles
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 28 / 22,
      color: LuminaColors.textPrimaryLight,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 24 / 16,
      color: LuminaColors.textPrimaryLight,
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 20 / 14,
      color: LuminaColors.textPrimaryLight,
    ),

    // Body styles - Main content text
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 24 / 16,
      color: LuminaColors.textPrimaryLight,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 20 / 14,
      color: LuminaColors.textPrimaryLight,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 16 / 12,
      color: LuminaColors.textSecondaryLight,
    ),

    // Label styles - Buttons, tabs, chips
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 20 / 14,
      color: LuminaColors.textPrimaryLight,
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 16 / 12,
      color: LuminaColors.textPrimaryLight,
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 16 / 11,
      color: LuminaColors.textSecondaryLight,
    ),
  );

  // ============================================================================
  // DARK THEME TYPOGRAPHY
  // ============================================================================

  static TextTheme darkTextTheme = TextTheme(
    // Display styles
    displayLarge: TextStyle(
      fontFamily: displayFontFamily,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 64 / 57,
      color: LuminaColors.textPrimaryDark,
    ),
    displayMedium: TextStyle(
      fontFamily: displayFontFamily,
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 52 / 45,
      color: LuminaColors.textPrimaryDark,
    ),
    displaySmall: TextStyle(
      fontFamily: displayFontFamily,
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 44 / 36,
      color: LuminaColors.textPrimaryDark,
    ),

    // Headline styles
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 40 / 32,
      color: LuminaColors.textPrimaryDark,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 36 / 28,
      color: LuminaColors.textPrimaryDark,
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 32 / 24,
      color: LuminaColors.textPrimaryDark,
    ),

    // Title styles
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 28 / 22,
      color: LuminaColors.textPrimaryDark,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 24 / 16,
      color: LuminaColors.textPrimaryDark,
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 20 / 14,
      color: LuminaColors.textPrimaryDark,
    ),

    // Body styles
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 24 / 16,
      color: LuminaColors.textPrimaryDark,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 20 / 14,
      color: LuminaColors.textPrimaryDark,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 16 / 12,
      color: LuminaColors.textSecondaryDark,
    ),

    // Label styles
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 20 / 14,
      color: LuminaColors.textPrimaryDark,
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 16 / 12,
      color: LuminaColors.textPrimaryDark,
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 16 / 11,
      color: LuminaColors.textSecondaryDark,
    ),
  );
}
