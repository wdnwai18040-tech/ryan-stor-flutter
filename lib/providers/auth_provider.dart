import 'package:flutter/material.dart';
import '../core/storage/auth_storage.dart';
import '../api/api_service.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isNewUser = false;
  bool get isNewUser => _isNewUser;


  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;


void clearNewUserFlag() {
  _isNewUser = false;
  notifyListeners();
}

  // =========================
  // INIT
  // =========================
  Future<void> init() async {
    _token = await AuthStorage.getToken();
    await NotificationService.instance.updateAuthToken(_token);
    _isInitialized = true;
    notifyListeners();
  }

  // =========================
  // LOGIN
  // =========================
 Future<void> login(String token, {bool isNewUser = false}) async {
  _token = token;
  _isInitialized = true;
  _isNewUser = isNewUser;

  await AuthStorage.saveToken(token);
  await NotificationService.instance.updateAuthToken(_token);
  notifyListeners();
}




  // =========================
  // REGISTER
  // =========================
  Future<int> register(
    BuildContext context,
    String username,
    String email,
    String phone,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final api = ApiService();

      final res = await api.post('/register', {
        'username': username,
        'email': email,
        'phone': phone,
        'password': password,
      });

      if (res is Map && res['user_id'] != null) {
        return res['user_id'] as int;
      } else {
        throw Exception(res['message'] ?? 'فشل إنشاء الحساب');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // VERIFY OTP
  // =========================
  Future<void> verifyOtp(int userId, String otp) async {
    _isLoading = true;
    notifyListeners();

    try {
      final api = ApiService();

      final res = await api.post('/verify-otp', {
        'user_id': userId,
        'otp': otp,
      });

      if (res is Map && res['token'] != null) {
        _isNewUser = true;
        await login(res['token'], isNewUser: true);
      } else {
        throw Exception(res['message'] ?? 'فشل التحقق من الرمز');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // FORGOT PASSWORD
  // =========================
  Future<void> forgotPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final api = ApiService();

      final res = await api.post('/forgot-password', {
        'email': email,
      });

      if (res is! Map || res['message'] == null) {
        throw Exception('فشل إرسال طلب إعادة التعيين');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // RESET PASSWORD
  // =========================
  Future<void> resetPassword(String email, String otp, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final api = ApiService();

      final res = await api.post('/reset-password', {
        'email': email,
        'otp': otp,
        'new_password': newPassword,
      });

      if (res is! Map || res['message'] == null) {
        throw Exception('فشل إعادة تعيين كلمة المرور');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // LOADING CONTROL
  // =========================
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    _token = null;
    await AuthStorage.clearToken();
    await NotificationService.instance.updateAuthToken(null);
    notifyListeners();
  }
}
