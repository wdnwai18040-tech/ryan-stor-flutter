// File: core/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/design/app_colors.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? pageImage; // صورة هوية الصفحة (أيقونة أو بانر صغير)
  final List<Widget>? actions;
  final bool showBackButton;
  final double? elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.pageImage,
    this.actions,
    this.showBackButton = true,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBackground.withOpacity(0.95)
            : AppColors.lightBackground.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // الصف العلوي: زر الرجوع + الأكشنز (متوازن)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: showBackButton
                        ? _buildBackButton(context, isDark)
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(
                    height: 40,
                    child: actions != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: actions!,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // الصف السفلي: العناصر في المنتصف (صورة ثم عنوان)
              Column(
                children: [
                  if (pageImage != null && pageImage!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: AppRadius.chip,
                      child: Image.asset(
                        pageImage!,
                        height: 72,
                        width: 72,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Text(
                    title,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 22,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pop(context),
        borderRadius: AppRadius.button,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: AppRadius.button,
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(170);
}
