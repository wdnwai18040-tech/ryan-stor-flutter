// File: screens/settings/settings_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/components/layout/app_scaffold.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import 'account_settings_page.dart';
import 'change_password_page.dart';
import 'package:ryaaans_store/core/design/app_colors.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';
import 'package:ryaaans_store/core/design/app_shadows.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppScaffold(
        title: 'الإعدادات',
        imagePath: 'assets/mascot/settings.png',
        backgroundColor: colorScheme.surface,
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            _Section(
              title: 'المظهر',
              children: [
                _SettingsTile(
                  icon: context.watch<ThemeProvider>().isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  title: context.watch<ThemeProvider>().isDark
                      ? 'الوضع النهاري'
                      : 'الوضع الليلي',
                  subtitle: 'تبديل ثيم التطبيق',
                  onTap: () => context.read<ThemeProvider>().toggleTheme(),
                  theme: theme,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ],
            ),
            const SizedBox(height: 32),
            _Section(
              title: 'إعدادات الحساب',
              children: [
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'بيانات الحساب',
                  subtitle: 'البريد، رقم الهاتف، والاسم',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AccountSettingsPage(),
                    ),
                  ),
                  theme: theme,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                _SettingsTile(
                  icon: Icons.lock_reset_rounded,
                  title: 'تغيير كلمة المرور',
                  subtitle: 'تحديث أمان حسابك',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordPage(),
                    ),
                  ),
                  theme: theme,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ],
            ),
            const SizedBox(height: 32),
            _Section(
              title: 'الحماية والخروج',
              children: [
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  title: 'تسجيل الخروج',
                  subtitle: 'سيتم إنهاء جلستك الحالية',
                  iconColor: AppColors.danger,
                  textColor: AppColors.danger,
                  onTap: () =>
                      _showLogoutDialog(context, textTheme, colorScheme),
                  theme: theme,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        backgroundColor: colorScheme.surface,
        title: Text(
          'تسجيل الخروج',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w400, // ✅ عريض ولكن متوازن
          ),
        ),
        content: Text(
          'هل أنت متأكد أنك تريد مغادرة الحساب؟',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w400, // ✅ نص ثانوي خفيف
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
              elevation: 2,
            ),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(
              'خروج',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// 🎨 _Section: قسم موحد مع الثيم
// ═══════════════════════════════════════════════════════

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12, bottom: 12),
          child: Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w400, // ✅ عنوان قسم: عريض ولكن مريح
              color: colorScheme.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AppRadius.card, // ✅ موحد: 20px
            boxShadow: AppShadows.card(context),
            border: Border.all(
              color: colorScheme.outline.withOpacity(
                0.1,
              ), // ✅ حد خفيف جداً للأناقة
            ),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.card,
            child: Column(children: _addDividers(children, theme, colorScheme)),
          ),
        ),
      ],
    );
  }

  List<Widget> _addDividers(
    List<Widget> items,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final widgets = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      widgets.add(items[i]);
      if (i != items.length - 1) {
        widgets.add(
          Divider(
            height: 1,
            indent: 70,
            endIndent: 20,
            color: colorScheme.outline.withOpacity(
              0.2,
            ), // ✅ موحد مع DividerColor
          ),
        );
      }
    }
    return widgets;
  }
}

// ═══════════════════════════════════════════════════════
// 🎨 _SettingsTile: عنصر إعدادات موحد مع الثيم
// ═══════════════════════════════════════════════════════

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.textColor,
    required this.theme,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: colorScheme.primary.withOpacity(
          0.08,
        ), // ✅ تأثير ناعم عند الضغط
        highlightColor: Colors.transparent,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              // ✅ أيقونة داخل حاوية أنيقة
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (iconColor ?? colorScheme.primary).withOpacity(0.12),
                  borderRadius: AppRadius.button,
                  border: Border.all(
                    color: (iconColor ?? colorScheme.primary).withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),

              // ✅ النصوص: هرمية واضحة
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w400, // ✅ عنوان: متوسط العريض
                        color: textColor ?? colorScheme.onSurface,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w400, // ✅ نص ثانوي: خفيف
                        color: colorScheme.onSurface.withOpacity(0.65),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ سهم التنقل
              Icon(
                Icons.chevron_left_rounded,
                size: 18,
                color: colorScheme.onSurface.withOpacity(0.5), // ✅ باهت للتنقل
              ),
            ],
          ),
        ),
      ),
    );
  }
}
