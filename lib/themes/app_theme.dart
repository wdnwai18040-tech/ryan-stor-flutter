// File: core/design/app_theme.dart

import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/design/app_colors.dart';
import 'package:ryaaans_store/core/design/app_typography.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';
import 'package:ryaaans_store/themes/transaction_card_theme.dart';
import 'package:ryaaans_store/themes/wallet_card_theme.dart';

class AppTheme {
  AppTheme._();

  // ================= SHADOW TOKENS (موحد لجميع التطبيق) =================
  static List<BoxShadow> get elegantShadow => [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 24,
      offset: const Offset(0, 10),
      spreadRadius: -5,
    ),
  ];

  static List<BoxShadow> get elegantShadowDark => [
    BoxShadow(
      color: AppColors.shadowDark,
      blurRadius: 26,
      offset: const Offset(0, 10),
      spreadRadius: -6,
    ),
  ];

  // ================= LIGHT =================
  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.primaryBlue,
      secondary: AppColors.accentSky,
      tertiary: AppColors.accentPurple,
      surface: AppColors.lightCard,
      surfaceContainerHighest: Color(0xFFF1F5F9),
      secondaryContainer: Color(0xFFDFF4FF),
      tertiaryContainer: Color(0xFFEDE4FF),
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimaryLight,
    );

    final textTheme = AppTypography.buildTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: textTheme,
      fontFamily: AppTypography.fontFamily,

      extensions: const <ThemeExtension<dynamic>>[
        TransactionCardTheme(
          backgroundColor: AppColors.lightCard,
          borderColor: Color(0x14000000),
          creditColor: AppColors.success,
          debitColor: AppColors.danger,
          textMuted: AppColors.textSecondaryLight,
          elevation: 6,
          borderRadius: 28,
        ),
        WalletCardTheme(
          backgroundColor: Color(0x883A66D6),
          borderColor: Color(0x8077A7FF),
          premiumBadgeBg: Color(0x335F8FFF),
          premiumBadgeFg: Color(0xFFD7E4FF),
          amountColor: Color(0xFFFDFEFF),
          labelColor: Color(0xCCE4EEFF),
          metaColor: Color(0xB3D1E0FF),
          elevation: 20,
          borderRadius: 22,
        ),
      ],

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
          foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimary),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadius.button),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        toolbarHeight: 64,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 22,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
      ),

      // ✅ Card Theme موحد مع الظل الأزرق
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0, // نستخدم boxShadow يدوياً للتحكم الكامل
        shadowColor: AppColors.shadowLight,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),

      // ✅ ListTile Theme موحد
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        iconColor: colorScheme.primary,
        textColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        dense: false,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        minVerticalPadding: 12,
      ),

      dividerColor: colorScheme.onSurface.withOpacity(0.06),
    );
  }

  // ================= DARK =================
  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.primaryBlue,
      secondary: AppColors.accentSky,
      tertiary: AppColors.accentPink,
      surface: AppColors.darkCard,
      surfaceContainerHighest: Color(0xFF1B2334),
      secondaryContainer: Color(0xFF0F2D3A),
      tertiaryContainer: Color(0xFF3A1C39),
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimaryDark,
    );

    final textTheme = AppTypography.buildTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme,
      fontFamily: AppTypography.fontFamily,

      extensions: const <ThemeExtension<dynamic>>[
        TransactionCardTheme(
          backgroundColor: AppColors.darkCard,
          borderColor: Color(0x1FFFFFFF),
          creditColor: AppColors.success,
          debitColor: AppColors.danger,
          textMuted: AppColors.textSecondaryDark,
          elevation: 6,
          borderRadius: 28,
        ),
        WalletCardTheme(
          backgroundColor: Color(0x883A66D6),
          borderColor: Color(0x8077A7FF),
          premiumBadgeBg: Color(0x335F8FFF),
          premiumBadgeFg: Color(0xFFD7E4FF),
          amountColor: Color(0xFFFDFEFF),
          labelColor: Color(0xCCE4EEFF),
          metaColor: Color(0xB3D1E0FF),
          elevation: 20,
          borderRadius: 22,
        ),
      ],

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
          foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimary),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadius.button),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground.withOpacity(0.95),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 64,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 22,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        actionsIconTheme: const IconThemeData(color: Colors.white, size: 24),
      ),

      // ✅ Dark Card Theme مع الظل الأزرق
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shadowColor: AppColors.shadowDark,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: const BorderSide(color: Color(0x33FFFFFF)),
        ),
      ),

      // ✅ Dark ListTile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        iconColor: colorScheme.primary,
        textColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
        dense: false,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        tileColor: colorScheme.surface.withOpacity(0.4),
        selectedTileColor: colorScheme.primary.withOpacity(0.15),
        minVerticalPadding: 12,
      ),

      dividerColor: Colors.white.withOpacity(0.08),
    );
  }
}
