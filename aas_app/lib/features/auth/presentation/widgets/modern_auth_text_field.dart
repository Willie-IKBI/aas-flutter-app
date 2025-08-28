import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/index.dart';

/// Modern auth text field with floating labels
/// 
/// Features:
/// - Floating labels that animate smoothly
/// - Clean, minimal design
/// - Responsive sizing
/// - Proper focus states
/// - Error handling with smooth animations
class ModernAuthTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  const ModernAuthTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.validator,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  State<ModernAuthTextField> createState() => _ModernAuthTextFieldState();
}

class _ModernAuthTextFieldState extends State<ModernAuthTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _hasFocus = false;
  bool _hasError = false;
  bool _hasContent = false;
  late AnimationController _animationController;
  late Animation<double> _labelAnimation;
  late Animation<double> _errorAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _labelAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _errorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);
    
    // Initialize state
    _hasContent = _controller.text.isNotEmpty;
    if (_hasContent || _hasFocus) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    if (widget.controller == null) {
      _controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
    
    if (_hasFocus || _hasContent) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onTextChange() {
    final hasContent = _controller.text.isNotEmpty;
    if (hasContent != _hasContent) {
      setState(() {
        _hasContent = hasContent;
      });
      
      if (_hasContent || _hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  void _updateErrorState(String? errorText) {
    final hasError = errorText != null && errorText.isNotEmpty;
    if (hasError != _hasError) {
      setState(() {
        _hasError = hasError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main text field container
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(
                  isDesktop ? 16.0 : isTablet ? 14.0 : 12.0,
                ),
                border: Border.all(
                  color: _getBorderColor(),
                  width: _hasFocus ? 2.0 : 1.0,
                ),
                boxShadow: _hasFocus ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: isDesktop ? 12.0 : isTablet ? 10.0 : 8.0,
                    offset: Offset(0, isDesktop ? 4.0 : isTablet ? 3.0 : 2.0),
                  ),
                ] : null,
              ),
              child: Stack(
                children: [
                  // Text field
                  TextFormField(
                    controller: _controller,
                    focusNode: _focusNode,
                    obscureText: widget.obscureText,
                    enabled: widget.enabled,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    maxLines: widget.maxLines,
                    maxLength: widget.maxLength,
                    inputFormatters: widget.inputFormatters,
                    validator: (value) {
                      final error = widget.validator?.call(value);
                      _updateErrorState(error);
                      return error;
                    },
                    onTap: widget.onTap,
                    onChanged: (value) {
                      widget.onChanged?.call(value);
                      _updateErrorState(widget.validator?.call(value));
                    },
                    onFieldSubmitted: widget.onSubmitted,
                    style: _getTextStyle(context, isDesktop, isTablet),
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: _getHintStyle(context, isDesktop, isTablet),
                      prefixIcon: widget.prefixIcon != null
                          ? Padding(
                              padding: EdgeInsets.all(
                                isDesktop ? 16.0 : isTablet ? 14.0 : 12.0,
                              ),
                              child: Icon(
                                widget.prefixIcon,
                                color: _getIconColor(),
                                size: isDesktop ? 24.0 : isTablet ? 22.0 : 20.0,
                              ),
                            )
                          : null,
                      suffixIcon: widget.suffixIcon != null
                          ? Padding(
                              padding: EdgeInsets.all(
                                isDesktop ? 8.0 : isTablet ? 6.0 : 4.0,
                              ),
                              child: widget.suffixIcon!,
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(
                        widget.prefixIcon != null
                            ? (isDesktop ? 56.0 : isTablet ? 52.0 : 48.0)
                            : (isDesktop ? 20.0 : isTablet ? 18.0 : 16.0),
                        isDesktop ? 24.0 : isTablet ? 20.0 : 18.0,
                        widget.suffixIcon != null
                            ? (isDesktop ? 40.0 : isTablet ? 36.0 : 32.0)
                            : (isDesktop ? 20.0 : isTablet ? 18.0 : 16.0),
                        isDesktop ? 24.0 : isTablet ? 20.0 : 18.0,
                      ),
                      counterText: '', // Hide character counter
                    ),
                  ),
                  
                  // Floating label
                  Positioned(
                    left: widget.prefixIcon != null
                        ? (isDesktop ? 56.0 : isTablet ? 52.0 : 48.0)
                        : (isDesktop ? 20.0 : isTablet ? 18.0 : 16.0),
                    top: 0,
                    child: AnimatedBuilder(
                      animation: _labelAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _labelAnimation.value * -8),
                          child: Opacity(
                            opacity: _labelAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.label,
                                style: _getLabelStyle(context, isDesktop, isTablet),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Error text
            if (widget.errorText != null && widget.errorText!.isNotEmpty) ...[
              SizedBox(height: isDesktop ? 8.0 : isTablet ? 6.0 : 4.0),
              AnimatedBuilder(
                animation: _errorAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _errorAnimation.value) * -4),
                    child: Opacity(
                      opacity: _errorAnimation.value,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: isDesktop ? 20.0 : isTablet ? 18.0 : 16.0,
                        ),
                        child: Text(
                          widget.errorText!,
                          style: _getErrorStyle(context, isDesktop, isTablet),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Color _getBorderColor() {
    if (_hasError) return AppColors.error.withOpacity(0.7);
    if (_hasFocus) return AppColors.primary;
    return AppColors.outline.withOpacity(0.3);
  }

  Color _getIconColor() {
    if (_hasError) return AppColors.error;
    if (_hasFocus) return AppColors.primary;
    return AppColors.onSurfaceVariant;
  }

  TextStyle _getTextStyle(BuildContext context, bool isDesktop, bool isTablet) {
    final baseStyle = Theme.of(context).textTheme.bodyLarge;
    final fontSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;
    
    return baseStyle?.copyWith(
      color: AppColors.onSurface,
      fontWeight: FontWeight.w500,
      fontSize: fontSize,
      height: 1.4,
    ) ?? TextStyle(
      color: AppColors.onSurface,
      fontWeight: FontWeight.w500,
      fontSize: fontSize,
      height: 1.4,
    );
  }

  TextStyle _getHintStyle(BuildContext context, bool isDesktop, bool isTablet) {
    final baseStyle = Theme.of(context).textTheme.bodyLarge;
    final fontSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;
    
    return baseStyle?.copyWith(
      color: AppColors.onSurfaceVariant.withOpacity(0.6),
      fontWeight: FontWeight.w400,
      fontSize: fontSize,
      height: 1.4,
    ) ?? TextStyle(
      color: AppColors.onSurfaceVariant.withOpacity(0.6),
      fontWeight: FontWeight.w400,
      fontSize: fontSize,
      height: 1.4,
    );
  }

  TextStyle _getLabelStyle(BuildContext context, bool isDesktop, bool isTablet) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    final fontSize = isDesktop ? 14.0 : isTablet ? 13.0 : 12.0;
    
    return baseStyle?.copyWith(
      color: _hasError ? AppColors.error : AppColors.primary,
      fontWeight: FontWeight.w600,
      fontSize: fontSize,
      height: 1.2,
    ) ?? TextStyle(
      color: _hasError ? AppColors.error : AppColors.primary,
      fontWeight: FontWeight.w600,
      fontSize: fontSize,
      height: 1.2,
    );
  }

  TextStyle _getErrorStyle(BuildContext context, bool isDesktop, bool isTablet) {
    final baseStyle = Theme.of(context).textTheme.bodySmall;
    final fontSize = isDesktop ? 13.0 : isTablet ? 12.0 : 11.0;
    
    return baseStyle?.copyWith(
      color: AppColors.error,
      fontWeight: FontWeight.w500,
      fontSize: fontSize,
      height: 1.2,
    ) ?? TextStyle(
      color: AppColors.error,
      fontWeight: FontWeight.w500,
      fontSize: fontSize,
      height: 1.2,
    );
  }
}
