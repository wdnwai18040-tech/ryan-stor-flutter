import 'package:flutter/material.dart';
import '../design/app_spacing.dart';
import 'app_card.dart';

class BaseCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;

  const BaseCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.border,
  });

  @override
  State<BaseCard> createState() => _BaseCardState();
}

class _BaseCardState extends State<BaseCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: AppCard(
          onTap: null,
          padding: widget.padding ?? const EdgeInsets.all(AppSpacing.md),
          border: widget.border,
          child: widget.child,
        ),
      ),
    );
  }
}
