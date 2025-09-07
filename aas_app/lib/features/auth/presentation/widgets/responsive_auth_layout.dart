import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';

/// Responsive layout wrapper for authentication screens
///
/// Provides consistent layout across different screen sizes:
/// - Desktop: Centered card with max-width constraints
/// - Tablet: Centered card with medium width
/// - Mobile: Full-width with proper padding
class ResponsiveAuthLayout extends StatelessWidget {
  const ResponsiveAuthLayout({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.header,
    this.footer,
    this.showBackButton = false,
    this.onBackPressed,
  });
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? header;
  final Widget? footer;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Determine screen size
              final screenWidth = constraints.maxWidth;
              final isDesktop = screenWidth >= 1200;
              final isTablet = screenWidth >= 768 && screenWidth < 1200;
              final isMobile = screenWidth < 768;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop
                      ? 48.0
                      : isTablet
                          ? 32.0
                          : 24.0,
                  vertical: isDesktop ? 32.0 : 24.0,
                ),
                child: Column(
                  children: [
                    // Top spacing
                    SizedBox(
                        height: isDesktop
                            ? 60.0
                            : isTablet
                                ? 40.0
                                : 20.0),

                    // Back button (if needed)
                    if (showBackButton) ...[
                      _buildBackButton(context),
                      const SizedBox(height: 24),
                    ],

                    // Header section
                    if (header != null) ...[
                      header!,
                      SizedBox(
                          height: isDesktop
                              ? 48.0
                              : isTablet
                                  ? 32.0
                                  : 24.0),
                    ],

                    // Main content with responsive constraints
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isDesktop
                              ? 450.0
                              : isTablet
                                  ? 500.0
                                  : double.infinity,
                        ),
                        child: child,
                      ),
                    ),

                    // Footer section
                    if (footer != null) ...[
                      SizedBox(height: isDesktop ? 32.0 : 24.0),
                      footer!,
                    ],

                    // Bottom spacing
                    SizedBox(
                        height: isDesktop
                            ? 40.0
                            : isTablet
                                ? 32.0
                                : 24.0),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: onBackPressed ?? () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outline.withValues(alpha: 0.2),
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.onSurface,
            size: 20,
          ),
        ),
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(40, 40),
        ),
      ),
    );
  }
}

/// Responsive card container for auth forms
///
/// Provides consistent styling and responsive behavior
class ResponsiveAuthCard extends StatelessWidget {
  const ResponsiveAuthCard({
    super.key,
    required this.child,
    this.padding,
    this.showShadow = true,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet =
            constraints.maxWidth >= 768 && constraints.maxWidth < 1200;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              isDesktop
                  ? 24.0
                  : isTablet
                      ? 20.0
                      : 16.0,
            ),
            border: Border.all(
              color: AppColors.outline.withValues(alpha: 0.1),
            ),
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.1),
                      blurRadius: isDesktop
                          ? 20.0
                          : isTablet
                              ? 16.0
                              : 12.0,
                      offset: Offset(
                          0,
                          isDesktop
                              ? 8.0
                              : isTablet
                                  ? 6.0
                                  : 4.0),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              isDesktop
                  ? 24.0
                  : isTablet
                      ? 20.0
                      : 16.0,
            ),
            child: Padding(
              padding: padding ??
                  EdgeInsets.all(
                    isDesktop
                        ? 48.0
                        : isTablet
                            ? 40.0
                            : 32.0,
                  ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Responsive spacing utilities
class ResponsiveSpacing {
  static double getHorizontalPadding(double screenWidth) {
    return screenWidth >= 1200
        ? 48.0
        : screenWidth >= 768
            ? 32.0
            : 24.0;
  }

  static double getVerticalPadding(double screenWidth) {
    return screenWidth >= 1200 ? 32.0 : 24.0;
  }

  static double getCardPadding(double screenWidth) {
    return screenWidth >= 1200
        ? 48.0
        : screenWidth >= 768
            ? 40.0
            : 32.0;
  }

  static double getBorderRadius(double screenWidth) {
    return screenWidth >= 1200
        ? 24.0
        : screenWidth >= 768
            ? 20.0
            : 16.0;
  }
}
