import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';

class PartFormField extends StatelessWidget {
  const PartFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.suffixIcon,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            prefixIcon,
            color: AppColors.onSurfaceVariant,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          labelStyle: const TextStyle(
            color: AppColors.onSurfaceVariant,
          ),
          hintStyle: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        style: const TextStyle(
          color: AppColors.onBackground,
          fontSize: 14,
        ),
      ),
    );
  }
}
