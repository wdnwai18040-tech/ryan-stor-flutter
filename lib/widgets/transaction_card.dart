import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/design/app_colors.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';
import 'package:ryaaans_store/models/wallet_transaction.dart';
import 'package:ryaaans_store/themes/transaction_card_theme.dart';
import 'package:ryaaans_store/core/widgets/price_text.dart';
import 'package:ryaaans_store/core/widgets/status_badge.dart';
// Suggest adding for cleaner dates

class TransactionCard extends StatelessWidget {
  final WalletTransaction transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final themeExtension = Theme.of(context).extension<TransactionCardTheme>()!;
    final theme = Theme.of(context);

    final isCredit = transaction.type == 'credit';
    final accentColor = isCredit
        ? themeExtension.creditColor
        : themeExtension.debitColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: themeExtension.backgroundColor,
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? AppColors.shadowDark
                : AppColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 1. Bold Action Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: AppRadius.button,
              ),
              child: Icon(
                isCredit ? Icons.add_rounded : Icons.remove_rounded,
                color: accentColor,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            // 2. Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${isCredit ? '+' : '-'} ',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  PriceText(
                    value: '${transaction.amount}',
                    color: accentColor,
                    size: PriceTextSize.compact,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'مرجع: ${transaction.reference}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: themeExtension.textMuted.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    // Format this as needed, simplified here
                    transaction.createdAt.toString().substring(0, 16),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: themeExtension.textMuted.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Bold Status Pill
            _buildStatusPill(transaction.status, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(String status, ThemeData theme) {
    if (status.toLowerCase() == 'completed' || status == 'success') {
      return const StatusBadge(label: 'مكتملة', type: AppStatusType.completed);
    }

    if (status.toLowerCase() == 'pending' ||
        status.toLowerCase() == 'processing') {
      return const StatusBadge(
        label: 'قيد المعالجة',
        type: AppStatusType.processing,
      );
    }

    return const StatusBadge(label: 'غير معروف', type: AppStatusType.neutral);
  }
}
