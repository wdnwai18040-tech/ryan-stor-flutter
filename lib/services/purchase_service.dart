import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryaaans_store/screens/orders/order_details_page.dart';

import '../api/api_service.dart';
import '../providers/wallet_provider.dart';
import '../providers/auth_provider.dart';
import '../models/product.dart';
import '../exceptions/session_expired_exception.dart';
import 'purchase_request_manager.dart';

class PurchaseService {
  static Future<void> buyNow({
    required BuildContext context,
    required ProductVariant selectedVariant,
    Map<String, dynamic>? playerData,
  }) async {
    final wallet = context.read<WalletProvider>();

    try {
      // 🔄 تحديث الرصيد قبل الشراء
      await wallet.refresh(force: true);

      // 🆔 الحصول على request_id
      await PurchaseRequestManager.clear();
      final requestId = await PurchaseRequestManager.getOrCreateRequestId();
      debugPrint("REQUEST ID SENT: $requestId");
      // 🚀 إعداد ApiService
      final token = context.read<AuthProvider>().token;
      final api = ApiService(token: token);

      // 📦 تجهيز بيانات الطلب
      final orderData = <String, dynamic>{
        'variant_id': selectedVariant.id,
        'request_id': requestId,
      };

      // ✅ إضافة بيانات اللاعب إذا وجدت
      if (playerData != null && playerData.isNotEmpty) {
        orderData.addAll(playerData);
      }

      // 📤 إرسال الطلب
      final response = await api.post('/orders', orderData);
      debugPrint("ORDER RESPONSE: $response");
      // ✅ التحقق من الاستجابة
      if (response is! Map<String, dynamic>) {
        throw Exception('استجابة غير متوقعة من الخادم');
      }

      final data = response;

      if (data == null || data['order_id'] == null) {
        throw Exception('تعذر إنشاء الطلب: بيانات الاستجابة غير مكتملة');
      }

      final orderId = data['order_id'];
      final successMessage = data['message'] ?? 'تم تنفيذ الطلب بنجاح';
_showSnackBar(context, successMessage);
      if (orderId == null) {
        throw Exception('تعذر إنشاء الطلب: بيانات الاستجابة غير مكتملة');
      }

      // 🧹 تنظيف request_id
      await PurchaseRequestManager.clear();

      // 🔄 تحديث الرصيد بعد الخصم
      await wallet.refresh(force: true);

      if (!context.mounted) return;

      // ✅ الانتقال لصفحة تفاصيل الطلب (التعديل الجديد)
      final int orderIntId = orderId is int
          ? orderId
          : int.tryParse(orderId.toString()) ?? 0;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderDetailsPage(orderId: orderIntId),
        ),
      );
    } on SessionExpiredException catch (e) {
      if (!context.mounted) return;
      await _handleSessionExpired(context, e.message);
    } on Exception catch (e) {
      if (!context.mounted) return;
      final message = _parseErrorMessage(e);
      _showSnackBar(context, message, isError: true);
    } catch (e, stack) {
      debugPrint('PURCHASE ERROR: $e');
      debugPrint('STACK: $stack');
      if (!context.mounted) return;
      _showSnackBar(
        context,
        'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً',
        isError: true,
      );
    }
  }

  // ... (بقية الدوال المساعدة _handleSessionExpired, _showSnackBar, _parseErrorMessage كما هي بدون تغيير)

  static Future<void> _handleSessionExpired(
    BuildContext context,
    String? message,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('انتهت الجلسة'),
        content: Text(message ?? 'يرجى تسجيل الدخول للمتابعة'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        showCloseIcon: true,
      ),
    );
  }

  static String _parseErrorMessage(Exception e) {
    final raw = e.toString();
    String message = raw.startsWith('Exception: ')
        ? raw.replaceFirst('Exception: ', '')
        : raw;

    if (raw.contains('SocketException') || raw.contains('Connection refused')) {
      return 'تعذر الاتصال بالخادم، تأكد من اتصالك بالإنترنت';
    }
    if (message.contains('Player ID is required')) {
      return 'يرجى إدخال معرف اللاعب';
    }
    if (message.contains('Player name is required')) {
      return 'يرجى إدخال اسم اللاعب';
    }
    if (message.contains('Player Email is required')) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    if (message.contains('Player Password is required')) {
      return 'يرجى إدخال كلمة السر';
    }
    if (message.contains('Invalid email')) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    if (message.contains('401') || message.contains('Unauthorized')) {
      return 'انتهت جلسة الدخول، يرجى تسجيل الدخول مجدداً';
    }
    if (message.contains('Insufficient balance')) {
      return 'رصيدك غير كافٍ لإتمام هذا الطلب';
    }
    if (message.contains('out of stock')) {
      return 'المنتج نفذ من المخزون';
    }

    return message.length > 150 ? '${message.substring(0, 150)}...' : message;
  }
}
