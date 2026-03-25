import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PurchaseRequestManager {
  static const _key = 'active_purchase_request_id';

  /// توليد أو استرجاع request_id الحالي
  static Future<String> getOrCreateRequestId() async {
    final prefs = await SharedPreferences.getInstance();

    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final newId = const Uuid().v4();
    await prefs.setString(_key, newId);
    return newId;
  }

  /// مسح request_id بعد نجاح العملية
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
