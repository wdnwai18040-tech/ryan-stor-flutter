// File: screens/wallet/transactions_page.dart

import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/components/layout/app_scaffold.dart';
import 'package:ryaaans_store/core/design/app_colors.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';
import '../../models/wallet_transaction.dart';
import '../../services/wallet_transaction_service.dart';
import 'package:ryaaans_store/widgets/transaction_card.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppScaffold(
      title: 'سجل المعاملات',
      backgroundColor: colorScheme.surface,
      body: FutureBuilder<List<WalletTransaction>>(
        future: WalletTransactionService().getMyTransactions(context),
        builder: (context, snapshot) {
          // 1️⃣ حالة التحميل
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'جاري تحميل المعاملات...',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          // 2️⃣ حالة الخطأ
          if (snapshot.hasError) {
            return _buildErrorState(
              context, // ✅ تمرير السياق
              colorScheme,
              textTheme,
              snapshot.error.toString(),
            );
          }

          // 3️⃣ حالة القائمة الفارغة
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(
              context, // ✅ تمرير السياق
              colorScheme,
              textTheme,
            );
          }

          final transactions = snapshot.data!;

          // 4️⃣ عرض القائمة بنجاح
          return RefreshIndicator(
            onRefresh: () async {
              await WalletTransactionService().getMyTransactions(context);
            },
            color: colorScheme.primary,
            backgroundColor: colorScheme.surface,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: transactions.length,
              separatorBuilder: (_, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  height: 1,
                  color: colorScheme.outline.withOpacity(0.1),
                ),
              ),
              itemBuilder: (context, i) {
                final t = transactions[i];
                return TransactionCard(transaction: t);
              },
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // 🎨 Empty State - ✅ تم إضافة context كـ parameter
  // ═══════════════════════════════════════════════════════

  Widget _buildEmptyState(
    BuildContext context, // ✅ إضافة السياق
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: _stateCardDecoration(context, colorScheme, isDark),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 56,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'لا توجد معاملات حتى الآن',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'عند إجراء أي عملية شحن أو شراء، ستظهر هنا تفاصيل المعاملة',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context), // ✅ الآن سيعمل
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: Text(
                  'العودة للرئيسية',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // 🎨 Error State - ✅ تم إضافة context كـ parameter
  // ═══════════════════════════════════════════════════════

  Widget _buildErrorState(
    BuildContext context, // ✅ إضافة السياق
    ColorScheme colorScheme,
    TextTheme textTheme,
    String errorMessage,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: _stateCardDecoration(context, colorScheme, isDark),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'عذراً، حدث خطأ ما',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage.length > 100
                    ? '${errorMessage.substring(0, 100)}...'
                    : errorMessage,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context), // ✅ الآن سيعمل
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  'إعادة المحاولة',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                  elevation: 4,
                  shadowColor: colorScheme.primary.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _stateCardDecoration(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: AppRadius.card,
      border: Border.all(color: colorScheme.onSurface.withOpacity(0.06)),
      boxShadow: [
        BoxShadow(
          color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ],
    );
  }
}
