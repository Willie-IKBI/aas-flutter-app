import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Theme Extensions for AAS App
///
/// This file provides convenient extensions to access theme colors and styles.
extension ThemeExtension on BuildContext {
  /// Get the current theme
  ThemeData get theme => Theme.of(this);

  /// Get the current color scheme
  ColorScheme get colors => theme.colorScheme;

  /// Get the current text theme
  TextTheme get textTheme => theme.textTheme;

  /// Get the current brightness
  Brightness get brightness => theme.brightness;

  /// Check if the theme is dark
  bool get isDark => brightness == Brightness.dark;

  /// Check if the theme is light
  bool get isLight => brightness == Brightness.light;
}

/// Extension for common color access
extension ColorExtension on BuildContext {
  // Primary colors
  Color get primary => colors.primary;
  Color get onPrimary => colors.onPrimary;
  Color get primaryContainer => colors.primaryContainer;
  Color get onPrimaryContainer => colors.onPrimaryContainer;

  // Secondary colors
  Color get secondary => colors.secondary;
  Color get onSecondary => colors.onSecondary;
  Color get secondaryContainer => colors.secondaryContainer;
  Color get onSecondaryContainer => colors.onSecondaryContainer;

  // Tertiary colors
  Color get tertiary => colors.tertiary;
  Color get onTertiary => colors.onTertiary;
  Color get tertiaryContainer => colors.tertiaryContainer;
  Color get onTertiaryContainer => colors.onTertiaryContainer;

  // Error colors
  Color get error => colors.error;
  Color get onError => colors.onError;
  Color get errorContainer => colors.errorContainer;
  Color get onErrorContainer => colors.onErrorContainer;

  // Warning colors
  Color get warning => AppColors.warning;

  // Success colors
  Color get success => AppColors.success;

  // Background colors
  Color get background => colors.surface;
  Color get onBackground => colors.onSurface;

  // Surface colors
  Color get surface => colors.surface;
  Color get onSurface => colors.onSurface;
  Color get surfaceVariant => colors.surfaceContainerHighest;
  Color get onSurfaceVariant => colors.onSurfaceVariant;

  // Outline colors
  Color get outline => colors.outline;
  Color get outlineVariant => colors.outlineVariant;

  // Shadow colors
  Color get shadow => colors.shadow;
  Color get scrim => colors.scrim;

  // Inverse colors
  Color get inverseSurface => colors.inverseSurface;
  Color get onInverseSurface => colors.onInverseSurface;
  Color get inversePrimary => colors.inversePrimary;

  // Surface tint
  Color get surfaceTint => colors.surfaceTint;
}

/// Extension for text styles
extension TextStyleExtension on BuildContext {
  // Display styles
  TextStyle get displayLarge => textTheme.displayLarge!;
  TextStyle get displayMedium => textTheme.displayMedium!;
  TextStyle get displaySmall => textTheme.displaySmall!;

  // Headline styles
  TextStyle get headlineLarge => textTheme.headlineLarge!;
  TextStyle get headlineMedium => textTheme.headlineMedium!;
  TextStyle get headlineSmall => textTheme.headlineSmall!;

  // Title styles
  TextStyle get titleLarge => textTheme.titleLarge!;
  TextStyle get titleMedium => textTheme.titleMedium!;
  TextStyle get titleSmall => textTheme.titleSmall!;

  // Body styles
  TextStyle get bodyLarge => textTheme.bodyLarge!;
  TextStyle get bodyMedium => textTheme.bodyMedium!;
  TextStyle get bodySmall => textTheme.bodySmall!;

  // Label styles
  TextStyle get labelLarge => textTheme.labelLarge!;
  TextStyle get labelMedium => textTheme.labelMedium!;
  TextStyle get labelSmall => textTheme.labelSmall!;
}

/// Extension for common spacing and sizing
extension SpacingExtension on BuildContext {
  // Common spacing values
  double get spacing4 => 4.0;
  double get spacing8 => 8.0;
  double get spacing12 => 12.0;
  double get spacing16 => 16.0;
  double get spacing20 => 20.0;
  double get spacing24 => 24.0;
  double get spacing32 => 32.0;
  double get spacing40 => 40.0;
  double get spacing48 => 48.0;
  double get spacing56 => 56.0;
  double get spacing64 => 64.0;

  // Common border radius values
  double get radius4 => 4.0;
  double get radius8 => 8.0;
  double get radius12 => 12.0;
  double get radius16 => 16.0;
  double get radius20 => 20.0;
  double get radius24 => 24.0;
  double get radius32 => 32.0;

  // Common elevation values
  double get elevation1 => 1.0;
  double get elevation2 => 2.0;
  double get elevation4 => 4.0;
  double get elevation8 => 8.0;
  double get elevation16 => 16.0;
}

/// Extension for responsive design
extension ResponsiveExtension on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Get screen aspect ratio
  double get screenAspectRatio => screenSize.aspectRatio;

  /// Get screen pixel density
  double get pixelDensity => MediaQuery.of(this).devicePixelRatio;

  /// Check if screen is small (width < 600)
  bool get isSmallScreen => screenWidth < 600;

  /// Check if screen is medium (600 <= width < 900)
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 900;

  /// Check if screen is large (width >= 900)
  bool get isLargeScreen => screenWidth >= 900;

  /// Check if screen is extra large (width >= 1200)
  bool get isExtraLargeScreen => screenWidth >= 1200;

  /// Get responsive padding based on screen size
  EdgeInsets get responsivePadding {
    if (isSmallScreen) {
      return const EdgeInsets.all(16.0);
    } else if (isMediumScreen) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  /// Get responsive margin based on screen size
  EdgeInsets get responsiveMargin {
    if (isSmallScreen) {
      return const EdgeInsets.all(8.0);
    } else if (isMediumScreen) {
      return const EdgeInsets.all(16.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }

  /// Get responsive font size multiplier
  double get responsiveFontSize {
    if (isSmallScreen) {
      return 1.0;
    } else if (isMediumScreen) {
      return 1.1;
    } else {
      return 1.2;
    }
  }
}

/// Extension for common widget helpers
extension WidgetExtension on BuildContext {
  /// Show a snackbar with the given message
  void showSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show a snackbar with error styling
  void showErrorSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error,
        duration: duration ?? const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show a snackbar with success styling
  void showSuccessSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: duration ?? const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show a loading dialog
  void showLoadingDialog(String message) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  /// Hide the current dialog
  void hideDialog() {
    Navigator.of(this).pop();
  }

  /// Show a confirmation dialog
  Future<bool> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

/// Extension for common decoration helpers
extension DecorationExtension on BuildContext {
  /// Get a card decoration
  BoxDecoration get cardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius12),
        boxShadow: [
          BoxShadow(
            color: shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  /// Get an elevated card decoration
  BoxDecoration get elevatedCardDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius12),
        boxShadow: [
          BoxShadow(
            color: shadow.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  /// Get a primary gradient decoration
  BoxDecoration get primaryGradientDecoration => BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(radius12),
      );

  /// Get a secondary gradient decoration
  BoxDecoration get secondaryGradientDecoration => BoxDecoration(
        gradient: AppColors.secondaryGradient,
        borderRadius: BorderRadius.circular(radius12),
      );

  /// Get a background gradient decoration
  BoxDecoration get backgroundGradientDecoration => const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      );

  /// Get an outline decoration
  BoxDecoration get outlineDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius8),
        border: Border.all(
          color: outline,
        ),
      );

  /// Get a primary outline decoration
  BoxDecoration get primaryOutlineDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius8),
        border: Border.all(
          color: primary,
          width: 2,
        ),
      );
}
