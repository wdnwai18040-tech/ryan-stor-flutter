import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/components/layout/app_scaffold.dart';
import 'package:ryaaans_store/core/widgets/base_card.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';
import 'package:ryaaans_store/core/design/app_spacing.dart';
import 'package:ryaaans_store/core/widgets/status_badge.dart';
import 'package:provider/provider.dart';
import '../api/api_service.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import 'product_details_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const ProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  bool _hasError = false;

  List<String> _imageCandidates(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return const [];
    final value = rawUrl.trim();

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

    final path = value.startsWith('/') ? value : '/$value';
    return [
      'https://api.ryanstor.com$path',
      'https://ryanstor.com$path',
      'http://145.223.34.121:3000$path',
    ];
  }

  Widget _networkWithFallback(
    List<String> candidates,
    int index,
    Widget fallback,
    String? token,
  ) {
    if (index >= candidates.length) return fallback;

    return Image.network(
      candidates[index],
      fit: BoxFit.cover,
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      errorBuilder: (_, _, _) =>
          _networkWithFallback(candidates, index + 1, fallback, token),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final api = ApiService();

      final response = await api.get('/products?category=${widget.categoryId}');

      if (!mounted) return;
      print("PRODUCTS RESPONSE: $response");
      print("TYPE: ${response.runtimeType}");

      if (response is List) {
        setState(() {
          _products = response.map((data) => Product.fromJson(data)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      print("PRODUCTS ERROR: $e");

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppScaffold(
        title: widget.categoryName,
        imagePath: 'assets/mascot/products.png',
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        body: SafeArea(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                )
              : _hasError
              ? _buildErrorState(theme)
              : _products.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _products.length,
                  itemBuilder: (context, i) =>
                      _buildProductCard(context, _products[i], theme),
                ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product,
    ThemeData theme,
  ) {
    final bool isAvailable = product.isAvailable;
    final token = context.read<AuthProvider>().token;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: BaseCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        onTap: isAvailable
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsScreen(product: product),
                  ),
                );
              }
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: AppRadius.chip,
              ),
              clipBehavior: Clip.antiAlias,
              child: _networkWithFallback(
                _imageCandidates(product.imageUrl),
                0,
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    'assets/mascot/home_mascot.webp',
                    fit: BoxFit.contain,
                  ),
                ),
                token,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: isAvailable
                          ? theme.colorScheme.onSurface
                          : theme.disabledColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusBadge(isAvailable, theme),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          isAvailable
                              ? 'اضغط لعرض التفاصيل'
                              : 'غير متاح حالياً',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isAvailable
                                ? theme.colorScheme.onSurface.withOpacity(0.55)
                                : theme.colorScheme.primary.withOpacity(0.7),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isAvailable, ThemeData theme) {
    if (!isAvailable) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withOpacity(0.12),
          borderRadius: AppRadius.chip,
        ),
        child: Text(
          'غير متوفر',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    return const StatusBadge(label: 'متوفر', type: AppStatusType.completed);
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Text(
        'لا توجد منتجات',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w400,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Text(
        'حدث خطأ ما',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w400,
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}
