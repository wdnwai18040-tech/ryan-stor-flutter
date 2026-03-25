import 'package:flutter/material.dart';
import '../exceptions/session_expired_exception.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? user;
  bool isLoading = false;
  String? error;

  Future<void> refresh(String token) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      user = await UserService.getCurrentUser(token);
    } on SessionExpiredException {
      user = null;
      error = 'session_expired';
      rethrow;
    } catch (_) {
      user = null;
      error = 'load_failed';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    user = null;
    error = null;
    isLoading = false;
    notifyListeners();
  }
}
