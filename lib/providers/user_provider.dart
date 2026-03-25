import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? user;

  Future<void> refresh(String token) async {
    user = await UserService.getCurrentUser(token);
    notifyListeners();
  }

  void clear() {
    user = null;
    notifyListeners();
  }
}
