import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography system for Neru Music
/// Implements 4-level hierarchy as per project requirements
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  /// Font family
  static const String fontFamily = 'Inter';

  /// Heading styles (Level 1)
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: AppTheme.primaryText,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    color: AppTheme.primaryText,
    height: 1.25,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    color: AppTheme.primaryText,
    height: 1.3,
  );

  /// Body styles (Level 2)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    color: AppTheme.primaryText,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppTheme.primaryText,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppTheme.secondaryText,
    height: 1.4,
  );

  /// Caption styles (Level 3)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppTheme.tertiaryText,
    height: 1.3,
  );

  static const TextStyle captionBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    color: AppTheme.secondaryText,
    height: 1.3,
  );

  /// Button styles (Level 4)
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppTheme.primaryText,
    height: 1.0,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppTheme.primaryText,
    height: 1.0,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    color: AppTheme.primaryText,
    height: 1.0,
  );
}
