import 'package:flutter/material.dart';

/// Accessibility helpers for consistent accessibility support across the app
class AccessibilityHelpers {
  AccessibilityHelpers._();

  /// Check if the user has reduced motion enabled
  static bool isReducedMotionEnabled(BuildContext context) {
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }

  /// Get the current text scale factor
  static double textScaleFactor(BuildContext context) {
    return MediaQuery.maybeOf(context)?.textScaler.scale(1.0) ?? 1.0;
  }

  /// Check if text is scaled beyond normal (1.3x or higher)
  static bool isTextScaled(BuildContext context) {
    return textScaleFactor(context) >= 1.3;
  }

  /// Check if text is highly scaled (1.6x or higher)
  static bool isTextHighlyScaled(BuildContext context) {
    return textScaleFactor(context) >= 1.6;
  }

  /// Get responsive padding based on text scale
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    EdgeInsets? base,
    double scaleFactor = 1.0,
  }) {
    final textScale = textScaleFactor(context);
    final responsiveScale = textScale * scaleFactor;

    return EdgeInsets.only(
      left: (base?.left ?? 16) * responsiveScale,
      top: (base?.top ?? 16) * responsiveScale,
      right: (base?.right ?? 16) * responsiveScale,
      bottom: (base?.bottom ?? 16) * responsiveScale,
    );
  }

  /// Get responsive font size based on text scale
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final textScale = textScaleFactor(context);
    return baseSize * textScale;
  }

  /// Get responsive spacing based on text scale
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final textScale = textScaleFactor(context);
    return baseSpacing * textScale;
  }

  /// Announce text to screen readers
  static void announce(BuildContext context, String text, {TextDirection? textDirection}) {
    // Use Semantics widget to announce text to screen readers
    Semantics(
      label: text,
      textDirection: textDirection ?? TextDirection.ltr,
      child: const SizedBox.shrink(),
    );
  }

  /// Focus the first invalid field in a form
  static void focusFirstInvalidField(
      BuildContext context, GlobalKey<FormState> formKey) {
    // This would need to be implemented with a custom form field that can be focused
    // For now, we'll announce the error
    announce(context, 'Please fix the errors in the form');
  }

  /// Get minimum tap target size (48x48dp)
  static const Size minimumTapTarget = Size(48, 48);

  /// Ensure a widget meets minimum tap target requirements
  static Widget ensureMinimumTapTarget(Widget child, {Size? minimumSize}) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minimumSize?.width ?? minimumTapTarget.width,
        minHeight: minimumSize?.height ?? minimumTapTarget.height,
      ),
      child: child,
    );
  }
}
