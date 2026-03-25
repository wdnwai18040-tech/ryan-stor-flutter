import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryaaans_store/core/design/app_colors.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';
import 'package:ryaaans_store/core/design/app_spacing.dart';
import 'package:ryaaans_store/core/storage/utils/currency_formatter.dart';
import 'package:ryaaans_store/providers/wallet_provider.dart';

class WalletBalanceChip extends StatelessWidget {
  final bool compact;

  const WalletBalanceChip({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final String balanceText =
        "${CurrencyFormatter.format(wallet.balance)} جنيه";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: compact ? AppSpacing.xs : AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        balanceText,
        style: compact ? textTheme.labelLarge : textTheme.titleMedium,
      ),
    );
  }
}
