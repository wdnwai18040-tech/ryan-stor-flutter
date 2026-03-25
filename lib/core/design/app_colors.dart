// File: core/design/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ================= PRIMARY =================
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueDark = Color(0xFF1D4ED8);
  static const Color accentSky = Color(0xFF38BDF8);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentPink = Color(0xFFEC4899);

  // Soft primary (20% opacity)
  static const Color primarySoft = Color(0x332563EB);

  // ================= SHADOW COLORS (جديد) =================
  // ظل أزرق/بنفسجي خفيف موحد لجميع التطبيق
  static const Color shadowLight = Color(0x1F2563EB); // 12% opacity لللايت مود
  static const Color shadowDark = Color(0x332563EB); // 20% opacity للدارك مود

  // ================= LIGHT MODE =================
  static const Color lightBackground = Color(0xFFF7F9FC);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Glass effect (60% opacity)
  static const Color glassLight = Color(0x99F8FAFC);

  // ================= DARK MODE =================
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkCard = Color(0xFF121A2B);

  // Glass effect (60% opacity)
  static const Color glassDark = Color(0x99121A2B);

  // ================= TEXT =================
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // ================= BUTTON SYSTEM =================
  static const Color outlineBorder = Color(0xFFE2E8F0);
  static const Color ghostText = primaryBlue;

  static const Color disabledBackground = Color(0xFFE5E7EB);
  static const Color disabledText = Color(0xFF9CA3AF);

  // Transparent token
  static const Color transparent = Color(0x00000000);

  // ================= STATUS =================
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // ================= BUTTON GRADIENT =================
  static const List<Color> primaryGradient = [primaryBlue, primaryBlueDark];
}
