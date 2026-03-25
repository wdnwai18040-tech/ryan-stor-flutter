import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/design/app_colors.dart';
import 'package:ryaaans_store/core/design/app_spacing.dart';
import 'package:ryaaans_store/core/widgets/base_card.dart';
import 'package:ryaaans_store/core/storage/utils/currency_formatter.dart';
import 'package:ryaaans_store/models/product.dart';
import 'package:ryaaans_store/screens/product_details_screen.dart';

class PopularProductsSection extends StatelessWidget {
  final List<dynamic> products;

  const PopularProductsSection({super.key, required this.products});

  static String? _normalizeImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final value = url.trim();
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    const base = 'https://api.ryanstor.com';
    if (value.startsWith('/')) return '$base$value';
    return '$base/$value';
  }

  static List<String> _imageCandidates(String? rawUrl) {
    final normalized = _normalizeImageUrl(rawUrl);
    if (normalized == null || normalized.isEmpty) return const [];
    final value = normalized.trim();

    if (value.startsWith('http://') || value.startsWith('https://')) {
      final candidates = <String>[value];
      final uri = Uri.tryParse(value);
      final path = uri?.path ?? '';
      if (path.isNotEmpty) {
        candidates.add('https://api.ryanstor.com$path');
        candidates.add('https://ryanstor.com$path');
        candidates.add('http://145.223.34.121:3000$path');
      }
      return candidates.toSet().toList();
    }
    return const [];
  }

  static Widget _networkWithFallback(
    List<String> candidates,
    int index,
    Widget fallback,
  ) {
    if (index >= candidates.length) return fallback;
    return Image.network(
      candidates[index],
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) =>
          _networkWithFallback(candidates, index + 1, fallback),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double sectionHeight = 182;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: theme.colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              "الأكثر مبيعاً",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),

        SizedBox(height: AppSpacing.md),

        /// Empty State
        if (products.isEmpty)
          BaseCard(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Text(
                  "لا توجد منتجات حالياً",
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final int visibleItems = constraints.maxWidth < 420 ? 2 : 3;
              final double itemWidth =
                  (constraints.maxWidth -
                      (AppSpacing.md * (visibleItems - 1))) /
                  visibleItems;

              return SizedBox(
                height: sectionHeight,
                child: Stack(
                  children: [
                    ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length,
                      separatorBuilder: (_, _) =>
                          SizedBox(width: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final product = products[index];

                        final rawImage =
                            product['image_url'] ??
                            product['imageUrl'] ??
                            product['image'] ??
                            product['photo'];
                        final imageCandidates = _imageCandidates(
                          rawImage?.toString(),
                        );

                        final String name = product['name'] ?? "";

                        final String priceRaw =
                            product['price']?.toString() ?? "0";
                        final double price = double.tryParse(priceRaw) ?? 0;

                        final String sales =
                            product['sales_count']?.toString() ?? "0";

                        return SizedBox(
                          width: itemWidth,
                          child: BaseCard(
                            onTap: () {
                              final map = Map<String, dynamic>.from(product);

                              // لو جاي من top-popular استخدم product_id
                              if (map.containsKey('product_id')) {
                                map['id'] = map['product_id'];
                              }

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailsScreen(
                                    product: Product.fromJson(map),
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.xs),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            child: imageCandidates.isNotEmpty
                                                ? _networkWithFallback(
                                                    imageCandidates,
                                                    0,
                                                    Container(
                                                      color: theme
                                                          .colorScheme
                                                          .primary
                                                          .withOpacity(0.08),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Icon(
                                                        Icons.image_rounded,
                                                        size: 28,
                                                        color: theme
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    color: theme
                                                        .colorScheme
                                                        .primary
                                                        .withOpacity(0.08),
                                                    alignment: Alignment.center,
                                                    child: Icon(
                                                      Icons.image_rounded,
                                                      size: 28,
                                                      color: theme
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary
                                                  .withOpacity(0.9),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              "$sales مبيعة",
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onPrimary,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: AppSpacing.sm),

                                  /// 🏷 اسم المنتج
                                  Text(
                                    name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  SizedBox(height: AppSpacing.xs),

                                  /// 💰 السعر
                                  Text(
                                    "${CurrencyFormatter.format(price)} جنيه",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w400,
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
                    Positioned(
                      left: 6,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: Center(
                          child: Icon(
                            Icons.chevron_left_rounded,
                            size: 28,
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.35,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 6,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: Center(
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 28,
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.35,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
