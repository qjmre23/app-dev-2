import 'dart:convert';
import 'dart:io';
import 'models.dart';

class Database {
  static final Database _instance = Database._internal();
  factory Database() => _instance;
  Database._internal();

  final String _dataPath = 'data';
  final Map<String, User> _users = {};
  final Map<String, Order> _orders = {};

  Future<void> initialize() async {
    final dir = Directory(_dataPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    await _loadUsers();
    await _loadOrders();
  }

  Future<void> _loadUsers() async {
    try {
      final file = File('$_dataPath/users.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isEmpty) return;
        final dynamic data = jsonDecode(content);
        if (data is List) {
          for (var json in data) {
            final user = User.fromJson(json);
            _users[user.id] = user;
          }
        }
      }
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Future<void> _loadOrders() async {
    try {
      final file = File('$_dataPath/orders.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isEmpty) return;
        final dynamic data = jsonDecode(content);
        if (data is List) {
          for (var json in data) {
            final order = Order.fromJson(json);
            _orders[order.id] = order;
          }
        }
      }
    } catch (e) {
      print('Error loading orders: $e');
    }
  }

  Future<void> _saveUsers() async {
    final file = File('$_dataPath/users.json');
    final data = _users.values.map((u) => u.toJson()).toList();
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> _saveOrders() async {
    final file = File('$_dataPath/orders.json');
    final data = _orders.values.map((o) => o.toJson()).toList();
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> clearAllOrders() async {
    _orders.clear();
    await _saveOrders();
  }

  Future<User> createUser(User user) async {
    _users[user.id] = user;
    await _saveUsers();
    return user;
  }

  User? getUserByUsername(String username) {
    try {
      return _users.values.firstWhere((user) => user.username == username);
    } catch (e) {
      return null;
    }
  }

  Future<Order> createOrder(Order order) async {
    _orders[order.id] = order;
    await _saveOrders();
    return order;
  }

  Future<Order> updateOrder(Order order) async {
    _orders[order.id] = order;
    await _saveOrders();
    return order;
  }

  Order? getOrderByRfidUid(String rfidUid) {
    try {
      return _orders.values.firstWhere((order) => order.rfidUid == rfidUid);
    } catch (e) {
      return null;
    }
  }

  List<Order> getAllOrders() {
    return _orders.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
