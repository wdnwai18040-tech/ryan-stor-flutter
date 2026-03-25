// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ryaaans_store/core/storage/utils/currency_formatter.dart';
import 'package:ryaaans_store/providers/wallet_provider.dart';
import 'package:ryaaans_store/screens/transactions/transactions_page.dart';
import 'package:ryaaans_store/core/design/app_radius.dart';
import 'package:ryaaans_store/services/loyalty_service.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../core/widgets/wallet_glass_card.dart';
import '../core/widgets/modern_card_tile.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final LoyaltyService _loyaltyService = LoyaltyService();
  LoyaltyTier? _loyaltyTier;
  bool _loyaltyLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoyaltyData();
  }

  Future<void> _loadLoyaltyData() async {
    final loyalty = await _loyaltyService.fetchUserLoyalty();

    if (mounted) {
      setState(() {
        _loyaltyTier = loyalty;
        _loyaltyLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        backgroundColor: Colors.white,
        elevation: 0,
        width: MediaQuery.of(context).size.width * 0.86,
        child: SafeArea(
          child: Column(
            children: [
              _buildProfileHeader(context, theme),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  children: [
                    _buildSectionTitle(theme, "النشاط"),
                    _buildMenuIsland(context, theme, [
                      _MenuItemData(
                        icon: Icons.shopping_bag_rounded,
                        title: 'طلباتي',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/orders');
                        },
                      ),
                      _MenuItemData(
                        icon: Icons.receipt_long_rounded,
                        title: 'سجل المعاملات',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TransactionsPage(),
                            ),
                          );
                        },
                      ),
                    ]),

                    const SizedBox(height: 24),

                    _buildSectionTitle(theme, "التطبيق"),
                    _buildMenuIsland(context, theme, [
                      _MenuItemData(
                        icon: Icons.dark_mode_rounded,
                        title: 'الوضع الليلي',
                        onTap: () {
                          context.read<ThemeProvider>().toggleTheme();
                        },
                      ),
                      _MenuItemData(
                        icon: Icons.settings_suggest_rounded,
                        title: 'الإعدادات',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                      _MenuItemData(
                        icon: Icons.power_settings_new_rounded,
                        title: 'تسجيل الخروج',
                        isDestructive: true,
                        onTap: () async {
                          Navigator.pop(context);
                          await context.read<AuthProvider>().logout();
                          context.read<UserProvider>().clear();
                          context.read<WalletProvider>().clear();
                          if (!context.mounted) return;
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        },
                      ),
                    ]),
                  ],
                ),
              ),
              _buildFooter(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ThemeData theme) {
    final user = context.watch<UserProvider>().user;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white,
        border: Border.all(color: Colors.blue.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 50,
            spreadRadius: -10,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 👤 USER INFO SECTION
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.blue.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(Icons.person, color: Colors.blue, size: 26),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.username ?? "مستخدم",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      user?.email ?? "",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// ─── Divider: User → Loyalty ───
          const SizedBox(height: 22),
          Divider(
            color: Colors.blue.withOpacity(0.25),
            thickness: 1,
            height: 1,
            indent: 0,
            endIndent: 0,
          ),
          const SizedBox(height: 22),

          /// 🏆 LOYALTY SECTION
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.08),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.25),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.15),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: CachedNetworkImage(
                  imageUrl: _loyaltyTier?.iconUrl ?? "",
                  width: 30,
                  height: 30,
                  placeholder: (context, url) =>
                      Icon(Icons.star_rounded, color: Colors.blue, size: 30),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.star_rounded, color: Colors.blue, size: 30),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _loyaltyTier?.displayName ?? "رتبة غير معروفة",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),

              /// ✅ نسبة التخفيض LABEL + BADGE
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "نسبة التخفيض",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.35),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      "${_loyaltyTier?.discountPercent ?? 0}%",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            "التقدم نحو الرتبة التالية",
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: (_loyaltyTier?.progress ?? 0) / 100,
              minHeight: 10,
              backgroundColor: Colors.blue.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 10),

          Text(
            "متبقي ${_loyaltyTier?.remaining ?? 0} للوصول إلى ${_loyaltyTier?.nextTier ?? ""}",
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.black54),
          ),

          /// ─── Divider: Loyalty → Wallet ───
          const SizedBox(height: 24),
          Divider(
            color: Colors.blue.withOpacity(0.25),
            thickness: 1,
            height: 1,
            indent: 0,
            endIndent: 0,
          ),
          const SizedBox(height: 24),

          /// 💰 WALLET SECTION
          Text(
            "الرصيد المتاح",
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Consumer<WalletProvider>(
                  builder: (context, walletProvider, _) {
                    final balance = walletProvider.balance;
                    return Text(
  balance > 0
      ? "${CurrencyFormatter.format(balance)} جنيه"
      : "-- جنيه",
  style: theme.textTheme.headlineSmall?.copyWith(
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: Colors.black87,
  ),
);
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/wallet');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.blue.withOpacity(0.4),
                ),
                child: const Text("شحن"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 14, top: 6),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildMenuIsland(
    BuildContext context,
    ThemeData theme,
    List<_MenuItemData> items,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.card,
        border: Border.all(color: Colors.blue.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) {
          return ModernCardTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (item.isDestructive ? Colors.red : Colors.blue)
                      .withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Icon(
                item.icon,
                color: item.isDestructive ? Colors.red : Colors.blue,
                size: 22,
              ),
            ),
            title: Text(
              item.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: item.isDestructive ? Colors.red : Colors.black87,
                fontSize: 15,
              ),
            ),
            onTap: item.onTap,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.blue.withOpacity(0.2), width: 1),
        ),
      ),
      child: Text(
        "متجر الريان v1.0.0",
        style: theme.textTheme.labelMedium?.copyWith(
          color: Colors.black54,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  _MenuItemData({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });
}
