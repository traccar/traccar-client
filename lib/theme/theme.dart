import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luminalink/theme/colors.dart';
import 'package:luminalink/theme/typography.dart';
import 'package:luminalink/theme/spacing.dart';

/// LuminaLink Theme System
///
/// Provides platform-adaptive theming that respects Material Design 3 on Android
/// and Apple's Human Interface Guidelines on iOS.
class LuminaTheme {
  LuminaTheme._();

  // ============================================================================
  // MATERIAL THEME (Android)
  // ============================================================================

  /// Light theme for Material Design (Android)
  static ThemeData lightTheme() {
    final ColorScheme colorScheme = ColorScheme.light(
      // Primary colors
      primary: LuminaColors.primaryLight,
      onPrimary: LuminaColors.onPrimaryLight,
      primaryContainer: LuminaColors.primaryContainerLight,
      onPrimaryContainer: LuminaColors.textPrimaryLight,

      // Secondary colors
      secondary: LuminaColors.secondaryLight,
      onSecondary: LuminaColors.onSecondaryLight,
      secondaryContainer: LuminaColors.secondaryContainerLight,
      onSecondaryContainer: LuminaColors.textPrimaryLight,

      // Tertiary colors
      tertiary: LuminaColors.tertiaryLight,
      onTertiary: Colors.white,
      tertiaryContainer: LuminaColors.tertiaryContainerLight,
      onTertiaryContainer: LuminaColors.textPrimaryLight,

      // Error colors
      error: LuminaColors.errorLight,
      onError: Colors.white,
      errorContainer: LuminaColors.errorContainerLight,
      onErrorContainer: LuminaColors.textPrimaryLight,

      // Surface colors
      surface: LuminaColors.surfaceLight,
      onSurface: LuminaColors.textPrimaryLight,
      surfaceContainerHighest: LuminaColors.surfaceVariantLight,
      onSurfaceVariant: LuminaColors.textSecondaryLight,

      // Background colors
      // Note: background is deprecated in Material 3, using surface instead
      // But we keep it for compatibility
      // ignore: deprecated_member_use
      background: LuminaColors.backgroundLight,
      // ignore: deprecated_member_use
      onBackground: LuminaColors.textPrimaryLight,

      // Outline
      outline: LuminaColors.borderLight,
      outlineVariant: LuminaColors.dividerLight,

      // Shadow
      shadow: LuminaColors.shadowLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: LuminaTypography.lightTextTheme,
      scaffoldBackgroundColor: LuminaColors.backgroundLight,
      fontFamily: LuminaTypography.fontFamily,

      // AppBar theme
      appBarTheme: AppBarTheme(
        centerTitle: false, // Android style (left-aligned)
        elevation: 0,
        scrolledUnderElevation: LuminaSpacing.elevationXs,
        backgroundColor: LuminaColors.surfaceLight,
        foregroundColor: LuminaColors.textPrimaryLight,
        titleTextStyle: LuminaTypography.lightTextTheme.titleLarge,
        iconTheme: IconThemeData(
          color: LuminaColors.textPrimaryLight,
          size: LuminaSpacing.iconMd,
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        elevation: LuminaSpacing.elevationSm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
        ),
        color: LuminaColors.surfaceLight,
        margin: EdgeInsets.all(LuminaSpacing.xs),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: LuminaSpacing.elevationSm,
          padding: EdgeInsets.symmetric(
            horizontal: LuminaSpacing.lg,
            vertical: LuminaSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
          ),
          minimumSize: Size(0, LuminaSpacing.buttonHeightMd),
          textStyle: LuminaTypography.lightTextTheme.labelLarge,
        ),
      ),

      // Filled button theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: LuminaSpacing.lg,
            vertical: LuminaSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
          ),
          minimumSize: Size(0, LuminaSpacing.buttonHeightMd),
          textStyle: LuminaTypography.lightTextTheme.labelLarge,
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: LuminaSpacing.lg,
            vertical: LuminaSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
          ),
          side: BorderSide(
            color: LuminaColors.borderLight,
            width: LuminaSpacing.borderWidthThin,
          ),
          minimumSize: Size(0, LuminaSpacing.buttonHeightMd),
          textStyle: LuminaTypography.lightTextTheme.labelLarge,
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: LuminaSpacing.md,
            vertical: LuminaSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
          ),
          textStyle: LuminaTypography.lightTextTheme.labelLarge,
        ),
      ),

      // Floating Action Button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: LuminaSpacing.elevationLg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusLg),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LuminaColors.surfaceVariantLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
          borderSide: BorderSide(
            color: LuminaColors.borderLight,
            width: LuminaSpacing.borderWidthThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
          borderSide: BorderSide(
            color: LuminaColors.borderLight,
            width: LuminaSpacing.borderWidthThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
          borderSide: BorderSide(
            color: LuminaColors.primaryLight,
            width: LuminaSpacing.borderWidthThick,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
          borderSide: BorderSide(
            color: LuminaColors.errorLight,
            width: LuminaSpacing.borderWidthThin,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
          borderSide: BorderSide(
            color: LuminaColors.errorLight,
            width: LuminaSpacing.borderWidthThick,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: LuminaSpacing.md,
          vertical: LuminaSpacing.sm,
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: LuminaColors.surfaceVariantLight,
        deleteIconColor: LuminaColors.textSecondaryLight,
        disabledColor: LuminaColors.textDisabledLight,
        selectedColor: LuminaColors.primaryContainerLight,
        secondarySelectedColor: LuminaColors.secondaryContainerLight,
        padding: EdgeInsets.symmetric(
          horizontal: LuminaSpacing.sm,
          vertical: LuminaSpacing.xs,
        ),
        labelStyle: LuminaTypography.lightTextTheme.labelMedium,
        secondaryLabelStyle: LuminaTypography.lightTextTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusSm),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        elevation: LuminaSpacing.elevationXl,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusLg),
        ),
        backgroundColor: LuminaColors.surfaceLight,
        titleTextStyle: LuminaTypography.lightTextTheme.headlineSmall,
        contentTextStyle: LuminaTypography.lightTextTheme.bodyMedium,
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        elevation: LuminaSpacing.elevationXl,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(LuminaSpacing.radiusLg),
          ),
        ),
        backgroundColor: LuminaColors.surfaceLight,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: LuminaColors.dividerLight,
        thickness: LuminaSpacing.borderWidthHairline,
        space: LuminaSpacing.xs,
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: LuminaSpacing.md,
          vertical: LuminaSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusSm),
        ),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return LuminaColors.onPrimaryLight;
          }
          return LuminaColors.textDisabledLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return LuminaColors.primaryLight;
          }
          return LuminaColors.borderLight;
        }),
      ),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: LuminaColors.primaryLight,
        linearTrackColor: LuminaColors.primaryContainerLight,
        circularTrackColor: LuminaColors.primaryContainerLight,
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: LuminaColors.textPrimaryLight,
        contentTextStyle: LuminaTypography.darkTextTheme.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusSm),
        ),
      ),
    );
  }

  /// Dark theme for Material Design (Android)
  static ThemeData darkTheme() {
    final ColorScheme colorScheme = ColorScheme.dark(
      // Primary colors
      primary: LuminaColors.primaryDark,
      onPrimary: LuminaColors.onPrimaryDark,
      primaryContainer: LuminaColors.primaryContainerDark,
      onPrimaryContainer: LuminaColors.textPrimaryDark,

      // Secondary colors
      secondary: LuminaColors.secondaryDark,
      onSecondary: LuminaColors.onSecondaryDark,
      secondaryContainer: LuminaColors.secondaryContainerDark,
      onSecondaryContainer: LuminaColors.textPrimaryDark,

      // Tertiary colors
      tertiary: LuminaColors.tertiaryDark,
      onTertiary: Colors.black,
      tertiaryContainer: LuminaColors.tertiaryContainerDark,
      onTertiaryContainer: LuminaColors.textPrimaryDark,

      // Error colors
      error: LuminaColors.errorDark,
      onError: Colors.black,
      errorContainer: LuminaColors.errorContainerDark,
      onErrorContainer: LuminaColors.textPrimaryDark,

      // Surface colors
      surface: LuminaColors.surfaceDark,
      onSurface: LuminaColors.textPrimaryDark,
      surfaceContainerHighest: LuminaColors.surfaceVariantDark,
      onSurfaceVariant: LuminaColors.textSecondaryDark,

      // Background colors
      // ignore: deprecated_member_use
      background: LuminaColors.backgroundDark,
      // ignore: deprecated_member_use
      onBackground: LuminaColors.textPrimaryDark,

      // Outline
      outline: LuminaColors.borderDark,
      outlineVariant: LuminaColors.dividerDark,

      // Shadow
      shadow: LuminaColors.shadowDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: LuminaTypography.darkTextTheme,
      scaffoldBackgroundColor: LuminaColors.backgroundDark,
      fontFamily: LuminaTypography.fontFamily,

      // AppBar theme
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: LuminaSpacing.elevationXs,
        backgroundColor: LuminaColors.surfaceDark,
        foregroundColor: LuminaColors.textPrimaryDark,
        titleTextStyle: LuminaTypography.darkTextTheme.titleLarge,
        iconTheme: IconThemeData(
          color: LuminaColors.textPrimaryDark,
          size: LuminaSpacing.iconMd,
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        elevation: LuminaSpacing.elevationSm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
        ),
        color: LuminaColors.surfaceDark,
        margin: EdgeInsets.all(LuminaSpacing.xs),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: LuminaSpacing.elevationSm,
          padding: EdgeInsets.symmetric(
            horizontal: LuminaSpacing.lg,
            vertical: LuminaSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
          ),
          minimumSize: Size(0, LuminaSpacing.buttonHeightMd),
          textStyle: LuminaTypography.darkTextTheme.labelLarge,
        ),
      ),

      // Filled button theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: LuminaSpacing.lg,
            vertical: LuminaSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
          ),
          minimumSize: Size(0, LuminaSpacing.buttonHeightMd),
          textStyle: LuminaTypography.darkTextTheme.labelLarge,
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: LuminaSpacing.lg,
            vertical: LuminaSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
          ),
          side: BorderSide(
            color: LuminaColors.borderDark,
            width: LuminaSpacing.borderWidthThin,
          ),
          minimumSize: Size(0, LuminaSpacing.buttonHeightMd),
          textStyle: LuminaTypography.darkTextTheme.labelLarge,
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: LuminaSpacing.md,
            vertical: LuminaSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
          ),
          textStyle: LuminaTypography.darkTextTheme.labelLarge,
        ),
      ),

      // Floating Action Button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: LuminaSpacing.elevationLg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusLg),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LuminaColors.surfaceVariantDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
          borderSide: BorderSide(
            color: LuminaColors.borderDark,
            width: LuminaSpacing.borderWidthThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
          borderSide: BorderSide(
            color: LuminaColors.borderDark,
            width: LuminaSpacing.borderWidthThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
          borderSide: BorderSide(
            color: LuminaColors.primaryDark,
            width: LuminaSpacing.borderWidthThick,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
          borderSide: BorderSide(
            color: LuminaColors.errorDark,
            width: LuminaSpacing.borderWidthThin,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
          borderSide: BorderSide(
            color: LuminaColors.errorDark,
            width: LuminaSpacing.borderWidthThick,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: LuminaSpacing.md,
          vertical: LuminaSpacing.sm,
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: LuminaColors.surfaceVariantDark,
        deleteIconColor: LuminaColors.textSecondaryDark,
        disabledColor: LuminaColors.textDisabledDark,
        selectedColor: LuminaColors.primaryContainerDark,
        secondarySelectedColor: LuminaColors.secondaryContainerDark,
        padding: EdgeInsets.symmetric(
          horizontal: LuminaSpacing.sm,
          vertical: LuminaSpacing.xs,
        ),
        labelStyle: LuminaTypography.darkTextTheme.labelMedium,
        secondaryLabelStyle: LuminaTypography.darkTextTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusSm),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        elevation: LuminaSpacing.elevationXl,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusLg),
        ),
        backgroundColor: LuminaColors.surfaceDark,
        titleTextStyle: LuminaTypography.darkTextTheme.headlineSmall,
        contentTextStyle: LuminaTypography.darkTextTheme.bodyMedium,
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        elevation: LuminaSpacing.elevationXl,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(LuminaSpacing.radiusLg),
          ),
        ),
        backgroundColor: LuminaColors.surfaceDark,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: LuminaColors.dividerDark,
        thickness: LuminaSpacing.borderWidthHairline,
        space: LuminaSpacing.xs,
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: LuminaSpacing.md,
          vertical: LuminaSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusSm),
        ),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return LuminaColors.onPrimaryDark;
          }
          return LuminaColors.textDisabledDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return LuminaColors.primaryDark;
          }
          return LuminaColors.borderDark;
        }),
      ),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: LuminaColors.primaryDark,
        linearTrackColor: LuminaColors.primaryContainerDark,
        circularTrackColor: LuminaColors.primaryContainerDark,
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: LuminaColors.surfaceVariantDark,
        contentTextStyle: LuminaTypography.darkTextTheme.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LuminaSpacing.radiusSm),
        ),
      ),
    );
  }

  // ============================================================================
  // CUPERTINO THEME (iOS)
  // ============================================================================

  /// Light theme for Cupertino (iOS)
  static CupertinoThemeData cupertinoLightTheme() {
    return CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: LuminaColors.primaryLight,
      primaryContrastingColor: LuminaColors.onPrimaryLight,
      scaffoldBackgroundColor: LuminaColors.backgroundLight,
      barBackgroundColor: LuminaColors.surfaceLight,
      textTheme: CupertinoTextThemeData(
        primaryColor: LuminaColors.primaryLight,
        textStyle: LuminaTypography.lightTextTheme.bodyMedium?.copyWith(
          color: LuminaColors.textPrimaryLight,
        ),
        actionTextStyle: LuminaTypography.lightTextTheme.labelLarge?.copyWith(
          color: LuminaColors.primaryLight,
        ),
        navTitleTextStyle: LuminaTypography.lightTextTheme.titleLarge?.copyWith(
          color: LuminaColors.textPrimaryLight,
        ),
        navLargeTitleTextStyle:
            LuminaTypography.lightTextTheme.headlineMedium?.copyWith(
          color: LuminaColors.textPrimaryLight,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Dark theme for Cupertino (iOS)
  static CupertinoThemeData cupertinoDarkTheme() {
    return CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: LuminaColors.primaryDark,
      primaryContrastingColor: LuminaColors.onPrimaryDark,
      scaffoldBackgroundColor: LuminaColors.backgroundDark,
      barBackgroundColor: LuminaColors.surfaceDark,
      textTheme: CupertinoTextThemeData(
        primaryColor: LuminaColors.primaryDark,
        textStyle: LuminaTypography.darkTextTheme.bodyMedium?.copyWith(
          color: LuminaColors.textPrimaryDark,
        ),
        actionTextStyle: LuminaTypography.darkTextTheme.labelLarge?.copyWith(
          color: LuminaColors.primaryDark,
        ),
        navTitleTextStyle: LuminaTypography.darkTextTheme.titleLarge?.copyWith(
          color: LuminaColors.textPrimaryDark,
        ),
        navLargeTitleTextStyle:
            LuminaTypography.darkTextTheme.headlineMedium?.copyWith(
          color: LuminaColors.textPrimaryDark,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Returns true if the current platform is iOS
  static bool get isIOS {
    try {
      return Platform.isIOS;
    } catch (e) {
      // In web or if Platform is not available
      return false;
    }
  }

  /// Returns true if the current platform is Android
  static bool get isAndroid {
    try {
      return Platform.isAndroid;
    } catch (e) {
      // In web or if Platform is not available
      return false;
    }
  }
}
