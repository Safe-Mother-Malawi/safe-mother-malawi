import 'package:flutter/material.dart';

/// Responsive design helper for web portal
/// Provides breakpoints and responsive utilities for all screen sizes
class ResponsiveHelper {
  // Breakpoints
  static const int mobileBreakpoint = 600;
  static const int tabletBreakpoint = 900;
  static const int desktopBreakpoint = 1200;

  /// Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return ScreenSize.mobile;
    if (width < tabletBreakpoint) return ScreenSize.tablet;
    if (width < desktopBreakpoint) return ScreenSize.desktop;
    return ScreenSize.largeDesktop;
  }

  /// Check if screen is mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  /// Check if screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if screen is desktop or larger
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  /// Get responsive grid column count
  /// Mobile: 1, Tablet: 2, Desktop: 3, Large Desktop: 4
  static int getGridColumns(BuildContext context, {int? mobileOverride, int? tabletOverride, int? desktopOverride}) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return mobileOverride ?? 1;
      case ScreenSize.tablet:
        return tabletOverride ?? 2;
      case ScreenSize.desktop:
        return desktopOverride ?? 3;
      case ScreenSize.largeDesktop:
        return desktopOverride ?? 4;
    }
  }

  /// Get responsive padding
  /// Mobile: 16, Tablet: 20, Desktop: 28
  static double getResponsivePadding(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return 12.0;
      case ScreenSize.tablet:
        return 16.0;
      case ScreenSize.desktop:
        return 20.0;
      case ScreenSize.largeDesktop:
        return 28.0;
    }
  }

  /// Get responsive spacing between elements
  static double getResponsiveSpacing(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return 12.0;
      case ScreenSize.tablet:
        return 16.0;
      case ScreenSize.desktop:
        return 20.0;
      case ScreenSize.largeDesktop:
        return 28.0;
    }
  }

  /// Get responsive chart height
  /// Mobile: 150, Tablet: 180, Desktop: 220
  static double getChartHeight(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return 150.0;
      case ScreenSize.tablet:
        return 180.0;
      case ScreenSize.desktop:
        return 200.0;
      case ScreenSize.largeDesktop:
        return 220.0;
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return baseSize * 0.85;
      case ScreenSize.tablet:
        return baseSize * 0.9;
      case ScreenSize.desktop:
        return baseSize * 0.95;
      case ScreenSize.largeDesktop:
        return baseSize;
    }
  }

  /// Get responsive width for side panels
  /// Mobile: full width, Tablet: 60%, Desktop: 300px
  static double getSidePanelWidth(BuildContext context) {
    final size = getScreenSize(context);
    final screenWidth = MediaQuery.of(context).size.width;
    switch (size) {
      case ScreenSize.mobile:
        return screenWidth - 32; // Full width minus padding
      case ScreenSize.tablet:
        return screenWidth * 0.4;
      case ScreenSize.desktop:
        return 300.0;
      case ScreenSize.largeDesktop:
        return 320.0;
    }
  }

  /// Get responsive grid child aspect ratio
  static double getGridAspectRatio(BuildContext context, {double? mobileRatio, double? tabletRatio, double? desktopRatio}) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return mobileRatio ?? 1.2;
      case ScreenSize.tablet:
        return tabletRatio ?? 1.1;
      case ScreenSize.desktop:
        return desktopRatio ?? 1.0;
      case ScreenSize.largeDesktop:
        return desktopRatio ?? 1.0;
    }
  }

  /// Check if layout should be stacked (vertical) instead of side-by-side
  static bool shouldStackLayout(BuildContext context) =>
      MediaQuery.of(context).size.width < tabletBreakpoint;

  /// Get responsive max width for content
  static double getMaxContentWidth(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return double.infinity;
      case ScreenSize.tablet:
        return double.infinity;
      case ScreenSize.desktop:
        return 1200.0;
      case ScreenSize.largeDesktop:
        return 1400.0;
    }
  }
}

enum ScreenSize { mobile, tablet, desktop, largeDesktop }

/// Extension for easier access to responsive utilities
extension ResponsiveContext on BuildContext {
  ScreenSize get screenSize => ResponsiveHelper.getScreenSize(this);
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  int get gridColumns => ResponsiveHelper.getGridColumns(this);
  double get responsivePadding => ResponsiveHelper.getResponsivePadding(this);
  double get responsiveSpacing => ResponsiveHelper.getResponsiveSpacing(this);
  double get chartHeight => ResponsiveHelper.getChartHeight(this);
  bool get shouldStackLayout => ResponsiveHelper.shouldStackLayout(this);
}
