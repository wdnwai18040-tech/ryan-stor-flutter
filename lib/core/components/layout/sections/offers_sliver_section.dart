import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/design/app_colors.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';
import 'package:ryaaans_store/core/design/app_shadows.dart';
import 'package:ryaaans_store/core/design/app_spacing.dart';
import 'package:ryaaans_store/models/discounted_offer.dart';

class OffersSliverSection extends StatelessWidget {
  final List<DiscountedOffer> offers;

  const OffersSliverSection({super.key, required this.offers});

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("العروض المميزة", style: textTheme.titleLarge),

            const SizedBox(height: AppSpacing.lg),

            SizedBox(
              height: 150,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.9),
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];

                  final String productName = offer.productName;
                  final String variantName = offer.variantName;
                  final double originalPrice = offer.originalPrice;
                  final double finalPrice = offer.finalPrice;
                  final double discount = offer.discountPercentage;

                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.lg),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: AppRadius.card,
                            boxShadow: AppShadows.card(context),
                          ),
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(productName, style: textTheme.titleMedium),
                              const SizedBox(height: AppSpacing.xs),
                              Text(variantName, style: textTheme.bodyMedium),
                              const SizedBox(height: AppSpacing.md),

                              // السعر القديم
                              Text(
                                "${originalPrice.toStringAsFixed(0)} ر.س",
                                style: textTheme.bodyMedium?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),

                              // السعر بعد الخصم
                              Text(
                                "${finalPrice.toStringAsFixed(0)} ر.س",
                                style: textTheme.titleLarge?.copyWith(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Badge نسبة الخصم
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              "-${discount.toStringAsFixed(0)}%",
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
