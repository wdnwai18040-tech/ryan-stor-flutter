import 'package:flutter/material.dart';

enum PriceTextSize { compact, normal, prominent }

class PriceText extends StatelessWidget {
  final String value;
  final Color? color;
  final TextAlign textAlign;
  final PriceTextSize size;

  const PriceText({
    super.key,
    required this.value,
    this.color,
    this.textAlign = TextAlign.start,
    this.size = PriceTextSize.normal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = _resolveVisual(theme);
    final baseStyle = visual.baseStyle ?? const TextStyle(fontSize: 18);

    return Text(
      value,
      textAlign: textAlign,
      style: baseStyle.copyWith(
        fontWeight: FontWeight.w400,
        letterSpacing: -0.15,
        color: color ?? theme.colorScheme.primary,
      ),
    );
  }

  _PriceVisual _resolveVisual(ThemeData theme) {
    switch (size) {
      case PriceTextSize.compact:
        return _PriceVisual(baseStyle: theme.textTheme.titleSmall);
      case PriceTextSize.normal:
        return _PriceVisual(baseStyle: theme.textTheme.titleMedium);
      case PriceTextSize.prominent:
        return _PriceVisual(baseStyle: theme.textTheme.titleLarge);
    }
  }
}

class _PriceVisual {
  final TextStyle? baseStyle;

  const _PriceVisual({required this.baseStyle});
}
