import 'package:flutter/material.dart';

/// Dark theme configuration for Neru Music
/// Follows design system with purple/pink accents and consistent spacing
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Primary color palette
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryPink = Color(0xFFEC4899);
  static const Color secondaryPurple = Color(0xFF7C3AED);
  static const Color accentBlue = Color(0xFF3B82F6);

  /// Dark theme colors
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkCard = Color(0xFF262626);
  static const Color darkBorder = Color(0xFF404040);

  /// Text colors
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFD1D5DB);
  static const Color tertiaryText = Color(0xFF9CA3AF);
  static const Color disabledText = Color(0xFF6B7280);

  /// Status colors
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);

  /// Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, primaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [darkCard, darkSurface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Border radius values
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;

  /// Shadow definitions
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 8.0,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x60000000),
      blurRadius: 12.0,
      offset: Offset(0, 6),
    ),
  ];
}
