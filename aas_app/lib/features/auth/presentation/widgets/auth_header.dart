import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';
import 'enhanced_typography.dart';

/// Modern auth header component
/// 
/// Provides consistent header styling across all auth screens
/// with responsive design and clean typography
class AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final bool showLogo;

  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
        
        return Column(
          children: [
            // Logo/Icon section
            if (showLogo) ...[
              MicroInteractions.bounce(
                child: _buildLogo(context, isDesktop, isTablet),
              ),
              SizedBox(height: isDesktop ? 32.0 : isTablet ? 24.0 : 20.0),
            ],
            
            // Title section
            MicroInteractions.fadeInSlide(
              child: ModernHeading(
                text: title,
                showGradient: true,
              ),
            ),
            
            // Subtitle section
            if (subtitle != null) ...[
              SizedBox(height: isDesktop ? 12.0 : isTablet ? 8.0 : 6.0),
              MicroInteractions.fadeInSlide(
                duration: const Duration(milliseconds: 800),
                beginOffset: const Offset(0, 15),
                child: ModernSubtitle(
                  text: subtitle!,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildLogo(BuildContext context, bool isDesktop, bool isTablet) {
    final logoSize = isDesktop ? 80.0 : isTablet ? 70.0 : 60.0;
    final iconSize = isDesktop ? 40.0 : isTablet ? 35.0 : 30.0;
    
    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(isDesktop ? 20.0 : isTablet ? 18.0 : 16.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: isDesktop ? 20.0 : isTablet ? 16.0 : 12.0,
            offset: Offset(0, isDesktop ? 10.0 : isTablet ? 8.0 : 6.0),
          ),
        ],
      ),
      child: Icon(
        icon ?? Icons.construction,
        size: iconSize,
        color: iconColor ?? Colors.white,
      ),
    );
  }

  TextStyle _getTitleStyle(BuildContext context, bool isDesktop, bool isTablet) {
    final baseStyle = Theme.of(context).textTheme.headlineLarge;
    final fontSize = isDesktop ? 32.0 : isTablet ? 28.0 : 24.0;
    final letterSpacing = isDesktop ? -0.5 : isTablet ? -0.3 : -0.2;
    
    return baseStyle?.copyWith(
      color: AppColors.onBackground,
      fontWeight: FontWeight.w700,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      height: 1.2,
    ) ?? TextStyle(
      color: AppColors.onBackground,
      fontWeight: FontWeight.w700,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      height: 1.2,
    );
  }

  TextStyle _getSubtitleStyle(BuildContext context, bool isDesktop, bool isTablet) {
    final baseStyle = Theme.of(context).textTheme.bodyLarge;
    final fontSize = isDesktop ? 18.0 : isTablet ? 16.0 : 14.0;
    
    return baseStyle?.copyWith(
      color: AppColors.onSurfaceVariant,
      fontWeight: FontWeight.w400,
      fontSize: fontSize,
      height: 1.4,
    ) ?? TextStyle(
      color: AppColors.onSurfaceVariant,
      fontWeight: FontWeight.w400,
      fontSize: fontSize,
      height: 1.4,
    );
  }
}

/// Compact auth header for smaller screens or secondary pages
class CompactAuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const CompactAuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
        
        return Row(
          children: [
            // Icon
            if (icon != null) ...[
              Container(
                width: isDesktop ? 48.0 : isTablet ? 40.0 : 36.0,
                height: isDesktop ? 48.0 : isTablet ? 40.0 : 36.0,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(isDesktop ? 12.0 : isTablet ? 10.0 : 8.0),
                ),
                child: Icon(
                  icon,
                  size: isDesktop ? 24.0 : isTablet ? 20.0 : 18.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: isDesktop ? 16.0 : isTablet ? 12.0 : 10.0),
            ],
            
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: _getTitleStyle(context, isDesktop, isTablet),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: isDesktop ? 4.0 : 2.0),
                    Text(
                      subtitle!,
                      style: _getSubtitleStyle(context, isDesktop, isTablet),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  TextStyle _getTitleStyle(BuildContext context, bool isDesktop, bool isTablet) {
    final baseStyle = Theme.of(context).textTheme.headlineMedium;
    final fontSize = isDesktop ? 24.0 : isTablet ? 20.0 : 18.0;
    
    return baseStyle?.copyWith(
      color: AppColors.onBackground,
      fontWeight: FontWeight.w700,
      fontSize: fontSize,
      letterSpacing: -0.2,
    ) ?? TextStyle(
      color: AppColors.onBackground,
      fontWeight: FontWeight.w700,
      fontSize: fontSize,
      letterSpacing: -0.2,
    );
  }

  TextStyle _getSubtitleStyle(BuildContext context, bool isDesktop, bool isTablet) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    final fontSize = isDesktop ? 16.0 : isTablet ? 14.0 : 12.0;
    
    return baseStyle?.copyWith(
      color: AppColors.onSurfaceVariant,
      fontWeight: FontWeight.w400,
      fontSize: fontSize,
    ) ?? TextStyle(
      color: AppColors.onSurfaceVariant,
      fontWeight: FontWeight.w400,
      fontSize: fontSize,
    );
  }
}
