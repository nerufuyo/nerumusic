import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Main theme data for Neru Music application
/// Combines colors, typography, and component themes
class AppThemeData {
  // Private constructor to prevent instantiation
  AppThemeData._();

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTextStyles.fontFamily,
      
      /// Color scheme
      colorScheme: const ColorScheme.dark(
        primary: AppTheme.primaryPurple,
        secondary: AppTheme.primaryPink,
        surface: AppTheme.darkSurface,
        error: AppTheme.errorColor,
        onPrimary: AppTheme.primaryText,
        onSecondary: AppTheme.primaryText,
        onSurface: AppTheme.primaryText,
        onError: AppTheme.primaryText,
      ),

      /// Scaffold theme
      scaffoldBackgroundColor: AppTheme.darkBackground,

      /// AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h3,
        iconTheme: IconThemeData(color: AppTheme.primaryText),
      ),

      /// Card theme
      cardTheme: CardThemeData(
        color: AppTheme.darkCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),

      /// Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryPurple,
          foregroundColor: AppTheme.primaryText,
          textStyle: AppTextStyles.buttonMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 4,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryPurple,
          textStyle: AppTextStyles.buttonMedium,
          side: const BorderSide(color: AppTheme.primaryPurple, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.primaryPurple,
          textStyle: AppTextStyles.buttonMedium,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      /// Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTheme.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
          borderSide: const BorderSide(color: AppTheme.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
          borderSide: const BorderSide(color: AppTheme.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
          borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.tertiaryText,
        ),
        labelStyle: AppTextStyles.bodyMedium,
        contentPadding: const EdgeInsets.all(16),
      ),

      /// Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppTheme.darkSurface,
        selectedItemColor: AppTheme.primaryPurple,
        unselectedItemColor: AppTheme.tertiaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      /// Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppTheme.primaryPurple,
        inactiveTrackColor: AppTheme.darkBorder,
        thumbColor: AppTheme.primaryPurple,
        overlayColor: AppTheme.primaryPurple.withValues(alpha: 0.2),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      ),

      /// Icon theme
      iconTheme: const IconThemeData(
        color: AppTheme.primaryText,
        size: 24,
      ),

      /// Divider theme
      dividerTheme: const DividerThemeData(
        color: AppTheme.darkBorder,
        thickness: 1,
      ),
    );
  }
}
