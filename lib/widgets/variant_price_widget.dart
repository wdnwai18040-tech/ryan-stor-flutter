import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/storage/utils/currency_formatter.dart';
import '../../models/product.dart';

class VariantPriceWidget extends StatelessWidget {
  final ProductVariant variant;

  const VariantPriceWidget({super.key, required this.variant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!variant.isDiscountActive) {
      return Text(
        "${CurrencyFormatter.format(variant.price)} جنيه",
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Row(
      children: [
        Text(
          "${CurrencyFormatter.format(variant.finalPrice)} جنيه",
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(width: 8),

        Text(
          CurrencyFormatter.format(variant.price),
          style: theme.textTheme.bodySmall?.copyWith(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
          ),
        ),

        const SizedBox(width: 4),

        Text(
          "جنيه",
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),

        const SizedBox(width: 6),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "-${variant.discountPercentage?.toInt() ?? 0}%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}