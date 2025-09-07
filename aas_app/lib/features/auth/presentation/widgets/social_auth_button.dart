import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
  });
  final String text;
  final String icon; // Path to SVG icon
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _getTextColor(),
          backgroundColor: _getBackgroundColor(),
          side: BorderSide(
            color: _getBorderColor(),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getIconBackgroundColor(),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getIconData(),
                      size: 16,
                      color: _getIconColor(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _getTextColor(),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
      ),
    );
  }

  Color _getTextColor() {
    switch (text.toLowerCase()) {
      case 'google':
        return AppColors.googleBlue;
      case 'apple':
        return AppColors.appleBlack;
      default:
        return AppColors.onSurface;
    }
  }

  Color _getBackgroundColor() {
    switch (text.toLowerCase()) {
      case 'google':
        return Colors.white;
      case 'apple':
        return Colors.white;
      default:
        return AppColors.surfaceVariant.withValues(alpha: 0.3);
    }
  }

  Color _getBorderColor() {
    switch (text.toLowerCase()) {
      case 'google':
        return AppColors.googleBlue.withValues(alpha: 0.3);
      case 'apple':
        return AppColors.appleGray.withValues(alpha: 0.3);
      default:
        return AppColors.outline.withValues(alpha: 0.3);
    }
  }

  Color _getIconBackgroundColor() {
    switch (text.toLowerCase()) {
      case 'google':
        return Colors.transparent;
      case 'apple':
        return Colors.transparent;
      default:
        return AppColors.primary;
    }
  }

  Color _getIconColor() {
    switch (text.toLowerCase()) {
      case 'google':
        return AppColors.googleBlue;
      case 'apple':
        return AppColors.appleBlack;
      default:
        return Colors.white;
    }
  }

  IconData _getIconData() {
    switch (text.toLowerCase()) {
      case 'google':
        return Icons.g_mobiledata; // Placeholder for Google icon
      case 'apple':
        return Icons.apple; // Placeholder for Apple icon
      default:
        return Icons.account_circle;
    }
  }
}
