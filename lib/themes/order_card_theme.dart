import 'dart:ui';
import 'package:flutter/material.dart';

@immutable
class OrderCardTheme extends ThemeExtension<OrderCardTheme> {
  final Color backgroundColor;
  final Color borderColor;

  final Color statusPending;
  final Color statusCompleted;
  final Color statusCanceled;

  // 🆕 Text styles
  final TextStyle titleStyle;   // اسم المنتج (Bold)
  final TextStyle dateStyle;    // التاريخ (خفيف)
  final TextStyle priceStyle;   // السعر (Medium)
  final TextStyle statusStyle;  // حالة الطلب

  final double elevation;
  final double borderRadius;

  const OrderCardTheme({
    required this.backgroundColor,
    required this.borderColor,
    required this.statusPending,
    required this.statusCompleted,
    required this.statusCanceled,
    required this.titleStyle,
    required this.dateStyle,
    required this.priceStyle,
    required this.statusStyle,
    required this.elevation,
    required this.borderRadius,
  });

  @override
  OrderCardTheme copyWith({
    Color? backgroundColor,
    Color? borderColor,
    Color? statusPending,
    Color? statusCompleted,
    Color? statusCanceled,
    TextStyle? titleStyle,
    TextStyle? dateStyle,
    TextStyle? priceStyle,
    TextStyle? statusStyle,
    double? elevation,
    double? borderRadius,
  }) {
    return OrderCardTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      statusPending: statusPending ?? this.statusPending,
      statusCompleted: statusCompleted ?? this.statusCompleted,
      statusCanceled: statusCanceled ?? this.statusCanceled,
      titleStyle: titleStyle ?? this.titleStyle,
      dateStyle: dateStyle ?? this.dateStyle,
      priceStyle: priceStyle ?? this.priceStyle,
      statusStyle: statusStyle ?? this.statusStyle,
      elevation: elevation ?? this.elevation,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  OrderCardTheme lerp(ThemeExtension<OrderCardTheme>? other, double t) {
    if (other is! OrderCardTheme) return this;

    return OrderCardTheme(
      backgroundColor:
          Color.lerp(backgroundColor, other.backgroundColor, t)!,
      borderColor:
          Color.lerp(borderColor, other.borderColor, t)!,
      statusPending:
          Color.lerp(statusPending, other.statusPending, t)!,
      statusCompleted:
          Color.lerp(statusCompleted, other.statusCompleted, t)!,
      statusCanceled:
          Color.lerp(statusCanceled, other.statusCanceled, t)!,

      titleStyle:
          TextStyle.lerp(titleStyle, other.titleStyle, t)!,
      dateStyle:
          TextStyle.lerp(dateStyle, other.dateStyle, t)!,
      priceStyle:
          TextStyle.lerp(priceStyle, other.priceStyle, t)!,
      statusStyle:
          TextStyle.lerp(statusStyle, other.statusStyle, t)!,

      elevation: lerpDouble(elevation, other.elevation, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
    );
  }
}
