import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';

enum ButtonVariant { filled, outlined, text }

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = ButtonVariant.filled,
    this.width,
    this.height = 56,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final ButtonVariant variant;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle(context);
    final textStyle = _getTextStyle(context);

    return SizedBox(
      width: width,
      height: height,
      child: variant == ButtonVariant.filled
          ? ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: buttonStyle,
              child: _buildButtonContent(textStyle),
            )
          : variant == ButtonVariant.outlined
              ? OutlinedButton(
                  onPressed: isLoading ? null : onPressed,
                  style: buttonStyle,
                  child: _buildButtonContent(textStyle),
                )
              : TextButton(
                  onPressed: isLoading ? null : onPressed,
                  style: buttonStyle,
                  child: _buildButtonContent(textStyle),
                ),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    switch (variant) {
      case ButtonVariant.filled:
        return ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        );
      case ButtonVariant.outlined:
        return OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        );
      case ButtonVariant.text:
        return TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        );
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        );

    switch (variant) {
      case ButtonVariant.filled:
        return baseStyle?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ) ??
            const TextStyle();
      case ButtonVariant.outlined:
      case ButtonVariant.text:
        return baseStyle?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ) ??
            const TextStyle();
    }
  }

  Widget _buildButtonContent(TextStyle textStyle) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == ButtonVariant.filled ? Colors.white : AppColors.primary,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(text, style: textStyle);
  }
}
