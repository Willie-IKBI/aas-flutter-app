import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/index.dart';
import 'modern_auth_button.dart';

/// Accessibility helpers and final polish components
///
/// Features:
/// - Screen reader support
/// - Keyboard navigation
/// - Focus management
/// - High contrast support
/// - Reduced motion support

/// Accessibility-aware container with proper semantics
class AccessibleContainer extends StatelessWidget {
  const AccessibleContainer({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.isButton = false,
    this.onTap,
    this.excludeSemantics = false,
  });
  final Widget child;
  final String? label;
  final String? hint;
  final bool isButton;
  final VoidCallback? onTap;
  final bool excludeSemantics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      excludeSemantics: excludeSemantics,
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }
}

/// Accessibility-aware text with proper semantics
class AccessibleText extends StatelessWidget {
  const AccessibleText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.semanticsLabel,
    this.excludeSemantics = false,
  });
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final String? semanticsLabel;
  final bool excludeSemantics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? text,
      excludeSemantics: excludeSemantics,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}

/// Focus-aware button with keyboard support
class FocusAwareButton extends StatefulWidget {
  const FocusAwareButton({
    super.key,
    required this.child,
    this.onPressed,
    this.enabled = true,
    this.tooltip,
    this.focusNode,
  });
  final Widget child;
  final VoidCallback? onPressed;
  final bool enabled;
  final String? tooltip;
  final FocusNode? focusNode;

  @override
  State<FocusAwareButton> createState() => _FocusAwareButtonState();
}

class _FocusAwareButtonState extends State<FocusAwareButton> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space) {
            if (widget.enabled && widget.onPressed != null) {
              widget.onPressed!();
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: Tooltip(
        message: widget.tooltip ?? '',
        child: widget.child,
      ),
    );
  }
}

/// High contrast aware container
class HighContrastContainer extends StatelessWidget {
  const HighContrastContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
  });
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isHighContrast = mediaQuery.highContrast;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: isHighContrast && borderColor != null
            ? Border.all(
                color: borderColor!,
                width: borderWidth ?? 2.0,
              )
            : null,
        borderRadius: borderRadius,
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Reduced motion aware animation
class ReducedMotionAnimation extends StatelessWidget {
  const ReducedMotionAnimation({
    super.key,
    required this.child,
    this.duration,
    this.curve,
    this.shouldAnimate,
  });
  final Widget child;
  final Duration? duration;
  final Curve? curve;
  final bool Function()? shouldAnimate;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final prefersReducedMotion =
        mediaQuery.platformBrightness == Brightness.dark ||
            mediaQuery.accessibleNavigation ||
            (shouldAnimate?.call() ?? false);

    if (prefersReducedMotion) {
      return child;
    }

    return AnimatedContainer(
      duration: duration ?? const Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInOut,
      child: child,
    );
  }
}

/// Accessibility utilities
class AccessibilityUtils {
  /// Get appropriate text scale factor
  static double getTextScaleFactor(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.textScaleFactor.clamp(0.8, 2.0);
  }

  /// Check if high contrast is enabled
  static bool isHighContrast(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Check if reduced motion is preferred
  static bool prefersReducedMotion(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark ||
        MediaQuery.of(context).accessibleNavigation;
  }

  /// Get accessible color with proper contrast
  static Color getAccessibleColor(BuildContext context, Color baseColor) {
    final highContrast = isHighContrast(context);
    if (highContrast) {
      // Ensure high contrast colors
      return baseColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    }
    return baseColor;
  }

  /// Create accessible text style
  static TextStyle createAccessibleTextStyle(
    BuildContext context,
    TextStyle baseStyle, {
    double? minFontSize,
    double? maxFontSize,
  }) {
    final textScaleFactor = getTextScaleFactor(context);
    final fontSize = (baseStyle.fontSize ?? 14.0) * textScaleFactor;
    final finalFontSize = fontSize.clamp(
      minFontSize ?? 12.0,
      maxFontSize ?? 24.0,
    );

    return baseStyle.copyWith(
      fontSize: finalFontSize,
      color: getAccessibleColor(context, baseStyle.color ?? Colors.black),
    );
  }
}

/// Final polish components
class PolishComponents {
  /// Subtle shimmer effect for loading states
  static Widget shimmer({
    required Widget child,
    Duration? duration,
    Color? shimmerColor,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? const Duration(seconds: 2),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.transparent,
                shimmerColor ?? AppColors.primary.withValues(alpha: 0.1),
                Colors.transparent,
              ],
              stops: [
                (value - 0.3).clamp(0.0, 1.0),
                value,
                (value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }

  /// Smooth page transition
  static Widget smoothTransition({
    required Widget child,
    Duration? duration,
    Curve? curve,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve ?? Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Elegant error display
  static Widget elegantError({
    required String message,
    VoidCallback? onRetry,
    String? retryText,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 0.2,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            ModernAuthButton(
              text: retryText ?? 'Try Again',
              onPressed: onRetry,
              icon: Icons.refresh,
              variant: ModernButtonVariant.outlined,
              isFullWidth: false,
            ),
          ],
        ],
      ),
    );
  }

  /// Success feedback
  static Widget successFeedback({
    required String message,
    Duration? autoHideDuration,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.successGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.onBackground,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Loading overlay with accessibility
  static Widget loadingOverlay({
    required Widget child,
    required bool isLoading,
    String? loadingMessage,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          ColoredBox(
            color: Colors.black.withValues(alpha: 0.4),
            child: Center(
              child: Semantics(
                label: loadingMessage ?? 'Loading',
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.outline.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Modern loading indicator
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      if (loadingMessage != null) ...[
                        const SizedBox(height: 20),
                        Text(
                          loadingMessage,
                          style: const TextStyle(
                            color: AppColors.onBackground,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
