import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/wallet_model.dart';

class WalletProvider with ChangeNotifier {
  String? _token;
  WalletModel? _wallet;
  bool _loading = false;
  DateTime? _lastFetch;

  WalletModel? get wallet => _wallet;
  double get balance => _wallet?.balance ?? 0.0;
  bool get isLoading => _loading;

  // 🔄 يتم استدعاؤها من ProxyProvider
  void updateToken(String? token) {
    if (_token != token) {
      _token = token;
      _wallet = null;
      _lastFetch = null;
      notifyListeners();
    }
  }

  Future<void> refresh({bool force = false}) async {
    if (_token == null) return;

    if (!force &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!).inSeconds < 30) {
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      final api = ApiService(token: _token);
      final response = await api.get('/wallet');

      _wallet = WalletModel.fromJson(response);
      _lastFetch = DateTime.now();
    } catch (e) {
      debugPrint('Wallet error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _wallet = null;
    _lastFetch = null;
    notifyListeners();
  }
}
