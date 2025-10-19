import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../services/supabase_service.dart';

class AppProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  User? _currentUser;
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _supabaseService.client.auth.currentUser != null;

  AppProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final user = _supabaseService.client.auth.currentUser;
    if (user != null) {
      final userData = await _supabaseService.client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (userData != null) {
        _currentUser = User.fromJson(userData);
        await loadOrders();
        _setupRealtimeSubscription();
      }
    }
    notifyListeners();
  }

  void _setupRealtimeSubscription() {
    final userId = _supabaseService.client.auth.currentUser?.id;
    if (userId == null) return;

    _supabaseService.client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((data) {
          _orders = data.map((json) => Order.fromJson(json)).toList();
          _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          notifyListeners();
        });
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _supabaseService.signIn(email: email, password: password);
      if (response != null) {
        _currentUser = User.fromJson(response['user']);
        await loadOrders();
        _setupRealtimeSubscription();
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _errorMessage = 'Invalid email or password';
    }

    _setLoading(false);
    return false;
  }

  Future<bool> signup(String username, String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        username: username,
      );
      if (response != null) {
        _currentUser = User.fromJson(response['user']);
        _setupRealtimeSubscription();
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _errorMessage = 'Signup failed. Please try again.';
    }

    _setLoading(false);
    return false;
  }

  Future<void> logout() async {
    await _supabaseService.signOut();
    _currentUser = null;
    _orders = [];
    notifyListeners();
  }

  Future<void> loadOrders() async {
    if (_currentUser == null) return;

    _setLoading(true);
    final ordersData = await _supabaseService.getUserOrders();
    _orders = ordersData.map((json) => Order.fromJson(json)).toList();
    _setLoading(false);
  }

  Future<bool> createOrder({
    required String toyId,
    required String toyName,
    required String category,
    required String rfidUid,
    required String assignedPerson,
    required double totalAmount,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    try {
      final orderData = await _supabaseService.createOrder(
        toyId: toyId,
        toyName: toyName,
        category: category,
        rfidUid: rfidUid,
        totalAmount: totalAmount,
      );

      if (orderData != null) {
        final order = Order.fromJson(orderData);
        _orders.insert(0, order);
        _setLoading(false);
        return true;
      }
    } catch (e) {
      print('Create order error: $e');
    }

    _setLoading(false);
    return false;
  }

  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
