import 'package:flutter/material.dart';
import 'package:ryaaans_store/core/storage/auth_storage.dart';
import '../api/api_service.dart';
import '../models/wallet_transaction.dart';

class WalletTransactionService {
  Future<List<WalletTransaction>> getMyTransactions(
    BuildContext context,
  ) async {
    // 1️⃣ اقرأ التوكن من التخزين
    final token = await AuthStorage.getToken();

    if (token == null) {
      throw Exception("User not authenticated");
    }

    // 2️⃣ مرر التوكن إلى ApiService
    final api = ApiService(token: token);

    final res = await api.get('/wallet/transactions');

    return (res as List)
        .map((e) => WalletTransaction.fromJson(e))
        .toList();
  }
}
