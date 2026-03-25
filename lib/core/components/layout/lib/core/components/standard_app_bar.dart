import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/design/app_spacing.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';

class StandardAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final String imagePath;
  final Widget? leading;

  const StandardAppBar({
    super.key,
    required this.title,
    required this.imagePath,
    this.leading,
  });

  static const double _height = 140;

  @override
  Size get preferredSize =>
      const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      toolbarHeight: _height,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: theme.colorScheme.primary,
      leading: leading,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.hero, // ✅ Correct usage
      ),
      titleSpacing: AppSpacing.md,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.card,
            child: Image.asset(
              imagePath,
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
