import 'package:flutter/material.dart';
import 'package:ryaaans_store/models/order_model.dart';
import 'package:ryaaans_store/services/order_service.dart';
import 'package:ryaaans_store/widgets/order_card.dart';
import 'package:ryaaans_store/core/components/layout/app_scaffold.dart';
import 'package:ryaaans_store/core/design/app_colors.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  // نستخدم late للتمكن من تحديث القائمة عند السحب (Pull to refresh)
  late Future<List<Order>> _ordersFuture;
  int _currentPage = 1;
  static const int _pageSize = 8;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    _ordersFuture = OrderService().getMyOrders(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'طلباتي',
      imagePath: 'assets/mascot/orders.webp',
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _currentPage = 1;
            _loadOrders();
          });
        },
        child: FutureBuilder<List<Order>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            // 1. حالة التحميل
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingSkeleton(theme);
            }

            // 2. حالة الخطأ
            if (snapshot.hasError) {
              return _buildErrorState(theme);
            }

            // 3. حالة القائمة الفارغة
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState(theme);
            }

            final orders = snapshot.data!;
            final totalPages = (orders.length / _pageSize).ceil().clamp(
              1,
              9999,
            );
            if (_currentPage > totalPages) {
              _currentPage = totalPages;
            }
            final start = (_currentPage - 1) * _pageSize;
            final end = (start + _pageSize).clamp(0, orders.length);
            final pagedOrders = orders.sublist(start, end);

            // 4. عرض القائمة بنجاح
            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final isDesktopLike = width >= 760;

                    if (!isDesktopLike) {
                      return Column(
                        children: [
                          for (var i = 0; i < pagedOrders.length; i++) ...[
                            OrderCard(order: pagedOrders[i]),
                            if (i != pagedOrders.length - 1)
                              const SizedBox(height: 8),
                          ],
                        ],
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pagedOrders.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.45,
                          ),
                      itemBuilder: (_, i) {
                        return OrderCard(order: pagedOrders[i]);
                      },
                    );
                  },
                ),
                if (totalPages > 1) ...[
                  const SizedBox(height: 10),
                  _buildPagination(theme, totalPages),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPagination(ThemeData theme, int totalPages) {
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.button,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _currentPage > 1
                  ? () => setState(() => _currentPage--)
                  : null,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                side: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
              ),
              child: const Text('السابق'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$_currentPage / $totalPages',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.75),
              ),
            ),
          ),
          Expanded(
            child: OutlinedButton(
              onPressed: _currentPage < totalPages
                  ? () => setState(() => _currentPage++)
                  : null,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                side: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
              ),
              child: const Text('التالي'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 8,
      itemBuilder: (_, __) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AppRadius.card,
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150,
                height: 14,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 110,
                height: 10,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 90,
                height: 16,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // واجهة "لا توجد طلبات" بشكل احترافي
  Widget _buildEmptyState(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AppRadius.card,
            border: Border.all(color: const Color(0xFFE5E7EB)),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_basket_outlined,
                size: 96,
                color: colorScheme.primary.withOpacity(0.25),
              ),
              const SizedBox(height: 20),
              Text(
                'لا توجد طلبات حالياً',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'ابدأ بالتسوق الآن وستظهر طلباتك هنا',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // واجهة الخطأ
  Widget _buildErrorState(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AppRadius.card,
            border: Border.all(color: const Color(0xFFE5E7EB)),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: AppColors.danger,
              ),
              const SizedBox(height: 16),
              Text(
                'عذراً، حدث خطأ ما',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => _loadOrders()),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
                child: Text(
                  'إعادة المحاولة',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
