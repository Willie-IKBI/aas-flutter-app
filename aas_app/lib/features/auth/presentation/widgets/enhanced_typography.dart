import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';

/// Enhanced typography components with modern styling
/// 
/// Features:
/// - Modern typography hierarchy
/// - Responsive text sizing
/// - Subtle animations and micro-interactions
/// - Consistent spacing and colors

/// Modern heading with gradient text effect
class ModernHeading extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final bool showGradient;
  final double? fontSize;
  final FontWeight? fontWeight;

  const ModernHeading({
    super.key,
    required this.text,
    this.textAlign,
    this.showGradient = true,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
        
        final size = fontSize ?? (isDesktop ? 32.0 : isTablet ? 28.0 : 24.0);
        final weight = fontWeight ?? FontWeight.w700;
        
        if (showGradient) {
          return ShaderMask(
            shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
            child: Text(
              text,
              textAlign: textAlign ?? TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: size,
                fontWeight: weight,
                letterSpacing: -0.5,
                height: 1.2,
                color: Colors.white,
              ) ?? TextStyle(
                fontSize: size,
                fontWeight: weight,
                letterSpacing: -0.5,
                height: 1.2,
                color: Colors.white,
              ),
            ),
          );
        } else {
          return Text(
            text,
            textAlign: textAlign ?? TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: size,
              fontWeight: weight,
              letterSpacing: -0.5,
              height: 1.2,
              color: AppColors.onBackground,
            ) ?? TextStyle(
              fontSize: size,
              fontWeight: weight,
              letterSpacing: -0.5,
              height: 1.2,
              color: AppColors.onBackground,
            ),
          );
        }
      },
    );
  }
}

/// Modern subtitle with enhanced styling
class ModernSubtitle extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  const ModernSubtitle({
    super.key,
    required this.text,
    this.textAlign,
    this.color,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
        
        final size = fontSize ?? (isDesktop ? 18.0 : isTablet ? 16.0 : 14.0);
        final weight = fontWeight ?? FontWeight.w400;
        
        return Text(
          text,
          textAlign: textAlign ?? TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: size,
            fontWeight: weight,
            height: 1.4,
            color: color ?? AppColors.onSurfaceVariant,
            letterSpacing: 0.1,
          ) ?? TextStyle(
            fontSize: size,
            fontWeight: weight,
            height: 1.4,
            color: color ?? AppColors.onSurfaceVariant,
            letterSpacing: 0.1,
          ),
        );
      },
    );
  }
}

/// Animated text with fade-in effect
class AnimatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Duration? duration;
  final Curve? curve;

  const AnimatedText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.duration,
    this.curve,
  });

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _fadeAnimation.value) * 10),
            child: Text(
              widget.text,
              textAlign: widget.textAlign,
              style: widget.style,
            ),
          ),
        );
      },
    );
  }
}

/// Interactive text with hover effects
class InteractiveText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? hoverStyle;
  final VoidCallback? onTap;
  final TextAlign? textAlign;

  const InteractiveText({
    super.key,
    required this.text,
    this.style,
    this.hoverStyle,
    this.onTap,
    this.textAlign,
  });

  @override
  State<InteractiveText> createState() => _InteractiveTextState();
}

class _InteractiveTextState extends State<InteractiveText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Text(
                widget.text,
                textAlign: widget.textAlign,
                style: _isHovered ? widget.hoverStyle : widget.style,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Typography utility class for consistent text styling
class TypographyUtils {
  /// Get responsive font size based on screen width
  static double getResponsiveFontSize(double screenWidth, {
    double? desktop,
    double? tablet,
    double? mobile,
  }) {
    if (screenWidth >= 1200) return desktop ?? 16.0;
    if (screenWidth >= 768) return tablet ?? 14.0;
    return mobile ?? 12.0;
  }

  /// Get responsive line height based on screen width
  static double getResponsiveLineHeight(double screenWidth, {
    double? desktop,
    double? tablet,
    double? mobile,
  }) {
    if (screenWidth >= 1200) return desktop ?? 1.4;
    if (screenWidth >= 768) return tablet ?? 1.3;
    return mobile ?? 1.2;
  }

  /// Get responsive letter spacing based on screen width
  static double getResponsiveLetterSpacing(double screenWidth, {
    double? desktop,
    double? tablet,
    double? mobile,
  }) {
    if (screenWidth >= 1200) return desktop ?? 0.1;
    if (screenWidth >= 768) return tablet ?? 0.05;
    return mobile ?? 0.0;
  }

  /// Create responsive text style
  static TextStyle createResponsiveStyle(
    BuildContext context,
    double screenWidth, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? lineHeight,
    double? letterSpacing,
  }) {
    final size = fontSize ?? getResponsiveFontSize(screenWidth);
    final height = lineHeight ?? getResponsiveLineHeight(screenWidth);
    final spacing = letterSpacing ?? getResponsiveLetterSpacing(screenWidth);

    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: size,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: spacing,
    ) ?? TextStyle(
      fontSize: size,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: spacing,
    );
  }
}

/// Micro-interaction components
class MicroInteractions {
  /// Subtle pulse animation
  static Widget pulse({
    required Widget child,
    Duration? duration,
    Curve? curve,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? const Duration(seconds: 2),
      tween: Tween(begin: 0.95, end: 1.0),
      curve: curve ?? Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Gentle bounce animation
  static Widget bounce({
    required Widget child,
    Duration? duration,
    Curve? curve,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve ?? Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Fade-in with slide animation
  static Widget fadeInSlide({
    required Widget child,
    Duration? duration,
    Curve? curve,
    Offset? beginOffset,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve ?? Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: (beginOffset ?? const Offset(0, 20)) * (1 - value),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
