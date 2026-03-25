import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryaaans_store/services/loyalty_service.dart';

import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/wallet_provider.dart';
import '../services/notification_service.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/main_navigation_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final auth = context.read<AuthProvider>();

    if (auth.isAuthenticated && !_loaded) {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 👤 بيانات المستخدم
        context.read<UserProvider>().refresh(auth.token!);

        // 💰 المحفظة
        context.read<WalletProvider>().refresh(force: true);

        // 🏆 نظام الولاء
        context.read<LoyaltyService>().fetchUserLoyalty();
        NotificationService.instance.handlePendingNavigation();
      });
    }

    if (!auth.isAuthenticated) {
      _loaded = false; // مهم عند تسجيل الخروج
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();

    if (!auth.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    // ✅ انتظار تحميل بيانات المستخدم
    if (userProvider.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 👇 مستخدم جديد
    if (auth.isNewUser) {
      return const WelcomeScreen();
    }

    // 👇 مستخدم عادي
    return const MainNavigationScreen();
  }
}
