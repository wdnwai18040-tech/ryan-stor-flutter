import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:ryaaans_store/screens/orders/orders_page.dart';
import 'package:ryaaans_store/screens/splash_screen.dart';
import 'package:ryaaans_store/core/update_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ryaaans_store/services/notification_service.dart';
// 🎨 Theme
import 'themes/app_theme.dart';

// 🔌 Providers
import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'firebase_options.dart';
// 📱 Screens
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/settings/settings_page.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/loyalty_service.dart';

// 🧩 Widgets
import 'widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.handlePendingNavigation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => LoyaltyService()),
        // 🔐 Auth
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),

        // 👤 User
        ChangeNotifierProvider(create: (_) => UserProvider()),

        // 💰 Wallet (مرتبط بالتوكن)
        ChangeNotifierProxyProvider<AuthProvider, WalletProvider>(
          create: (_) => WalletProvider(),
          update: (_, auth, wallet) {
            wallet ??= WalletProvider();
            wallet.updateToken(auth.token);
            return wallet;
          },
        ),

        // 🌗 Theme
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'متجر ريان',
            debugShowCheckedModeBanner: false,
            navigatorKey: NotificationService.navigatorKey,

            // 🌍 Localization
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // 🎨 Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // 🚪 Entry
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: const SplashScreen(),
            ),
            // 🛣 Routes
            routes: {
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/otp-verify': (_) => const OtpVerificationScreen(),
              '/forgot-password': (_) => const ForgotPasswordScreen(),
              '/home': (_) => const MainNavigationScreen(),
              '/wallet': (_) => const WalletScreen(),
              '/orders': (_) => const OrdersPage(),
              '/settings': (_) => const SettingsPage(),
            },
          );
        },
      ),
    );
  }
}
