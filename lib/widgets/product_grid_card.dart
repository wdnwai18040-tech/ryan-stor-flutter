import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/components/layout/app_scaffold.dart';
import 'package:ryaaans_store/core/design/app_colors.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';
import 'package:ryaaans_store/screens/product_details_screen.dart';
import '../api/api_service.dart';
import '../models/product.dart';

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
  ) {
    if (index >= candidates.length) return fallback;

    return Image.network(
      candidates[index],
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) =>
          _networkWithFallback(candidates, index + 1, fallback),
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

      final response = await api.get(
        '/categories/${widget.categoryId}/products',
      );

      if (!mounted) return;

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
    } catch (_) {
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
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        body: _isLoading
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                itemCount: _products.length,
                itemBuilder: (context, i) =>
                    _buildProductListItem(context, _products[i], theme),
              ),
      ),
    );
  }

  Widget _buildProductListItem(
    BuildContext context,
    Product product,
    ThemeData theme,
  ) {
    final bool isAvailable = product.isAvailable;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        // الكرت يأخذ لون السطح (surface) المحدد في الثيم (أبيض في العادة)
        color: theme.colorScheme.surface,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.card,
          onTap: isAvailable
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(product: product),
                    ),
                  );
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // حاوية الأيقونة تعتمد على اللون الأساسي للثيم
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _networkWithFallback(
                    _imageCandidates(product.imageUrl),
                    0,
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/mascot/home_mascot.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: isAvailable
                              ? theme.colorScheme.onSurface
                              : theme.disabledColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildStatusBadge(isAvailable, theme),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: theme.disabledColor.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isAvailable, ThemeData theme) {
    // الألوان هنا تتبع منطق الحالة (نجاح أو خطأ) من الثيم
    final color = isAvailable ? AppColors.success : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        isAvailable ? 'متوفر الآن' : 'غير متوفر',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Text(
        'لا توجد منتجات حالياً',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w400,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'تعذر تحميل البيانات',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            onPressed: () => _fetchProducts(),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
