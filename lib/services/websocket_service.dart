import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/order.dart';

class WebSocketService {
  static const String wsUrl = 'ws://192.168.137.1:8080/ws';

  WebSocketChannel? _channel;
  final StreamController<Order> _orderController = StreamController<Order>.broadcast();
  Timer? _reconnectTimer;
  bool _isConnected = false;

  Stream<Order> get orderStream => _orderController.stream;
  bool get isConnected => _isConnected;

  void connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;
      print('WebSocket connected');

      _channel!.stream.listen(
        (data) {
          try {
            final jsonData = jsonDecode(data);
            final order = Order.fromJson(jsonData);
            _orderController.add(order);
          } catch (e) {
            print('Error parsing order data: $e');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          print('WebSocket connection closed');
          _handleDisconnect();
        },
      );
    } catch (e) {
      print('WebSocket connection error: $e');
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      print('Attempting to reconnect...');
      connect();
    });
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _orderController.close();
  }
}
