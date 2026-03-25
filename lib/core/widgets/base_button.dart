import 'package:flutter/material.dart';
import 'app_button.dart';

enum ButtonVariant { primary, secondary, ghost, danger }

class BaseButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;

  const BaseButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  State<BaseButton> createState() => _BaseButtonState();
}

class _BaseButtonState extends State<BaseButton> {
  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: widget.label,
      onPressed: widget.onPressed,
      isLoading: widget.isLoading,
      fullWidth: widget.fullWidth,
      variant: _mapVariant(widget.variant),
    );
  }

  AppButtonVariant _mapVariant(ButtonVariant variant) {
    switch (variant) {
      case ButtonVariant.primary:
        return AppButtonVariant.primary;
      case ButtonVariant.secondary:
        return AppButtonVariant.secondary;
      case ButtonVariant.ghost:
        return AppButtonVariant.ghost;
      case ButtonVariant.danger:
        return AppButtonVariant.danger;
    }
  }
}
