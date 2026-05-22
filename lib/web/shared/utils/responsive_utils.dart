import 'package:flutter/material.dart';

/// Responsive utilities for web portal
class ResponsiveUtils {
  // Breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1280;

  // Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return ScreenSize.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenSize.tablet;
    } else if (width < desktopBreakpoint) {
      return ScreenSize.desktop;
    } else {
      return ScreenSize.largeDesktop;
    }
  }

  // Check if mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  // Check if tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  // Check if desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return const EdgeInsets.all(12);
      case ScreenSize.tablet:
        return const EdgeInsets.all(16);
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        return const EdgeInsets.all(24);
    }
  }

  // Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet;
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        return desktop;
    }
  }

  // Get responsive grid columns
  static int getGridColumns(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return 1;
      case ScreenSize.tablet:
        return 2;
      case ScreenSize.desktop:
        return 3;
      case ScreenSize.largeDesktop:
        return 4;
    }
  }

  // Get responsive spacing
  static double getResponsiveSpacing(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return 8;
      case ScreenSize.tablet:
        return 12;
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        return 16;
    }
  }

  // Get responsive width for content
  static double getContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final size = getScreenSize(context);
    
    switch (size) {
      case ScreenSize.mobile:
        return width - 32; // 16px padding on each side
      case ScreenSize.tablet:
        return width - 64; // 32px padding on each side
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        return width - 96; // 48px padding on each side
    }
  }

  // Get responsive height for cards
  static double getCardHeight(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return 200;
      case ScreenSize.tablet:
        return 250;
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        return 300;
    }
  }

  // Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return 12;
      case ScreenSize.tablet:
        return 14;
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        return 16;
    }
  }

  // Get responsive icon size
  static double getResponsiveIconSize(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return 20;
      case ScreenSize.tablet:
        return 24;
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        return 28;
    }
  }

  // Get responsive button height
  static double getResponsiveButtonHeight(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return 40;
      case ScreenSize.tablet:
        return 44;
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        return 48;
    }
  }

  // Get responsive sidebar width
  static double getSidebarWidth(BuildContext context, {bool collapsed = false}) {
    if (collapsed) return 70;
    return 240;
  }

  // Get responsive navbar height
  static double getNavbarHeight(BuildContext context) {
    return 64;
  }

  // Get responsive max width for content
  static double getMaxContentWidth(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return double.infinity;
      case ScreenSize.tablet:
        return 900;
      case ScreenSize.desktop:
        return 1200;
      case ScreenSize.largeDesktop:
        return 1400;
    }
  }
}

/// Screen size categories
enum ScreenSize {
  mobile,      // < 768px
  tablet,      // 768px - 1023px
  desktop,     // 1024px - 1279px
  largeDesktop // >= 1280px
}

/// Responsive widget builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, ScreenSize) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveUtils.getScreenSize(context);
    return builder(context, screenSize);
  }
}

/// Responsive grid view
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final double spacing;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.getGridColumns(context);
    
    return Padding(
      padding: padding,
      child: GridView.count(
        crossAxisCount: columns,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: children,
      ),
    );
  }
}

/// Responsive row/column switcher
class ResponsiveLayout extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const ResponsiveLayout({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    
    if (isMobile) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      );
    } else {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      );
    }
  }
}

/// Responsive spacing widget
class ResponsiveSpacing extends StatelessWidget {
  final bool horizontal;

  const ResponsiveSpacing({
    super.key,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    
    if (horizontal) {
      return SizedBox(width: spacing);
    } else {
      return SizedBox(height: spacing);
    }
  }
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    
    return Padding(
      padding: responsivePadding,
      child: child,
    );
  }
}
