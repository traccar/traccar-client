import 'package:flutter/material.dart';

/// LuminaLink Color System
///
/// A warm, trustworthy color palette inspired by light and connection.
/// Designed to feel safe, welcoming, and family-oriented across both
/// light and dark modes.
class LuminaColors {
  LuminaColors._();

  // ============================================================================
  // PRIMARY COLORS - Warm Amber/Gold (representing light/connection)
  // ============================================================================

  /// Primary color - Warm amber representing illumination and connection
  static const Color primaryLight = Color(0xFFF59E0B); // Amber 500
  static const Color primaryDark = Color(0xFFFBBF24); // Amber 400 (lighter for dark mode)

  /// Primary container - Softer backgrounds
  static const Color primaryContainerLight = Color(0xFFFEF3C7); // Amber 100
  static const Color primaryContainerDark = Color(0xFF78350F); // Amber 900

  /// On primary - Text/icons on primary color
  static const Color onPrimaryLight = Color(0xFF000000);
  static const Color onPrimaryDark = Color(0xFF000000);

  // ============================================================================
  // SECONDARY COLORS - Teal/Cyan (representing safety/trust)
  // ============================================================================

  /// Secondary color - Calming teal for trust and reliability
  static const Color secondaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color secondaryDark = Color(0xFF2DD4BF); // Teal 400

  /// Secondary container
  static const Color secondaryContainerLight = Color(0xFFCCFBF1); // Teal 100
  static const Color secondaryContainerDark = Color(0xFF134E4A); // Teal 900

  /// On secondary
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color onSecondaryDark = Color(0xFF000000);

  // ============================================================================
  // TERTIARY COLORS - Violet (representing care/family)
  // ============================================================================

  /// Tertiary color - Soft violet for emotional warmth
  static const Color tertiaryLight = Color(0xFF8B5CF6); // Violet 500
  static const Color tertiaryDark = Color(0xFFA78BFA); // Violet 400

  /// Tertiary container
  static const Color tertiaryContainerLight = Color(0xFFEDE9FE); // Violet 100
  static const Color tertiaryContainerDark = Color(0xFF4C1D95); // Violet 900

  // ============================================================================
  // SURFACE & BACKGROUND COLORS
  // ============================================================================

  /// Background - Main app background
  static const Color backgroundLight = Color(0xFFFAFAFA); // Warm off-white
  static const Color backgroundDark = Color(0xFF121212); // True black with slight warmth

  /// Surface - Cards, sheets, dialogs
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  /// Surface variant - Slightly different surface for hierarchy
  static const Color surfaceVariantLight = Color(0xFFF5F5F5);
  static const Color surfaceVariantDark = Color(0xFF2A2A2A);

  // ============================================================================
  // SEMANTIC COLORS - Status, Alerts, Actions
  // ============================================================================

  /// Error - Danger, destructive actions
  static const Color errorLight = Color(0xFFDC2626); // Red 600
  static const Color errorDark = Color(0xFFF87171); // Red 400

  /// Error container
  static const Color errorContainerLight = Color(0xFFFEE2E2); // Red 100
  static const Color errorContainerDark = Color(0xFF7F1D1D); // Red 900

  /// Success - Confirmations, positive status
  static const Color successLight = Color(0xFF16A34A); // Green 600
  static const Color successDark = Color(0xFF4ADE80); // Green 400

  /// Success container
  static const Color successContainerLight = Color(0xFFDCFCE7); // Green 100
  static const Color successContainerDark = Color(0xFF14532D); // Green 900

  /// Warning - Caution, attention needed
  static const Color warningLight = Color(0xFFEA580C); // Orange 600
  static const Color warningDark = Color(0xFFFB923C); // Orange 400

  /// Warning container
  static const Color warningContainerLight = Color(0xFFFFEDD5); // Orange 100
  static const Color warningContainerDark = Color(0xFF7C2D12); // Orange 900

  /// Info - Informational messages
  static const Color infoLight = Color(0xFF0284C7); // Sky 600
  static const Color infoDark = Color(0xFF38BDF8); // Sky 400

  // ============================================================================
  // TEXT & ICON COLORS
  // ============================================================================

  /// Text - Primary text color
  static const Color textPrimaryLight = Color(0xFF1F2937); // Gray 800
  static const Color textPrimaryDark = Color(0xFFF9FAFB); // Gray 50

  /// Text secondary - Muted text
  static const Color textSecondaryLight = Color(0xFF6B7280); // Gray 500
  static const Color textSecondaryDark = Color(0xFF9CA3AF); // Gray 400

  /// Text disabled
  static const Color textDisabledLight = Color(0xFFD1D5DB); // Gray 300
  static const Color textDisabledDark = Color(0xFF4B5563); // Gray 600

  // ============================================================================
  // BORDER & DIVIDER COLORS
  // ============================================================================

  /// Border
  static const Color borderLight = Color(0xFFE5E7EB); // Gray 200
  static const Color borderDark = Color(0xFF374151); // Gray 700

  /// Divider
  static const Color dividerLight = Color(0xFFF3F4F6); // Gray 100
  static const Color dividerDark = Color(0xFF1F2937); // Gray 800

  // ============================================================================
  // ELEVATION & SHADOW (for Material Design)
  // ============================================================================

  /// Shadow color for light mode
  static const Color shadowLight = Color(0x1A000000); // 10% black

  /// Shadow color for dark mode
  static const Color shadowDark = Color(0x33000000); // 20% black

  // ============================================================================
  // SPECIAL PURPOSE COLORS
  // ============================================================================

  /// Online indicator (user is active)
  static const Color onlineIndicator = Color(0xFF10B981); // Emerald 500

  /// Offline indicator
  static const Color offlineIndicator = Color(0xFF6B7280); // Gray 500

  /// Battery critical
  static const Color batteryCritical = Color(0xFFDC2626); // Red 600

  /// Battery warning
  static const Color batteryWarning = Color(0xFFF59E0B); // Amber 500

  /// Battery good
  static const Color batteryGood = Color(0xFF10B981); // Emerald 500

  /// Geofence zone on map
  static const Color geofenceZone = Color(0x4D8B5CF6); // Violet 500 with 30% opacity

  /// Location marker (current user)
  static const Color locationSelf = Color(0xFF0284C7); // Sky 600

  /// Location marker (family member)
  static const Color locationFamily = Color(0xFFF59E0B); // Amber 500
}
