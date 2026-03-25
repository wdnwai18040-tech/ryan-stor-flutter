import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/components/layout/app_scaffold.dart';
import 'package:ryaaans_store/core/widgets/base_card.dart';
import 'package:ryaaans_store/core/widgets/base_button.dart';
import 'package:ryaaans_store/core/widgets/price_text.dart';
import 'package:ryaaans_store/core/widgets/status_badge.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';
import 'package:ryaaans_store/core/design/app_colors.dart';
import 'package:ryaaans_store/core/storage/utils/currency_formatter.dart';
import 'package:ryaaans_store/providers/wallet_provider.dart';
import 'package:ryaaans_store/widgets/wallet_balance_card.dart';
import '../api/api_service.dart';
import '../models/product.dart';
import '../services/purchase_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  List<ProductVariant> _variants = [];
  ProductVariant? _selectedVariant;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isBuying = false;
  final _playerIdController = TextEditingController();
  final _playerNameController = TextEditingController();
  final _playerEmailController = TextEditingController();
  final _playerPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchVariants();
  }

  Future<void> _fetchVariants() async {
    try {
      final token = context.read<AuthProvider>().token;
      final api = ApiService(token: token);
      final response = await api.get('/products/${widget.product.id}');

      if (!mounted) return;

      if (response is Map<String, dynamic>) {
        final dynamic rawVariants =
            response['variations'] ?? response['variants'];
        final List variationsList = rawVariants is List
            ? rawVariants
            : const [];

        if (variationsList.isEmpty) {
          _setError();
          return;
        }

        setState(() {
          _variants = variationsList
              .map((e) => ProductVariant.fromJson(Map<String, dynamic>.from(e)))
              .toList();

          _isLoading = false;

          if (_variants.isNotEmpty) {
            _selectedVariant = _variants.first;
          }
        });
      } else {
        _setError();
      }
    } catch (_) {
      if (!mounted) return;
      _setError();
    }
  }

  void _setError() {
    setState(() {
      _isLoading = false;
      _hasError = true;
    });
  }

  @override
  void dispose() {
    _playerIdController.dispose();
    _playerNameController.dispose();
    _playerEmailController.dispose();
    _playerPasswordController.dispose();
    super.dispose();
  }

  bool _isVariantAvailable(ProductVariant variant) {
    if (variant.variantType == 'service') {
      return variant.availability == 'available' ||
          variant.availability == 'on_request';
    }
    return variant.availableCodes > 0;
  }

  Color _getAvailabilityColor(ProductVariant variant, ThemeData theme) {
    return _isVariantAvailable(variant)
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
  }

  String _getAvailabilityText(ProductVariant variant) {
    if (!_isVariantAvailable(variant)) return '✗ نفذ';
    if (variant.variantType == 'service') return '✓ متاح للطلب';
    return '✓ كود شحن مباشر';
  }

  String _variantPriceText(ProductVariant variant) {
    final price = variant.isDiscountActive ? variant.finalPrice : variant.price;
    return CurrencyFormatter.formatWithCurrency(price);
  }

  bool _requiresPlayerData(ProductVariant variant) {
    return variant.requirePlayerId ||
        variant.requirePlayerName ||
        variant.requirePlayerEmail ||
        variant.requirePlayerPassword;
  }

  String? _validatePlayerData(ProductVariant variant) {
    if (variant.requirePlayerId && _playerIdController.text.trim().isEmpty) {
      return 'يرجى إدخال معرف اللاعب';
    }
    if (variant.requirePlayerName &&
        _playerNameController.text.trim().isEmpty) {
      return 'يرجى إدخال اسم اللاعب';
    }
    if (variant.requirePlayerEmail &&
        _playerEmailController.text.trim().isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    if (variant.requirePlayerPassword &&
        _playerPasswordController.text.trim().isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    return null;
  }

  Map<String, dynamic> _buildPlayerData(ProductVariant variant) {
    final Map<String, dynamic> data = {};
    if (variant.requirePlayerId) {
      data['player_id'] = _playerIdController.text.trim();
    }
    if (variant.requirePlayerName) {
      data['player_name'] = _playerNameController.text.trim();
    }
    if (variant.requirePlayerEmail) {
      data['player_email'] = _playerEmailController.text.trim();
    }
    if (variant.requirePlayerPassword) {
      data['player_password'] = _playerPasswordController.text.trim();
    }
    return data;
  }

  Future<void> _buySelectedVariant() async {
    final variant = _selectedVariant;
    if (variant == null || !_isVariantAvailable(variant) || _isBuying) return;

    final validationMessage = _validatePlayerData(variant);
    if (validationMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationMessage),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final playerData = _buildPlayerData(variant);

    setState(() => _isBuying = true);
    try {
      await PurchaseService.buyNow(
        context: context,
        selectedVariant: variant,
        playerData: playerData,
      );
    } finally {
      if (mounted) {
        setState(() => _isBuying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wallet = context.watch<WalletProvider>();
    final balance = wallet.balance ?? 0.0;
    final inputFillColor = theme.colorScheme.primary.withOpacity(
      theme.brightness == Brightness.dark ? 0.16 : 0.06,
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: theme.colorScheme.primary.withOpacity(0.55),
      ),
    );
    final focusedInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppScaffold(
        title: widget.product.name,
        imagePath: 'assets/mascot/products.png',
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                  ? const Center(child: Text('حدث خطأ أثناء تحميل المنتج'))
                  : _variants.isEmpty
                  ? const Center(
                      child: Text('لا توجد خيارات متاحة لهذا المنتج'),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        MediaQuery.of(context).viewInsets.bottom + 16,
                      ),
                      child: Column(
                        children: [
                          WalletBalanceCard(balance: balance),

                          const SizedBox(height: 16),

                          // =========================
                          // اختيار الفاريانت
                          // =========================
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'اختر الفاريانت',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              const spacing = 10.0;
                              final cardWidth =
                                  (constraints.maxWidth - spacing) / 2;

                              return Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                children: _variants.map((variant) {
                                  final isSelected =
                                      _selectedVariant?.id == variant.id;
                                  final isAvailable = _isVariantAvailable(
                                    variant,
                                  );
                                  final variantCardRadius =
                                      BorderRadius.circular(12);

                     return SizedBox(
  width: cardWidth,
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: variantCardRadius,
      onTap: () {
        setState(() {
          _selectedVariant = variant;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: variantCardRadius,
          color: theme.colorScheme.surface,
          border: isSelected
              ? Border.all(
                  color: theme.colorScheme.tertiary,
                  width: 1.5,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(
                isSelected ? 0.20 : 0.10,
              ),
              blurRadius: isSelected ? 20 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  variant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _variantPriceText(variant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    isAvailable
                        ? const StatusBadge(
                            label: 'متوفر',
                            type: AppStatusType.completed,
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: AppRadius.chip,
                              color: theme.colorScheme.error.withOpacity(0.12),
                            ),
                            child: Text(
                              'غير متوفر',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),

            // 🔥 Badge الخصم
            if (variant.isDiscountActive)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "تخفيض ${(variant.discountPercentage ?? 0).toStringAsFixed(0)}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  ),
);
                                }).toList(),
                              );
                            },
                          ),

                          if (_selectedVariant != null &&
                              _requiresPlayerData(_selectedVariant!)) ...[
                            const SizedBox(height: 14),
                            BaseCard(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'بيانات اللاعب',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w400),
                                  ),
                                  const SizedBox(height: 10),
                                  if (_selectedVariant!.requirePlayerId) ...[
                                    TextField(
                                      controller: _playerIdController,
                                      decoration: InputDecoration(
                                        labelText: 'معرف اللاعب',
                                        filled: true,
                                        fillColor: inputFillColor,
                                        border: inputBorder,
                                        enabledBorder: inputBorder,
                                        focusedBorder: focusedInputBorder,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                  if (_selectedVariant!.requirePlayerName) ...[
                                    TextField(
                                      controller: _playerNameController,
                                      decoration: InputDecoration(
                                        labelText: 'اسم اللاعب',
                                        filled: true,
                                        fillColor: inputFillColor,
                                        border: inputBorder,
                                        enabledBorder: inputBorder,
                                        focusedBorder: focusedInputBorder,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                  if (_selectedVariant!.requirePlayerEmail) ...[
                                    TextField(
                                      controller: _playerEmailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        labelText: 'البريد الإلكتروني',
                                        filled: true,
                                        fillColor: inputFillColor,
                                        border: inputBorder,
                                        enabledBorder: inputBorder,
                                        focusedBorder: focusedInputBorder,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                  if (_selectedVariant!
                                      .requirePlayerPassword) ...[
                                    TextField(
                                      controller: _playerPasswordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'كلمة المرور',
                                        filled: true,
                                        fillColor: inputFillColor,
                                        border: inputBorder,
                                        enabledBorder: inputBorder,
                                        focusedBorder: focusedInputBorder,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),

            // =========================
            // الشريط السفلي
            // =========================
            if (_selectedVariant != null)
              BaseCard(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 1),
                child: SafeArea(
                  top: false,
                  bottom: false,
                  left: false,
                  right: false,
                  minimum: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'إجمالي المبلغ:',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.78,
                              ),
                            ),
                          ),
                          PriceText(
                            value: _selectedVariant!.isDiscountActive
                                ? '${CurrencyFormatter.format(_selectedVariant!.finalPrice)} جنيه'
                                : '${CurrencyFormatter.format(_selectedVariant!.price)} جنيه',
                            color: AppColors.success,
                            size: PriceTextSize.normal,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      BaseButton(
                        label: _isVariantAvailable(_selectedVariant!)
                            ? 'شراء الآن'
                            : 'غير متاح حالياً',
                        isLoading: _isBuying,
                        onPressed: _isVariantAvailable(_selectedVariant!)
                            ? _buySelectedVariant
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
