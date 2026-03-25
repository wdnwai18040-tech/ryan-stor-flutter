import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final Connectivity _connectivity = Connectivity();

  /// فحص الاتصال مرة واحدة
  Future<bool> hasInternet() async {
    final result = await _connectivity.checkConnectivity();

    if (result.contains(ConnectivityResult.none)) {
      return false;
    }

    return true;
  }

  /// مراقبة تغير الاتصال
  Stream<List<ConnectivityResult>> get onConnectionChanged {
    return _connectivity.onConnectivityChanged;
  }
}