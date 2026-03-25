// File: core/design/app_typography.dart

import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/design/app_colors.dart';

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Cairo'; // خط عربي حديث Sans-Serif كخط رئيسي

  static TextTheme buildTextTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    final baseColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return TextTheme(
      // === العناوين الرئيسية (ثقيل - Bold) ===
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 30,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 26,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: 1.3,
      ),

      // === عناوين الأقسام (شبه ثقيل - SemiBold) ===
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 21,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 19,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: 1.3,
      ),

      // === عناوين الكروت والعناصر (Medium) ===
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 19,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: 1.3,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: 1.3,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: 1.4,
      ),

      // === النصوص العادية (Regular - للقراءة) ===
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: secondaryColor, // ✅ لون ثانوي باهت
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: secondaryColor.withOpacity(0.7), // ✅ أفتح للنصوص الثانوية
        height: 1.5,
      ),

      // === النصوص الصغيرة جداً (Meta/Caption) ===
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: secondaryColor.withOpacity(0.6),
        height: 1.4,
      ),
    );
  }
}
