import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/storage/utils/currency_formatter.dart';

class WalletBalanceCard extends StatelessWidget {
  final double balance;

  const WalletBalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.primary.withOpacity(0.08),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: theme.colorScheme.primary,
            size: 26,
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Text(
              "رصيدك",
              style: theme.textTheme.bodyMedium,
            ),
          ),

          Text(
            "${CurrencyFormatter.format(balance)} جنيه",
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}