// screens/orders/order_details_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ryaaans_store/models/order_model.dart';
import 'package:ryaaans_store/services/order_service.dart';
import 'package:ryaaans_store/core/components/layout/app_scaffold.dart';
import 'package:ryaaans_store/core/design/app_colors.dart';
import 'package:ryaaans_store/core/storage/utils/currency_formatter.dart';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  Order? order;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadOrder();
  }

  Future<void> loadOrder() async {
    try {
      final result = await OrderService().getOrderDetails(
        context,
        widget.orderId,
      );

      if (mounted) {
        setState(() {
          order = result;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: "تفاصيل الطلب",
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : order == null
          ? const Center(child: Text("تعذر تحميل الطلب"))
          : RefreshIndicator(
              onRefresh: loadOrder,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  /// المنتج
                  _Card(
                    child: Column(
                      children: [
                        Text(
                          order!.productName,
                          style: theme.textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),

                        Text(
                          order!.variantName,
                          style: theme.textTheme.bodyMedium,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          CurrencyFormatter.formatWithCurrency(
                            order!.totalAmount,
                          ),
                          style: theme.textTheme.headlineSmall!.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// تفاصيل الطلب
                  _Card(
                    title: "تفاصيل الطلب",
                    child: Column(
                      children: [
                        _Row("رقم الطلب", "#${order!.id}"),
                        _Row(
                          "التاريخ",
                          "${order!.createdAt.year}-${order!.createdAt.month}-${order!.createdAt.day}",
                        ),
                        _Row(
                          "الحالة",
                          order!.status == "completed"
                              ? "مكتمل"
                              : "قيد التنفيذ",
                          color: order!.status == "completed"
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ],
                    ),
                  ),

                  if (order!.licenseKey != null) ...[
                    const SizedBox(height: 16),

                    /// كود التفعيل
                    _Card(
                      title: "كود التفعيل",
                      child: Column(
                        children: [
                          SelectableText(
                            order!.licenseKey!,
                            style: theme.textTheme.titleMedium!.copyWith(
                              fontFamily: "monospace",
                            ),
                          ),

                          const SizedBox(height: 12),

                          ElevatedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: order!.licenseKey!),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("تم نسخ الكود")),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text("نسخ الكود"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final String? title;

  const _Card({required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title!, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _Row(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
