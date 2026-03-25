import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryaaans_store/models/order_model.dart';
import '../api/api_service.dart';
import '../providers/auth_provider.dart';

class OrderService {
  Future<List<Order>> getMyOrders(BuildContext context) async {
    final token = context.read<AuthProvider>().token;

    final api = ApiService(token: token);

    final res = await api.get('/orders/my');

    return (res as List).map((e) => Order.fromJson(e)).toList();
  }

  Future<Order> getOrderDetails(BuildContext context, int orderId) async {
    final token = context.read<AuthProvider>().token;

    final api = ApiService(token: token);

    final res = await api.get('/orders/$orderId');

    return Order.fromJson(res);
  }
}
