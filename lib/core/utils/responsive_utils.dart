import 'package:flutter/material.dart';

/// Responsive design utilities for different screen sizes
/// Provides breakpoints and responsive layouts
class ResponsiveUtils {
  ResponsiveUtils._();

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Get responsive value based on screen size
  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  /// Get responsive padding
  static EdgeInsetsGeometry responsivePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: responsiveValue(
        context: context,
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
      ),
      vertical: 16.0,
    );
  }

  /// Get responsive grid count
  static int responsiveGridCount(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );
  }

  /// Get responsive font size
  static double responsiveFontSize({
    required BuildContext context,
    required double baseFontSize,
  }) {
    final scaleFactor = responsiveValue(
      context: context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.2,
    );
    return baseFontSize * scaleFactor;
  }

  /// Get responsive spacing
  static double responsiveSpacing(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );
  }

  /// Get responsive card width
  static double responsiveCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isMobile(context)) {
      return screenWidth * 0.8;
    } else if (isTablet(context)) {
      return 300;
    } else {
      return 350;
    }
  }

  /// Build responsive layout
  static Widget responsiveLayout({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= desktopBreakpoint && desktop != null) {
          return desktop;
        } else if (constraints.maxWidth >= mobileBreakpoint && tablet != null) {
          return tablet;
        } else {
          return mobile;
        }
      },
    );
  }

  /// Responsive grid view
  static Widget responsiveGrid({
    required BuildContext context,
    required List<Widget> children,
    double? childAspectRatio,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
    EdgeInsetsGeometry? padding,
  }) {
    final crossAxisCount = responsiveGridCount(context);
    final spacing = crossAxisSpacing ?? responsiveSpacing(context);
    
    return GridView.builder(
      padding: padding ?? responsivePadding(context),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio ?? 1.0,
        crossAxisSpacing: spacing,
        mainAxisSpacing: mainAxisSpacing ?? spacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  /// Responsive text
  static Widget responsiveText(
    String text, {
    required BuildContext context,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium!;
    final responsiveStyle = baseStyle.copyWith(
      fontSize: responsiveFontSize(
        context: context,
        baseFontSize: baseStyle.fontSize ?? 14.0,
      ),
    );

    return Text(
      text,
      style: responsiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Responsive sized box
  static Widget responsiveSizedBox({
    required BuildContext context,
    double? height,
    double? width,
  }) {
    return SizedBox(
      height: height != null ? height * _getScaleFactor(context) : null,
      width: width != null ? width * _getScaleFactor(context) : null,
    );
  }

  /// Get responsive app bar height
  static double responsiveAppBarHeight(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: kToolbarHeight,
      tablet: kToolbarHeight + 8,
      desktop: kToolbarHeight + 16,
    );
  }

  /// Get responsive drawer width
  static double responsiveDrawerWidth(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: 280.0,
      tablet: 320.0,
      desktop: 360.0,
    );
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get responsive bottom navigation height
  static double responsiveBottomNavHeight(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: 60.0,
      tablet: 70.0,
      desktop: 80.0,
    );
  }

  /// Build adaptive layout for different orientations
  static Widget adaptiveLayout({
    required BuildContext context,
    required Widget portrait,
    Widget? landscape,
  }) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape && landscape != null) {
          return landscape;
        }
        return portrait;
      },
    );
  }

  // Helper method to get scale factor
  static double _getScaleFactor(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.2,
    );
  }
}

/// Responsive widget that rebuilds when screen size changes
class ResponsiveWidget extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType) builder;

  const ResponsiveWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        ScreenType screenType;
        
        if (constraints.maxWidth >= ResponsiveUtils.desktopBreakpoint) {
          screenType = ScreenType.desktop;
        } else if (constraints.maxWidth >= ResponsiveUtils.mobileBreakpoint) {
          screenType = ScreenType.tablet;
        } else {
          screenType = ScreenType.mobile;
        }

        return builder(context, screenType);
      },
    );
  }
}

/// Enum for different screen types
enum ScreenType { mobile, tablet, desktop }

/// Extension methods for responsive design
extension ResponsiveExtension on BuildContext {
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  bool get isLandscape => ResponsiveUtils.isLandscape(this);
  bool get isPortrait => ResponsiveUtils.isPortrait(this);

  EdgeInsetsGeometry get responsivePadding => ResponsiveUtils.responsivePadding(this);
  double get responsiveSpacing => ResponsiveUtils.responsiveSpacing(this);
  int get responsiveGridCount => ResponsiveUtils.responsiveGridCount(this);
  double get responsiveCardWidth => ResponsiveUtils.responsiveCardWidth(this);
  EdgeInsets get safeAreaPadding => ResponsiveUtils.getSafeAreaPadding(this);

  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    return ResponsiveUtils.responsiveValue<T>(
      context: this,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}
