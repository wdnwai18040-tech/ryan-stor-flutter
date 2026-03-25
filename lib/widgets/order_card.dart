// File: widgets/order_card.dart

import 'package:flutter/material.dart';
import 'package:ryaaans_store/models/order_model.dart';
import 'package:ryaaans_store/screens/orders/order_details_page.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';
import 'package:ryaaans_store/core/storage/utils/currency_formatter.dart';
import 'package:ryaaans_store/core/widgets/price_text.dart';
import 'package:ryaaans_store/core/widgets/status_badge.dart';

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final orderStatus = OrderStatus.from(order.status);
    final productTitle = order.productName.trim().isNotEmpty
        ? order.productName
        : order.variantName;
    final showVariantLine =
        order.variantName.trim().isNotEmpty &&
        order.variantName.trim() != productTitle.trim();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -6,
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailsPage(orderId: order.id),
              ),
            ),
            splashColor: colorScheme.primary.withOpacity(0.08),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productTitle,
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (showVariantLine) ...[
                              const SizedBox(height: 4),
                              Text(
                                order.variantName,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(
                                    0.65,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(
                        label: orderStatus.label,
                        type: orderStatus.badgeType,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PriceText(
                        value:
                            '${CurrencyFormatter.format(order.totalAmount)} جنيه',
                        color: colorScheme.primary,
                        size: PriceTextSize.compact,
                      ),
                      Text(
                        '#${order.id}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  Text(
                    _formatDate(order.createdAt),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

enum OrderStatus {
  completed,
  processing;

  static OrderStatus from(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return OrderStatus.completed;
      case 'processing':
      case 'pending':
      case 'in_progress':
        return OrderStatus.processing;
      default:
        return OrderStatus.processing;
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.completed:
        return 'مكتمل';
      case OrderStatus.processing:
        return 'قيد التنفيذ';
    }
  }

  AppStatusType get badgeType {
    switch (this) {
      case OrderStatus.completed:
        return AppStatusType.completed;
      case OrderStatus.processing:
        return AppStatusType.processing;
    }
  }
}
