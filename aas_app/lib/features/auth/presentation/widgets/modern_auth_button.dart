import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';
import 'accessibility_helpers.dart';

/// Modern auth button with enhanced loading states
/// 
/// Features:
/// - Smooth loading animations
/// - Multiple button variants
/// - Responsive sizing
/// - Hover effects (desktop)
/// - Proper accessibility
enum ModernButtonVariant {
  filled,
  outlined,
  text,
}

class ModernAuthButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final ModernButtonVariant variant;
  final bool isFullWidth;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const ModernAuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = ModernButtonVariant.filled,
    this.isFullWidth = true,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  State<ModernAuthButton> createState() => _ModernAuthButtonState();
}

class _ModernAuthButtonState extends State<ModernAuthButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
        
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: _buildButton(context, isDesktop, isTablet),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton(BuildContext context, bool isDesktop, bool isTablet) {
    final buttonHeight = widget.height ?? (isDesktop ? 56.0 : isTablet ? 52.0 : 48.0);
    final fontSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;
    final iconSize = isDesktop ? 24.0 : isTablet ? 22.0 : 20.0;
    final borderRadius = isDesktop ? 16.0 : isTablet ? 14.0 : 12.0;

    return Container(
      width: widget.isFullWidth ? double.infinity : null,
      height: buttonHeight,
      decoration: BoxDecoration(
        gradient: _getBackgroundGradient(),
        borderRadius: BorderRadius.circular(borderRadius),
        border: _getBorder(),
        boxShadow: _getBoxShadow(isDesktop, isTablet),
      ),
             child: Material(
         color: Colors.transparent,
         child: InkWell(
           onTap: widget.isLoading ? null : widget.onPressed,
           borderRadius: BorderRadius.circular(borderRadius),
           focusColor: AppColors.primary.withOpacity(0.1),
           hoverColor: AppColors.primary.withOpacity(0.05),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24.0 : isTablet ? 20.0 : 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading) ...[
                  _buildLoadingIndicator(iconSize),
                  SizedBox(width: isDesktop ? 16.0 : isTablet ? 14.0 : 12.0),
                ] else if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: iconSize,
                    color: _getTextColor(),
                  ),
                  SizedBox(width: isDesktop ? 12.0 : isTablet ? 10.0 : 8.0),
                ],
                                 Semantics(
                   label: widget.isLoading ? 'Please wait...' : widget.text,
                   button: true,
                   child: Text(
                     widget.isLoading ? 'Please wait...' : widget.text,
                     style: _getTextStyle(context, fontSize),
                   ),
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
      ),
    );
  }

  LinearGradient? _getBackgroundGradient() {
    if (widget.variant == ModernButtonVariant.filled) {
      return widget.backgroundColor != null
          ? LinearGradient(
              colors: [
                widget.backgroundColor!,
                widget.backgroundColor!.withOpacity(0.8),
              ],
            )
          : AppColors.primaryGradient;
    }
    return null;
  }

  Color _getBackgroundColor() {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    
    switch (widget.variant) {
      case ModernButtonVariant.filled:
        return AppColors.primary;
      case ModernButtonVariant.outlined:
      case ModernButtonVariant.text:
        return Colors.transparent;
    }
  }

  Border? _getBorder() {
    if (widget.variant == ModernButtonVariant.outlined) {
      return Border.all(
        color: widget.borderColor ?? AppColors.primary,
        width: 1.5,
      );
    }
    return null;
  }

  List<BoxShadow>? _getBoxShadow(bool isDesktop, bool isTablet) {
    if (widget.variant == ModernButtonVariant.filled) {
      return [
        BoxShadow(
          color: AppColors.primary.withOpacity(_isHovered ? 0.4 : 0.2),
          blurRadius: _isHovered 
              ? (isDesktop ? 20.0 : isTablet ? 16.0 : 12.0)
              : (isDesktop ? 12.0 : isTablet ? 10.0 : 8.0),
          offset: Offset(0, _isHovered ? 8.0 : 4.0),
        ),
      ];
    }
    return null;
  }

  Color _getTextColor() {
    if (widget.textColor != null) return widget.textColor!;
    
    switch (widget.variant) {
      case ModernButtonVariant.filled:
        return AppColors.onPrimary;
      case ModernButtonVariant.outlined:
      case ModernButtonVariant.text:
        return AppColors.primary;
    }
  }

  TextStyle _getTextStyle(BuildContext context, double fontSize) {
    final baseStyle = Theme.of(context).textTheme.labelLarge;
    
    return baseStyle?.copyWith(
      color: _getTextColor(),
      fontWeight: FontWeight.w600,
      fontSize: fontSize,
      letterSpacing: 0.5,
    ) ?? TextStyle(
      color: _getTextColor(),
      fontWeight: FontWeight.w600,
      fontSize: fontSize,
      letterSpacing: 0.5,
    );
  }
}

/// Secondary button for less prominent actions
class ModernSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;

  const ModernSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return ModernAuthButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      variant: ModernButtonVariant.outlined,
      isFullWidth: isFullWidth,
    );
  }
}

/// Text button for minimal actions
class ModernTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? textColor;

  const ModernTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ModernAuthButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      variant: ModernButtonVariant.text,
      isFullWidth: false,
      textColor: textColor,
    );
  }
}
