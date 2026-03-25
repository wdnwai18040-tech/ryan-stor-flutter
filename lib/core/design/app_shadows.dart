import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  static List<BoxShadow> hero(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return [
        BoxShadow(
          color: AppColors.primaryBlue.withOpacity(0.25),
          blurRadius: 24,
          offset: const Offset(0, 10),
          spreadRadius: -4,
        ),
      ];
    }

    return [
      BoxShadow(
        color: AppColors.primaryBlue.withOpacity(0.14),
        blurRadius: 24,
        offset: const Offset(0, 10),
        spreadRadius: -6,
      ),
    ];
  }

  static List<BoxShadow> card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return [
        BoxShadow(
          color: AppColors.primaryBlue.withOpacity(0.18),
          blurRadius: 18,
          offset: const Offset(0, 8),
          spreadRadius: -6,
        ),
      ];
    }

    return [
      BoxShadow(
        color: AppColors.primaryBlue.withOpacity(0.11),
        blurRadius: 18,
        offset: const Offset(0, 8),
        spreadRadius: -8,
      ),
    ];
  }
}
