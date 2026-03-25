import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';
import 'package:ryaaans_store/core/storage/utils/currency_formatter.dart';

import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/wallet_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>().user;
    final wallet = context.watch<WalletProvider>().wallet;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                Icon(
                  Icons.celebration_rounded,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),

                const SizedBox(height: 24),

                Text(
                  "مرحباً بك ${user?.username ?? ''} 👋",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "أهلاً بك في متجر الريان للخدمات الرقمية وشحن الألعاب 🎮",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 40),

                _buildInfoCard(
                  context,
                  icon: Icons.account_balance_wallet_rounded,
                  title: "رصيد البداية",
                  value: CurrencyFormatter.formatWithCurrency(
                    wallet?.balance ?? 0,
                  ),
                ),

                const SizedBox(height: 16),

                _buildInfoCard(
                  context,
                  icon: Icons.card_giftcard_rounded,
                  title: "مكافأة التسجيل",
                  value: "تم إضافة بونص ترحيبي إلى محفظتك",
                ),

                const SizedBox(height: 16),

                _buildInfoCard(
                  context,
                  icon: Icons.local_offer_rounded,
                  title: "نظام الكاش باك",
                  value: "احصل على كاش باك عند كل عملية شراء",
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AuthProvider>().clearNewUserFlag();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                    ),
                    child: Text(
                      "ابدأ التسوق الآن",
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
