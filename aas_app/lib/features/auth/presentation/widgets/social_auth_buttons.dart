import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';

/// Social authentication provider types
enum SocialAuthProvider {
  google,
  github,
  microsoft,
  apple,
}

/// Modern social authentication button
/// 
/// Features:
/// - Clean, modern design
/// - Responsive sizing
/// - Provider-specific colors and icons
/// - Loading states
/// - Hover effects (desktop)
class SocialAuthButton extends StatefulWidget {
  final SocialAuthProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? customText;

  const SocialAuthButton({
    super.key,
    required this.provider,
    this.onPressed,
    this.isLoading = false,
    this.customText,
  });

  @override
  State<SocialAuthButton> createState() => _SocialAuthButtonState();
}

class _SocialAuthButtonState extends State<SocialAuthButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
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
                  child: _buildButton(context, isDesktop, isTablet),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton(BuildContext context, bool isDesktop, bool isTablet) {
    final buttonHeight = isDesktop ? 52.0 : isTablet ? 48.0 : 44.0;
    final fontSize = isDesktop ? 15.0 : isTablet ? 14.0 : 13.0;
    final iconSize = isDesktop ? 22.0 : isTablet ? 20.0 : 18.0;
    final borderRadius = isDesktop ? 14.0 : isTablet ? 12.0 : 10.0;

    return Container(
      width: double.infinity,
      height: buttonHeight,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: _getBorderColor(),
          width: 1.0,
        ),
        boxShadow: _getBoxShadow(isDesktop, isTablet),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 20.0 : isTablet ? 16.0 : 14.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading) ...[
                  _buildLoadingIndicator(iconSize),
                  SizedBox(width: isDesktop ? 12.0 : isTablet ? 10.0 : 8.0),
                ] else ...[
                  _buildProviderIcon(iconSize),
                  SizedBox(width: isDesktop ? 12.0 : isTablet ? 10.0 : 8.0),
                ],
                Text(
                  widget.isLoading ? 'Connecting...' : _getButtonText(),
                  style: _getTextStyle(context, fontSize),
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

  Widget _buildProviderIcon(double size) {
    switch (widget.provider) {
      case SocialAuthProvider.google:
        return _buildGoogleIcon(size);
      case SocialAuthProvider.github:
        return _buildGithubIcon(size);
      case SocialAuthProvider.microsoft:
        return _buildMicrosoftIcon(size);
      case SocialAuthProvider.apple:
        return _buildAppleIcon(size);
    }
  }

  Widget _buildGoogleIcon(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4285F4),
          ),
        ),
      ),
    );
  }

  Widget _buildGithubIcon(double size) {
    return Icon(
      Icons.code,
      size: size,
      color: _getTextColor(),
    );
  }

  Widget _buildMicrosoftIcon(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: const Color(0xFF00A4EF),
      ),
      child: Center(
        child: Text(
          'M',
          style: TextStyle(
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAppleIcon(double size) {
    return Icon(
      Icons.apple,
      size: size,
      color: _getTextColor(),
    );
  }

  Color _getBackgroundColor() {
    if (widget.isLoading) return AppColors.surface;
    
    switch (widget.provider) {
      case SocialAuthProvider.google:
        return Colors.white;
      case SocialAuthProvider.github:
        return const Color(0xFF24292E);
      case SocialAuthProvider.microsoft:
        return const Color(0xFF2F2F2F);
      case SocialAuthProvider.apple:
        return Colors.black;
    }
  }

  Color _getBorderColor() {
    if (widget.isLoading) return AppColors.outline.withOpacity(0.3);
    
    switch (widget.provider) {
      case SocialAuthProvider.google:
        return AppColors.outline.withOpacity(0.3);
      case SocialAuthProvider.github:
        return const Color(0xFF24292E);
      case SocialAuthProvider.microsoft:
        return const Color(0xFF2F2F2F);
      case SocialAuthProvider.apple:
        return Colors.black;
    }
  }

  Color _getTextColor() {
    if (widget.isLoading) return AppColors.onSurfaceVariant;
    
    switch (widget.provider) {
      case SocialAuthProvider.google:
        return const Color(0xFF757575);
      case SocialAuthProvider.github:
        return Colors.white;
      case SocialAuthProvider.microsoft:
        return Colors.white;
      case SocialAuthProvider.apple:
        return Colors.white;
    }
  }

  List<BoxShadow>? _getBoxShadow(bool isDesktop, bool isTablet) {
    if (widget.isLoading) return null;
    
    return [
      BoxShadow(
        color: AppColors.shadow.withOpacity(_isHovered ? 0.15 : 0.08),
        blurRadius: _isHovered 
            ? (isDesktop ? 12.0 : isTablet ? 10.0 : 8.0)
            : (isDesktop ? 8.0 : isTablet ? 6.0 : 4.0),
        offset: Offset(0, _isHovered ? 4.0 : 2.0),
      ),
    ];
  }

  String _getButtonText() {
    if (widget.customText != null) return widget.customText!;
    
    switch (widget.provider) {
      case SocialAuthProvider.google:
        return 'Continue with Google';
      case SocialAuthProvider.github:
        return 'Continue with GitHub';
      case SocialAuthProvider.microsoft:
        return 'Continue with Microsoft';
      case SocialAuthProvider.apple:
        return 'Continue with Apple';
    }
  }

  TextStyle _getTextStyle(BuildContext context, double fontSize) {
    final baseStyle = context.labelLarge;
    
    return baseStyle?.copyWith(
      color: _getTextColor(),
      fontWeight: FontWeight.w500,
      fontSize: fontSize,
      letterSpacing: 0.2,
    ) ?? TextStyle(
      color: _getTextColor(),
      fontWeight: FontWeight.w500,
      fontSize: fontSize,
      letterSpacing: 0.2,
    );
  }
}

/// Social authentication divider with "or" text
class SocialAuthDivider extends StatelessWidget {
  final String? text;

  const SocialAuthDivider({
    super.key,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
        
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: isDesktop ? 24.0 : isTablet ? 20.0 : 16.0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.outline.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 16.0 : isTablet ? 12.0 : 10.0,
                ),
                child: Text(
                  text ?? 'or',
                  style: context.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: isDesktop ? 14.0 : isTablet ? 13.0 : 12.0,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.outline.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Container for social authentication buttons
class SocialAuthContainer extends StatelessWidget {
  final List<SocialAuthButton> buttons;
  final Widget? divider;

  const SocialAuthContainer({
    super.key,
    required this.buttons,
    this.divider,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
        
        return Column(
          children: [
            if (divider != null) divider!,
            ...buttons.map((button) => Padding(
              padding: EdgeInsets.only(
                bottom: isDesktop ? 12.0 : isTablet ? 10.0 : 8.0,
              ),
              child: button,
            )),
          ],
        );
      },
    );
  }
}
