import 'dart:convert';
import 'package:http/http.dart' as http;
import '../exceptions/session_expired_exception.dart';

class ApiErrorHandler {
  static Exception handle(http.Response response) {
    try {
      final data = json.decode(response.body);

      String message =
          'حدث خطأ غير متوقع، يرجى المحاولة لاحقًا';

      // 1️⃣ لو يوجد message مباشر
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }

      // 2️⃣ لو يوجد validation errors
      if (data is Map && data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          message = firstError.first.toString();
        }
      }

      // 3️⃣ session expired
      if (response.statusCode == 401) {
        return SessionExpiredException(message);
      }

      return Exception(message);
    } catch (_) {
      return Exception(
        'حدث خطأ غير متوقع، يرجى المحاولة لاحقًا',
      );
    }
  }
}
