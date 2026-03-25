import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryaaans_store/services/loyalty_service.dart';

import '../exceptions/session_expired_exception.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/wallet_provider.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/welcome_screen.dart';
import '../services/notification_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _loaded = false;

  Future<void> _bootstrapAuthenticatedUser(AuthProvider auth) async {
    try {
      await context.read<UserProvider>().refresh(auth.token!);
      context.read<WalletProvider>().refresh(force: true);
      context.read<LoyaltyService>().fetchUserLoyalty();
      await NotificationService.instance.handlePendingNavigation();
    } on SessionExpiredException {
      if (!mounted) return;
      context.read<UserProvider>().clear();
      await context.read<AuthProvider>().logout();
    } catch (_) {
      if (!mounted) return;
      context.read<UserProvider>().clear();
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final auth = context.read<AuthProvider>();

    if (auth.isAuthenticated && !_loaded) {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _bootstrapAuthenticatedUser(auth);
      });
    }

    if (!auth.isAuthenticated) {
      _loaded = false;
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

    if (userProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userProvider.user == null) {
      return const LoginScreen();
    }

    if (auth.isNewUser) {
      return const WelcomeScreen();
    }

    return const MainNavigationScreen();
  }
}
