import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class WalletCardTheme extends ThemeExtension<WalletCardTheme> {
  final Color backgroundColor;
  final Color borderColor;
  final Color premiumBadgeBg;
  final Color premiumBadgeFg;
  final Color amountColor;
  final Color labelColor;
  final Color metaColor;
  final double elevation;
  final double borderRadius;

  const WalletCardTheme({
    required this.backgroundColor,
    required this.borderColor,
    required this.premiumBadgeBg,
    required this.premiumBadgeFg,
    required this.amountColor,
    required this.labelColor,
    required this.metaColor,
    required this.elevation,
    required this.borderRadius,
  });

  @override
  WalletCardTheme copyWith({
    Color? backgroundColor,
    Color? borderColor,
    Color? premiumBadgeBg,
    Color? premiumBadgeFg,
    Color? amountColor,
    Color? labelColor,
    Color? metaColor,
    double? elevation,
    double? borderRadius,
  }) {
    return WalletCardTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      premiumBadgeBg: premiumBadgeBg ?? this.premiumBadgeBg,
      premiumBadgeFg: premiumBadgeFg ?? this.premiumBadgeFg,
      amountColor: amountColor ?? this.amountColor,
      labelColor: labelColor ?? this.labelColor,
      metaColor: metaColor ?? this.metaColor,
      elevation: elevation ?? this.elevation,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  WalletCardTheme lerp(ThemeExtension<WalletCardTheme>? other, double t) {
    if (other is! WalletCardTheme) return this;

    return WalletCardTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      premiumBadgeBg: Color.lerp(premiumBadgeBg, other.premiumBadgeBg, t)!,
      premiumBadgeFg: Color.lerp(premiumBadgeFg, other.premiumBadgeFg, t)!,
      amountColor: Color.lerp(amountColor, other.amountColor, t)!,
      labelColor: Color.lerp(labelColor, other.labelColor, t)!,
      metaColor: Color.lerp(metaColor, other.metaColor, t)!,
      elevation: lerpDouble(elevation, other.elevation, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
    );
  }
}
