import 'package:flutter/material.dart';
import 'standard_app_bar.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final Widget? drawer;
  final Widget? endDrawer;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Color? backgroundColor;
  final String title;
  final String? imagePath;
  final Widget? leading;
  final Widget? trailing;
  final PreferredSizeWidget? bottomAppBar;
  final Widget? floatingActionButton;
  final ValueChanged<bool>? onEndDrawerChanged;
  final bool showHeaderImage;

  const AppScaffold({
    super.key,
    required this.body,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.title = '',
    this.imagePath,
    this.leading,
    this.trailing,
    this.bottomAppBar,
    this.floatingActionButton,
    this.scaffoldKey,
    this.onEndDrawerChanged,
    this.showHeaderImage = true,
  });

  static const Map<String, String> _sectionImages = {
    'متجر الريان': 'assets/mascot/home_mascot.webp',
    'طلباتي': 'assets/mascot/orders.webp',
    'تفاصيل الطلب': 'assets/mascot/order details.webp',
    'سجل المعاملات': 'assets/mascot/transection.webp',
    'إعادة شحن المحفظة': 'assets/mascot/wallet.webp',
    'إنشاء حساب جديد': 'assets/mascot/signup.webp',
    'تسجيل الدخول': 'assets/mascot/login.webp',
    'الإعدادات': 'assets/mascot/home_mascot.webp',
    'بيانات الحساب': 'assets/mascot/home_mascot.webp',
    'تغيير كلمة المرور': 'assets/mascot/signup.webp',
  };

  String _resolveSectionImage() {
    if (imagePath != null && imagePath!.trim().isNotEmpty) {
      return imagePath!;
    }

    final resolved = _sectionImages[title.trim()];
    if (resolved != null) return resolved;

    if (title.contains('محفظ')) return 'assets/mascot/wallet.webp';
    if (title.contains('معامل')) return 'assets/mascot/transection.webp';
    if (title.contains('طلب')) return 'assets/mascot/orders.webp';
    if (title.contains('تسجيل') || title.contains('دخول')) {
      return 'assets/mascot/login.webp';
    }
    if (title.contains('حساب') || title.contains('إنشاء')) {
      return 'assets/mascot/signup.webp';
    }
    if (title.contains('تفاصيل')) return 'assets/mascot/order details.webp';

    return 'assets/mascot/home_mascot.webp';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sectionImage = showHeaderImage ? _resolveSectionImage() : null;

    return Scaffold(
      key: scaffoldKey,
      drawer: drawer,
      endDrawer: endDrawer,
      onEndDrawerChanged: onEndDrawerChanged,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          // Large static header as first child
          StandardAppBar(
            title: title,
            imagePath: sectionImage,
            leading: leading,
            trailing: trailing,
          ),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: bottomAppBar,
    );
  }
}
