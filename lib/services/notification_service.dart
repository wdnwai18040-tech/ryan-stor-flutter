import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_service.dart';
import '../firebase_options.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/orders/order_details_page.dart';

const AndroidNotificationChannel _highImportanceChannel =
    AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important notifications.',
      importance: Importance.high,
    );

Future<void> _showLocalNotification(
  FlutterLocalNotificationsPlugin notificationsPlugin,
  RemoteMessage message,
) async {
  final notification = message.notification;
  final title = notification?.title ?? message.data['title']?.toString();
  final body = notification?.body ?? message.data['body']?.toString();

  if (title == null && body == null) {
    return;
  }

  await notificationsPlugin.show(
    message.hashCode,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'Used for important notifications.',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    payload: jsonEncode(message.data),
  );
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (message.notification != null) {
    return;
  }

  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );

  await notificationsPlugin.initialize(initializationSettings);

  final androidImplementation =
      notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
  await androidImplementation?.createNotificationChannel(
    _highImportanceChannel,
  );

  await _showLocalNotification(notificationsPlugin, message);
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _authToken;
  Map<String, dynamic>? _pendingNavigationData;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initializeLocalNotifications();
    await _requestPermissions();
    await _configureMessagingListeners();

    _initialized = true;

    if (_authToken != null) {
      await syncTokenToServer();
    }
  }

  Future<void> updateAuthToken(String? token) async {
    _authToken = token;

    if (_authToken == null || _authToken!.isEmpty) {
      return;
    }

    await syncTokenToServer();
  }

  Future<void> syncTokenToServer({String? tokenOverride}) async {
    final authToken = _authToken;
    if (authToken == null || authToken.isEmpty) {
      return;
    }

    final fcmToken = tokenOverride ?? await _messaging.getToken();
    if (fcmToken == null || fcmToken.isEmpty) {
      return;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final payload = <String, dynamic>{
        'token': fcmToken,
        'platform': Platform.isAndroid ? 'android' : Platform.operatingSystem,
        'device_name': await _getDeviceName(),
      };

      if (packageInfo.appName.isNotEmpty) {
        payload['app_name'] = packageInfo.appName;
      }

      await ApiService(token: authToken).post('/devices/fcm-token', payload);
    } catch (error) {
      debugPrint('FCM token sync failed: $error');
    }
  }

  Future<void> handlePendingNavigation() async {
    final data = _pendingNavigationData;
    if (data == null) {
      return;
    }

    _pendingNavigationData = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateFromData(data);
    });
  }

  Future<void> _initializeLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) {
          return;
        }

        try {
          final data = Map<String, dynamic>.from(jsonDecode(payload) as Map);
          _navigateFromData(data);
        } catch (_) {}
      },
    );

    final androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImplementation?.createNotificationChannel(
      _highImportanceChannel,
    );
  }

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.requestNotificationsPermission();
  }

  Future<void> _configureMessagingListeners() async {
    FirebaseMessaging.onMessage.listen((message) async {
      await _showLocalNotification(_localNotifications, message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigateFromData(message.data);
    });

    _messaging.onTokenRefresh.listen((token) async {
      await syncTokenToServer(tokenOverride: token);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _pendingNavigationData = Map<String, dynamic>.from(initialMessage.data);
    }
  }

  Future<String> _getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}'.trim();
      }
    } catch (_) {}

    return Platform.operatingSystem;
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingNavigationData = data;
      return;
    }

    final screen = data['screen']?.toString();
    final type = data['type']?.toString();
    final url = data['url']?.toString();
    final orderId = int.tryParse(data['order_id']?.toString() ?? '');
    final topupId = data['topup_id']?.toString();

    if (url != null && url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    if ((screen == 'order_details' || type == 'order_completed') &&
        orderId != null) {
      navigator.push(
        MaterialPageRoute(builder: (_) => OrderDetailsPage(orderId: orderId)),
      );
      return;
    }

    if (screen == 'orders') {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(initialIndex: 1),
        ),
      );
      return;
    }

    if (screen == 'transactions' || topupId != null) {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(initialIndex: 3),
        ),
      );
      return;
    }

    if (screen == 'wallet') {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(initialIndex: 2),
        ),
      );
      return;
    }

    if (screen == 'settings') {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(initialIndex: 4),
        ),
      );
      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(initialIndex: 0),
      ),
    );
  }
}
