import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/order.dart';

class OrderService {
  // Use a relative path for API calls, which is more robust.
  static const String baseUrl = 'http://192.168.137.1:8080/api';
  static const String ordersBoxName = 'orders';

  Future<List<Order>> fetchOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final orders = data.map((json) => Order.fromJson(json)).toList();

        await _cacheOrders(orders);
        return orders;
      }
      return await _getCachedOrders();
    } catch (e) {
      print('Fetch orders error: $e');
      return await _getCachedOrders();
    }
  }

  Future<Order?> createOrder({
    required String toyId,
    required String toyName,
    required String category,
    required String rfidUid,
    required String assignedPerson,
    required String department,
    required double totalAmount,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'toy_id': toyId,
          'toy_name': toyName,
          'category': category,
          'rfid_uid': rfidUid,
          'assigned_person': assignedPerson,
          'department': department,
          'total_amount': totalAmount,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Order.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Create order error: $e');
      return null;
    }
  }

  Future<void> _cacheOrders(List<Order> orders) async {
    try {
      final box = await Hive.openBox<Order>(ordersBoxName);
      await box.clear();
      for (var order in orders) {
        await box.put(order.id, order);
      }
    } catch (e) {
      print('Cache orders error: $e');
    }
  }

  Future<List<Order>> _getCachedOrders() async {
    try {
      final box = await Hive.openBox<Order>(ordersBoxName);
      return box.values.toList();
    } catch (e) {
      print('Get cached orders error: $e');
      return [];
    }
  }

  Future<List<Order>> getOrdersByStatus(String status) async {
    final orders = await _getCachedOrders();
    return orders.where((order) => order.status == status).toList();
  }
}
