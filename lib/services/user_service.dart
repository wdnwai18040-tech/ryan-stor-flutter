import 'package:ryaaans_store/api/api_service.dart';
import '../models/user_model.dart';

class UserService {
  static Future<UserModel> getCurrentUser(String token) async {
    final api = ApiService(token: token);

    final data = await api.get('/user/me');

    return UserModel.fromJson(data);
  }

  static Future<void> updateUser({
    required String token,
    String? email,
    String? phone,
    required String currentPassword,
  }) async {
    final api = ApiService(token: token);

    await api.post('/user/me', {
      "email": email,
      "phone": phone,
      "currentPassword": currentPassword,
    });
  }

  static Future<void> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    final api = ApiService(token: token);

    await api.post('/user/change-password', {
      "oldPassword": oldPassword,
      "newPassword": newPassword,
    });
  }
}
