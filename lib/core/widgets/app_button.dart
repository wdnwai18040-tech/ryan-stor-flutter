import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/design/app_colors.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onPressed == null || widget.isLoading) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDisabled = widget.onPressed == null;

    final textColor = _textColor(colors, isDisabled);

    return GestureDetector(
      onTap: isDisabled || widget.isLoading ? null : widget.onPressed,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: widget.fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: _gradient(isDisabled),
            color: _solidColor(colors, isDisabled),
            borderRadius: AppRadius.button,
            border: _border(colors, isDisabled),
            boxShadow: _shadow(isDisabled),
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              : Text(
                  widget.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
        ),
      ),
    );
  }

  List<BoxShadow> _shadow(bool isDisabled) {
    if (isDisabled || widget.variant != AppButtonVariant.primary)
      return const [];
    return const [
      BoxShadow(
        color: Color(0x332563EB),
        blurRadius: 14,
        spreadRadius: -4,
        offset: Offset(0, 6),
      ),
    ];
  }

  Gradient? _gradient(bool isDisabled) {
    if (isDisabled || widget.variant != AppButtonVariant.primary) return null;
    return const LinearGradient(
      colors: AppColors.primaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Border? _border(ColorScheme colors, bool isDisabled) {
    if (widget.variant == AppButtonVariant.secondary) {
      return Border.all(color: colors.primary.withOpacity(0.35));
    }
    if (widget.variant == AppButtonVariant.danger) {
      return Border.all(color: AppColors.danger.withOpacity(0.55));
    }
    if (widget.variant == AppButtonVariant.ghost) {
      return Border.all(color: Colors.transparent);
    }
    if (isDisabled) {
      return Border.all(color: AppColors.disabledBackground);
    }
    return null;
  }

  Color? _solidColor(ColorScheme colors, bool isDisabled) {
    if (isDisabled) return AppColors.disabledBackground;
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return null;
      case AppButtonVariant.secondary:
        return colors.surface;
      case AppButtonVariant.ghost:
        return Colors.transparent;
      case AppButtonVariant.danger:
        return AppColors.danger;
    }
  }

  Color _textColor(ColorScheme colors, bool isDisabled) {
    if (isDisabled) return AppColors.disabledText;
    switch (widget.variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return colors.onPrimary;
      case AppButtonVariant.secondary:
      case AppButtonVariant.ghost:
        return colors.primary;
    }
  }
}
