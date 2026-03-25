import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/components/layout/chips/wallet_balance_chip.dart';
import '../../design/app_spacing.dart';
import '../../design/app_shadows.dart';
import '../../design/app_radius.dart';

class HeroSliverAppBar extends SliverPersistentHeaderDelegate {
  final String title;
  final String subtitle;
  final String mascotAsset;
  final Gradient backgroundGradient;

  HeroSliverAppBar({
    required this.title,
    required this.subtitle,
    required this.mascotAsset,
    required this.backgroundGradient,
  });

  @override
  double get minExtent => kToolbarHeight + AppSpacing.lg;

  @override
  double get maxExtent => 240;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress =
        (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final isCollapsed = progress > 0.6;

    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: backgroundGradient,
        borderRadius: AppRadius.hero,
        boxShadow: AppShadows.hero(context),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Stack(
            children: [

              /// CHARACTER
              if (!isCollapsed)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Transform.scale(
                    scale: 1 - (progress * 0.15),
                    child: Image.asset(
                      mascotAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

              /// RIGHT CONTENT
              Align(
                alignment: Alignment.centerRight,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: Column(
                    mainAxisAlignment: isCollapsed
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: isCollapsed
                            ? textTheme.titleLarge
                            : textTheme.displayLarge,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      if (!isCollapsed)
                        Text(
                          subtitle,
                          style: textTheme.bodyMedium,
                        ),
                      SizedBox(height: AppSpacing.sm),
                      WalletBalanceChip(
                        compact: isCollapsed,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HeroSliverAppBar oldDelegate) {
    return oldDelegate.title != title ||
        oldDelegate.subtitle != subtitle ||
        oldDelegate.backgroundGradient != backgroundGradient ||
        oldDelegate.mascotAsset != mascotAsset;
  }
}
