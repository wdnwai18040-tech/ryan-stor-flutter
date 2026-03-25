import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryaaans_store/core/components/layout/app_scaffold.dart';
import 'package:ryaaans_store/core/design/app_colors.dart';
import 'package:ryaaans_store/features/home/widgets/offers_section.dart';
import 'package:ryaaans_store/features/home/widgets/popular_products_section.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';
import 'package:ryaaans_store/core/design/app_shadows.dart';

import '../api/api_service.dart';
import '../models/category.dart';
import '../widgets/app_drawer.dart';
import '../providers/wallet_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'products_screen.dart';
import '../widgets/category_card.dart';

import '../../../core/design/app_spacing.dart';
import '../../../core/design/app_sizes.dart';
import '../models/discounted_offer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Category> _categories = [];
  List<dynamic> _popularProducts = [];

  bool _isLoading = true;
  bool _isPopularLoading = true;
  List<DiscountedOffer> _offers = [];
  bool _isOffersLoading = true;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchPopularProducts();
    _fetchOffers();
  }

  /* =========================
     Fetch Offers
  ========================= */
  Future<void> _fetchOffers() async {
    try {
      final token = context.read<AuthProvider>().token;
      final api = ApiService(token: token);

      final response = await api.getDiscountedOffers();

      if (!mounted) return;

      setState(() {
        _offers = response;
        _isOffersLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isOffersLoading = false;
      });
    }
  }

  /* =========================
     Fetch Categories
  ========================= */
  Future<void> _fetchCategories() async {
    try {
      final token = context.read<AuthProvider>().token;

      final api = ApiService(token: token);
      final response = await api.get('/categories');

      if (!mounted) return;

      if (response is List) {
        final parsed = response.map((data) => Category.fromJson(data)).toList();

        setState(() {
          _categories = parsed;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "صيغة البيانات غير صحيحة";
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = "حدث خطأ أثناء تحميل الأقسام";
      });
    }
  }

  /* =========================
     Fetch Popular Products
  ========================= */
  Future<void> _fetchPopularProducts() async {
    try {
      final token = context.read<AuthProvider>().token;
      final api = ApiService(token: token);

      final response = await api.get('/products/top-selling?limit=6');

      if (!mounted) return;

      if (response is List) {
        setState(() {
          _popularProducts = response;
          _isPopularLoading = false;
        });
      } else {
        setState(() {
          _isPopularLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isPopularLoading = false;
      });
    }
  }

  Future<void> _refreshHome() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _isPopularLoading = true;
        _isOffersLoading = true;
        _errorMessage = null;
      });
    }

    await Future.wait([
      _fetchCategories(),
      _fetchPopularProducts(),
      _fetchOffers(),
      context.read<WalletProvider>().refresh(force: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppScaffold(
        scaffoldKey: _scaffoldKey,
        endDrawer: const AppDrawer(),
        onEndDrawerChanged: (isOpened) {
          if (isOpened) {
            context.read<WalletProvider>().refresh(force: true);
          }
        },
        title: 'متجر الريان',
        imagePath: 'assets/mascot/home_mascot.webp',
        leading: IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(
            width: AppSizes.headerImageSize - 4,
            height: AppSizes.headerImageSize - 4,
          ),
          visualDensity: VisualDensity.compact,
          icon: Icon(Icons.menu, color: theme.colorScheme.onPrimary),
          onPressed: () {
            _scaffoldKey.currentState?.openEndDrawer();
          },
        ),
        trailing: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(
                width: AppSizes.headerImageSize - 4,
                height: AppSizes.headerImageSize - 4,
              ),
              visualDensity: VisualDensity.compact,
              icon: Icon(
                themeProvider.isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: theme.colorScheme.onPrimary,
              ),
              onPressed: () => context.read<ThemeProvider>().toggleTheme(),
            );
          },
        ),
        backgroundColor: colorScheme.surface,
        body: _isLoading
            ? _buildLoadingHome(theme)
            : _errorMessage != null
            ? _buildErrorHome(theme)
            : RefreshIndicator(
                onRefresh: _refreshHome,
                color: colorScheme.primary,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _HomeHero(
                      categoriesCount: _categories.length,
                      topProductsCount: _popularProducts.length,
                      offersCount: _offers.length,
                    ),
                    const SizedBox(height: 12),
                    _QuickStatsRow(
                      categoriesCount: _categories.length,
                      topProductsCount: _popularProducts.length,
                      offersCount: _offers.length,
                    ),
                    const SizedBox(height: 14),

                    _SectionShell(
                      tone: _SectionTone.primary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionHeadline(
                            icon: Icons.local_fire_department_rounded,
                            title: 'الأكثر مبيعاً',
                            subtitle: 'منتجات رائجة بتحديث مستمر',
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _isPopularLoading
                              ? const SizedBox(
                                  height: 190,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : PopularProductsSection(
                                  products: _popularProducts,
                                ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    _SectionShell(
                      tone: _SectionTone.secondary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionHeadline(
                            icon: Icons.grid_view_rounded,
                            title: 'الأقسام',
                            subtitle: 'اختيارات مرتبة حسب النوع',
                          ),
                          const SizedBox(height: AppSpacing.md),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: AppSpacing.md,
                                  crossAxisSpacing: AppSpacing.md,
                                  childAspectRatio: 0.66,
                                ),
                            itemCount: _categories.length,
                            itemBuilder: (context, i) {
                              final cat = _categories[i];

                              return CategoryCard(
                                category: cat,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ProductsScreen(
                                      categoryId: cat.id,
                                      categoryName: cat.name,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    _SectionShell(
                      tone: _SectionTone.tertiary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionHeadline(
                            icon: Icons.card_giftcard_rounded,
                            title: 'العروض',
                            subtitle: 'خصومات مختارة لفترة محدودة',
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _isOffersLoading
                              ? const SizedBox(
                                  height: 220,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : OffersSection(offers: _offers),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingHome(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
      children: [
        Container(
          height: 146,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.primaryGradient,
            ),
            borderRadius: AppRadius.card,
            boxShadow: AppShadows.hero(context),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(
            3,
            (_) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          3,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 180,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: AppRadius.card,
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorHome(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AppRadius.card,
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: AppShadows.card(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: colorScheme.error,
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage ?? 'حدث خطأ غير متوقع',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _refreshHome,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة التحميل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SectionTone { primary, secondary, tertiary }

class _SectionShell extends StatelessWidget {
  final _SectionTone tone;
  final Widget child;

  const _SectionShell({required this.tone, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color background;
    final Color border;

    switch (tone) {
      case _SectionTone.primary:
        background = colorScheme.primaryContainer.withValues(alpha: 0.26);
        border = colorScheme.primary.withValues(alpha: 0.16);
        break;
      case _SectionTone.secondary:
        background = colorScheme.secondaryContainer.withValues(alpha: 0.24);
        border = colorScheme.secondary.withValues(alpha: 0.16);
        break;
      case _SectionTone.tertiary:
        background = colorScheme.tertiaryContainer.withValues(alpha: 0.24);
        border = colorScheme.tertiary.withValues(alpha: 0.16);
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.card,
        border: Border.all(color: border),
        boxShadow: AppShadows.card(context),
      ),
      child: child,
    );
  }
}

class _SectionHeadline extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeadline({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.14),
            borderRadius: AppRadius.chip,
          ),
          child: Icon(icon, size: 19, color: colorScheme.primary),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeHero extends StatelessWidget {
  final int categoriesCount;
  final int topProductsCount;
  final int offersCount;

  const _HomeHero({
    required this.categoriesCount,
    required this.topProductsCount,
    required this.offersCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.hero(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تجربة رقمية فاخرة',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'اشحن ألعابك وبطاقاتك بسرعة وأمان مع متابعة ذكية للطلبات.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroChip(label: '$topProductsCount منتج رائج'),
              _HeroChip(label: '$categoriesCount قسم'),
              _HeroChip(label: '$offersCount عرض متاح'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final String label;

  const _HeroChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: AppRadius.chip,
        border: Border.all(color: Colors.white.withOpacity(0.24)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  final int categoriesCount;
  final int topProductsCount;
  final int offersCount;

  const _QuickStatsRow({
    required this.categoriesCount,
    required this.topProductsCount,
    required this.offersCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            icon: Icons.grid_view_rounded,
            label: 'الأقسام',
            value: '$categoriesCount',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.local_fire_department_rounded,
            label: 'رائج',
            value: '$topProductsCount',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.card_giftcard_rounded,
            label: 'عروض',
            value: '$offersCount',
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }
}
