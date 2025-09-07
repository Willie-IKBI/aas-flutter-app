import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class InlineEditableText extends StatefulWidget {
  const InlineEditableText({
    super.key,
    required this.initialValue,
    required this.onSave,
    this.onCancel,
    this.enabled = true,
    this.validator,
    this.textStyle,
    this.hintText,
    this.maxLength = 50,
  });
  final String initialValue;
  final String? hintText;
  final Function(String) onSave;
  final Function()? onCancel;
  final bool enabled;
  final String? Function(String?)? validator;
  final TextStyle? textStyle;
  final int maxLength;

  @override
  State<InlineEditableText> createState() => _InlineEditableTextState();
}

class _InlineEditableTextState extends State<InlineEditableText> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;
  String _originalValue = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _originalValue = widget.initialValue;

    // Remove automatic cancel on focus loss to prevent interference with save button
    // _focusNode.addListener(() {
    //   if (!_focusNode.hasFocus && _isEditing) {
    //     _cancelEdit();
    //   }
    // });
  }

  @override
  void didUpdateWidget(InlineEditableText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update the controller and original value when the initial value changes
    if (oldWidget.initialValue != widget.initialValue && !_isEditing) {
      _controller.text = widget.initialValue;
      _originalValue = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEdit() {
    if (!widget.enabled) return;

    setState(() {
      _isEditing = true;
      _originalValue = _controller.text;
    });

    // Focus the text field after a short delay to ensure it's rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  void _saveEdit() {
    final newValue = _controller.text.trim();

// Validate if validator is provided
    if (widget.validator != null) {
      final validationResult = widget.validator!(newValue);
      if (validationResult != null) {
// Show error and don't save
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationResult),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    if (newValue != _originalValue) {
      widget.onSave(newValue);
    } else {}

    setState(() {
      _isEditing = false;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _controller.text = _originalValue;
    });
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLength: widget.maxLength,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: AppColors.outline.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                counterText: '', // Hide character counter
              ),
              style: widget.textStyle,
              onSubmitted: (_) => _saveEdit(),
            ),
          ),
          const SizedBox(width: 8),
          // Save button
          IconButton(
            onPressed: () {
              _saveEdit();
            },
            icon: const Icon(Icons.check, color: Colors.green),
            tooltip: 'Save',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          // Cancel button
          IconButton(
            onPressed: _cancelEdit,
            icon: const Icon(Icons.close, color: Colors.red),
            tooltip: 'Cancel',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            widget.initialValue.isEmpty
                ? (widget.hintText ?? 'No name')
                : widget.initialValue,
            style: widget.textStyle?.copyWith(
              color: widget.initialValue.isEmpty
                  ? AppColors.onBackground.withValues(alpha: 0.5)
                  : widget.textStyle?.color,
            ),
          ),
        ),
        if (widget.enabled) ...[
          const SizedBox(width: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: IconButton(
              onPressed: _startEdit,
              icon: const Icon(Icons.edit, size: 16, color: AppColors.primary),
              tooltip: 'Edit display name',
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ],
    );
  }
}
