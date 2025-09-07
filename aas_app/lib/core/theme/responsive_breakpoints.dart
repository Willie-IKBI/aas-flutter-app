import 'package:flutter/material.dart';

/// Responsive breakpoints for mobile-first design
///
/// Mobile-first approach means we design for mobile first,
/// then scale up for larger screens
class ResponsiveBreakpoints {
  // Mobile breakpoints
  static const double mobileSmall = 320; // iPhone SE, small Android
  static const double mobileMedium = 375; // iPhone 12/13/14
  static const double mobileLarge = 414; // iPhone 12/13/14 Pro Max

  // Tablet breakpoints
  static const double tabletSmall = 768; // iPad Mini, small tablets
  static const double tabletMedium = 834; // iPad Air, medium tablets
  static const double tabletLarge = 1024; // iPad Pro, large tablets

  // Desktop breakpoints
  static const double desktopSmall = 1280; // Small laptops
  static const double desktopMedium = 1440; // Standard laptops
  static const double desktopLarge = 1920; // Large monitors
  static const double desktopXLarge = 2560; // 4K monitors

  /// Get current screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileLarge) return ScreenSize.mobile;
    if (width < tabletLarge) return ScreenSize.tablet;
    if (width < desktopMedium) return ScreenSize.desktop;
    return ScreenSize.desktopLarge;
  }

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return getScreenSize(context) == ScreenSize.mobile;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    return getScreenSize(context) == ScreenSize.tablet;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    final size = getScreenSize(context);
    return size == ScreenSize.desktop || size == ScreenSize.desktopLarge;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final size = getScreenSize(context);

    switch (size) {
      case ScreenSize.mobile:
        return const EdgeInsets.all(16);
      case ScreenSize.tablet:
        return const EdgeInsets.all(24);
      case ScreenSize.desktop:
        return const EdgeInsets.all(32);
      case ScreenSize.desktopLarge:
        return const EdgeInsets.all(40);
    }
  }

  /// Get responsive margin based on screen size
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    final size = getScreenSize(context);

    switch (size) {
      case ScreenSize.mobile:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ScreenSize.tablet:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ScreenSize.desktop:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
      case ScreenSize.desktopLarge:
        return const EdgeInsets.symmetric(horizontal: 40, vertical: 20);
    }
  }

  /// Get responsive spacing based on screen size
  static double getResponsiveSpacing(BuildContext context) {
    final size = getScreenSize(context);

    switch (size) {
      case ScreenSize.mobile:
        return 16;
      case ScreenSize.tablet:
        return 24;
      case ScreenSize.desktop:
        return 32;
      case ScreenSize.desktopLarge:
        return 40;
    }
  }

  /// Get responsive font size multiplier
  static double getFontSizeMultiplier(BuildContext context) {
    final size = getScreenSize(context);

    switch (size) {
      case ScreenSize.mobile:
        return 1.0;
      case ScreenSize.tablet:
        return 1.1;
      case ScreenSize.desktop:
        return 1.2;
      case ScreenSize.desktopLarge:
        return 1.3;
    }
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context) {
    final size = getScreenSize(context);

    switch (size) {
      case ScreenSize.mobile:
        return 24;
      case ScreenSize.tablet:
        return 28;
      case ScreenSize.desktop:
        return 32;
      case ScreenSize.desktopLarge:
        return 36;
    }
  }

  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    final size = getScreenSize(context);

    switch (size) {
      case ScreenSize.mobile:
        return 48;
      case ScreenSize.tablet:
        return 52;
      case ScreenSize.desktop:
        return 56;
      case ScreenSize.desktopLarge:
        return 60;
    }
  }

  /// Get responsive card radius
  static double getCardRadius(BuildContext context) {
    final size = getScreenSize(context);

    switch (size) {
      case ScreenSize.mobile:
        return 12;
      case ScreenSize.tablet:
        return 16;
      case ScreenSize.desktop:
        return 20;
      case ScreenSize.desktopLarge:
        return 24;
    }
  }

  /// Get responsive grid columns
  static int getGridColumns(BuildContext context) {
    final size = getScreenSize(context);

    switch (size) {
      case ScreenSize.mobile:
        return 1;
      case ScreenSize.tablet:
        return 2;
      case ScreenSize.desktop:
        return 3;
      case ScreenSize.desktopLarge:
        return 4;
    }
  }

  /// Get responsive sidebar width
  static double getSidebarWidth(BuildContext context) {
    final size = getScreenSize(context);

    switch (size) {
      case ScreenSize.mobile:
        return 0; // No sidebar on mobile
      case ScreenSize.tablet:
        return 240;
      case ScreenSize.desktop:
        return 280;
      case ScreenSize.desktopLarge:
        return 320;
    }
  }

  /// Get responsive app bar height
  static double getAppBarHeight(BuildContext? context) {
    if (context == null) return 56; // Default height

    final size = getScreenSize(context);

    switch (size) {
      case ScreenSize.mobile:
        return 56;
      case ScreenSize.tablet:
        return 64;
      case ScreenSize.desktop:
        return 72;
      case ScreenSize.desktopLarge:
        return 80;
    }
  }
}

/// Screen size categories
enum ScreenSize {
  mobile,
  tablet,
  desktop,
  desktopLarge,
}

/// Responsive widget mixin for easy responsive behavior
mixin ResponsiveMixin {
  ScreenSize getScreenSize(BuildContext context) {
    return ResponsiveBreakpoints.getScreenSize(context);
  }

  bool isMobile(BuildContext context) {
    return ResponsiveBreakpoints.isMobile(context);
  }

  bool isTablet(BuildContext context) {
    return ResponsiveBreakpoints.isTablet(context);
  }

  bool isDesktop(BuildContext context) {
    return ResponsiveBreakpoints.isDesktop(context);
  }
}
