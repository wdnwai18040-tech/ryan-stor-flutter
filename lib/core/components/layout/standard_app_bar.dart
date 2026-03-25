import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/design/app_spacing.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';
import 'package:ryaaans_store/core/design/app_sizes.dart';
import 'package:ryaaans_store/core/design/app_shadows.dart';

class StandardAppBar extends StatelessWidget {
  final String title;
  final String? imagePath;
  final Widget? leading;
  final Widget? trailing;

  const StandardAppBar({
    super.key,
    required this.title,
    required this.imagePath,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);
    final canPop = ModalRoute.of(context)?.canPop ?? navigator.canPop();
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        final horizontalPadding = isNarrow ? AppSpacing.md : AppSpacing.lg;
        final baseImageSize = isNarrow
            ? AppSizes.headerImageSize - 20
            : AppSizes.headerImageSize;
        final imageSize = baseImageSize * 1.7;
        final hasImage = imagePath != null && imagePath!.isNotEmpty;
        final headerHeight =
            MediaQuery.of(context).padding.top +
            44 +
            AppSpacing.sm +
            (hasImage ? imageSize : 0) +
            AppSpacing.md +
            AppSpacing.sm;
        final leadingWidget =
            leading ??
            (canPop
                ? IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      if (navigator.canPop()) {
                        navigator.maybePop();
                      }
                    },
                  )
                : const SizedBox.shrink());
        final trailingWidget = trailing ?? const SizedBox.shrink();

        return Container(
          height: headerHeight,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            ),
            borderRadius: AppRadius.hero,
            boxShadow: AppShadows.hero(context),
          ),
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: horizontalPadding,
            right: horizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppSpacing.xs),
              SizedBox(
                height: 44,
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: AppRadius.chip,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.18),
                            ),
                          ),
                          child: leadingWidget,
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: AppRadius.chip,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.18),
                            ),
                          ),
                          child: trailingWidget,
                        ),
                      ],
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 56),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w400,
                            fontSize: isNarrow ? 18 : 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              if (hasImage)
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: AppRadius.chip,
                      child: Image.asset(
                        imagePath!,
                        height: imageSize,
                        width: imageSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }
}
