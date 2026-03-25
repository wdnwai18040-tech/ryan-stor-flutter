import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class TransactionCardTheme
    extends ThemeExtension<TransactionCardTheme> {
  final Color backgroundColor;
  final Color borderColor;
  final Color creditColor;
  final Color debitColor;
  final Color textMuted;
  final double elevation;
  final double borderRadius;

  const TransactionCardTheme({
    required this.backgroundColor,
    required this.borderColor,
    required this.creditColor,
    required this.debitColor,
    required this.textMuted,
    required this.elevation,
    required this.borderRadius,
  });

  @override
  TransactionCardTheme copyWith({
    Color? backgroundColor,
    Color? borderColor,
    Color? creditColor,
    Color? debitColor,
    Color? textMuted,
    double? elevation,
    double? borderRadius,
  }) {
    return TransactionCardTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      creditColor: creditColor ?? this.creditColor,
      debitColor: debitColor ?? this.debitColor,
      textMuted: textMuted ?? this.textMuted,
      elevation: elevation ?? this.elevation,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  TransactionCardTheme lerp(
    ThemeExtension<TransactionCardTheme>? other,
    double t,
  ) {
    if (other is! TransactionCardTheme) return this;

    return TransactionCardTheme(
      backgroundColor:
          Color.lerp(backgroundColor, other.backgroundColor, t)!,
      borderColor:
          Color.lerp(borderColor, other.borderColor, t)!,
      creditColor:
          Color.lerp(creditColor, other.creditColor, t)!,
      debitColor:
          Color.lerp(debitColor, other.debitColor, t)!,
      textMuted:
          Color.lerp(textMuted, other.textMuted, t)!,
      elevation: lerpDouble(elevation, other.elevation, t)!,
      borderRadius:
          lerpDouble(borderRadius, other.borderRadius, t)!,
    );
  }
}
