import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/design/app_colors.dart';
import 'package:ryaaans_store/core/design/app_spacing.dart';
import 'package:ryaaans_store/core/widgets/base_card.dart';
import 'package:ryaaans_store/core/storage/utils/currency_formatter.dart';
import 'package:ryaaans_store/models/product.dart';
import 'package:ryaaans_store/screens/product_details_screen.dart';

class OffersSection extends StatelessWidget {
  final List<dynamic> offers;

  const OffersSection({super.key, required this.offers});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // قمت بزيادة الارتفاع قليلاً ليتناسب مع عرض الصورة والبيانات الجديدة
    const double sectionHeight = 210; 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.discount_rounded,
              color: theme.colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              "العروض والتخفيضات",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),

        SizedBox(height: AppSpacing.md),

        if (offers.isEmpty)
          BaseCard(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: const Center(
                child: Text("لا توجد عروض حالياً"),
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final int visibleItems = constraints.maxWidth < 420 ? 2 : 3;
              final double itemWidth = (constraints.maxWidth - (AppSpacing.md * (visibleItems - 1))) / visibleItems;

              return SizedBox(
                height: sectionHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: offers.length,
                  separatorBuilder: (_, _) => SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final offer = offers[index];

                    return SizedBox(
                      width: itemWidth,
                      child: BaseCard(
                        onTap: () {
                          final map = <String, dynamic>{
                            'id': offer.productId,
                            'name': offer.productName,
                            'image_url': offer.imageUrl,
                          };
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsScreen(
                                product: Product.fromJson(map),
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.sm),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // القسم العلوي: الصورة + ملصق اسم الفارينت
                              Expanded(
                                child: Stack(
                                  children: [
                                    // عرض صورة المنتج
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: offer.imageUrl != null 
                                          ? DecorationImage(
                                              image: NetworkImage(offer.imageUrl!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                        color: theme.colorScheme.primary.withOpacity(0.05),
                                      ),
                                      child: offer.imageUrl == null 
                                          ? Icon(Icons.image_not_supported, color: theme.colorScheme.primary.withOpacity(0.2))
                                          : null,
                                    ),
                                    
                                    // ملصق اسم الفارينت (مثل: 600 شدة)
                                    Positioned(
                                      bottom: 4,
                                      right: 4,
                                      left: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withOpacity(0.85),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          offer.variantName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              SizedBox(height: AppSpacing.sm),

                              // اسم المنتج الأساسي
                              Text(
                                offer.productName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              // نسبة الخصم
                              Text(
                                "خصم ${offer.discountPercentage.toStringAsFixed(0)}%",
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),

                              // السعر النهائي
                              Text(
                                "${CurrencyFormatter.format(offer.finalPrice)} ج.س",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}