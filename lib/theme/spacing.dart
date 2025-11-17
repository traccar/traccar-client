/// LuminaLink Spacing System
///
/// Consistent spacing values based on an 8-point grid system.
/// All spacing should use these constants to maintain visual harmony.
class LuminaSpacing {
  LuminaSpacing._();

  // ============================================================================
  // BASE SPACING SCALE (8-point grid)
  // ============================================================================

  /// 2px - Minimal spacing (rare use)
  static const double xxxs = 2.0;

  /// 4px - Extra extra small spacing
  static const double xxs = 4.0;

  /// 8px - Extra small spacing
  static const double xs = 8.0;

  /// 12px - Small spacing
  static const double sm = 12.0;

  /// 16px - Medium spacing (most common)
  static const double md = 16.0;

  /// 24px - Large spacing
  static const double lg = 24.0;

  /// 32px - Extra large spacing
  static const double xl = 32.0;

  /// 40px - Extra extra large spacing
  static const double xxl = 40.0;

  /// 48px - Extra extra extra large spacing
  static const double xxxl = 48.0;

  /// 64px - Huge spacing
  static const double huge = 64.0;

  // ============================================================================
  // SEMANTIC SPACING
  // ============================================================================

  /// Default padding for screen edges
  static const double screenPadding = md; // 16px

  /// Default padding for screen edges (horizontal)
  static const double screenPaddingHorizontal = md; // 16px

  /// Default padding for screen edges (vertical)
  static const double screenPaddingVertical = lg; // 24px

  /// Padding inside cards
  static const double cardPadding = md; // 16px

  /// Padding inside list items
  static const double listItemPadding = md; // 16px

  /// Space between list items
  static const double listItemSpacing = xs; // 8px

  /// Space between sections
  static const double sectionSpacing = lg; // 24px

  /// Space between form fields
  static const double formFieldSpacing = md; // 16px

  /// Space between buttons in a button group
  static const double buttonSpacing = sm; // 12px

  /// Icon spacing (gap between icon and text)
  static const double iconSpacing = xs; // 8px

  /// Chip/tag spacing
  static const double chipSpacing = xs; // 8px

  /// Bottom sheet padding
  static const double bottomSheetPadding = lg; // 24px

  /// Dialog padding
  static const double dialogPadding = lg; // 24px

  /// AppBar padding
  static const double appBarPadding = md; // 16px

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================

  /// Extra small border radius
  static const double radiusXs = 4.0;

  /// Small border radius
  static const double radiusSm = 8.0;

  /// Medium border radius (default for most components)
  static const double radiusMd = 12.0;

  /// Large border radius
  static const double radiusLg = 16.0;

  /// Extra large border radius
  static const double radiusXl = 20.0;

  /// Extra extra large border radius
  static const double radiusXxl = 24.0;

  /// Circular border radius (fully rounded)
  static const double radiusCircular = 9999.0;

  // ============================================================================
  // ELEVATION
  // ============================================================================

  /// No elevation
  static const double elevationNone = 0.0;

  /// Minimal elevation (subtle lift)
  static const double elevationXs = 1.0;

  /// Small elevation (buttons, chips)
  static const double elevationSm = 2.0;

  /// Medium elevation (cards)
  static const double elevationMd = 4.0;

  /// Large elevation (FAB, app bar)
  static const double elevationLg = 8.0;

  /// Extra large elevation (modals, dialogs)
  static const double elevationXl = 12.0;

  /// Maximum elevation (dropdowns, tooltips)
  static const double elevationMax = 16.0;

  // ============================================================================
  // ICON SIZES
  // ============================================================================

  /// Extra small icon
  static const double iconXs = 16.0;

  /// Small icon
  static const double iconSm = 20.0;

  /// Medium icon (default)
  static const double iconMd = 24.0;

  /// Large icon
  static const double iconLg = 32.0;

  /// Extra large icon
  static const double iconXl = 40.0;

  /// Extra extra large icon
  static const double iconXxl = 48.0;

  /// Huge icon (splash screens, empty states)
  static const double iconHuge = 64.0;

  // ============================================================================
  // AVATAR SIZES
  // ============================================================================

  /// Extra small avatar
  static const double avatarXs = 24.0;

  /// Small avatar
  static const double avatarSm = 32.0;

  /// Medium avatar (default)
  static const double avatarMd = 40.0;

  /// Large avatar
  static const double avatarLg = 56.0;

  /// Extra large avatar
  static const double avatarXl = 72.0;

  /// Extra extra large avatar (profile screens)
  static const double avatarXxl = 96.0;

  // ============================================================================
  // BUTTON HEIGHTS
  // ============================================================================

  /// Small button height
  static const double buttonHeightSm = 36.0;

  /// Medium button height (default)
  static const double buttonHeightMd = 44.0;

  /// Large button height
  static const double buttonHeightLg = 52.0;

  // ============================================================================
  // INPUT FIELD HEIGHTS
  // ============================================================================

  /// Small input field height
  static const double inputHeightSm = 40.0;

  /// Medium input field height (default)
  static const double inputHeightMd = 48.0;

  /// Large input field height
  static const double inputHeightLg = 56.0;

  // ============================================================================
  // BORDER WIDTH
  // ============================================================================

  /// Hairline border
  static const double borderWidthHairline = 0.5;

  /// Thin border
  static const double borderWidthThin = 1.0;

  /// Medium border
  static const double borderWidthMedium = 1.5;

  /// Thick border
  static const double borderWidthThick = 2.0;

  /// Extra thick border (focus/active states)
  static const double borderWidthExtraThick = 3.0;
}
