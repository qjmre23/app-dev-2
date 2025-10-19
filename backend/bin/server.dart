import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../lib/database.dart';
import '../lib/models.dart';
import '../lib/auth.dart';

final _clients = <WebSocketChannel>[];
final _db = Database();
final _uuid = Uuid();

void main() async {
  await _db.initialize();
  print('Database initialized');

  final apiRouter = Router();
  apiRouter.post('/api/login', _loginHandler);
  apiRouter.post('/api/signup', _signupHandler);
  apiRouter.post('/api/orders', _createOrderHandler);
  apiRouter.post('/api/updateStatus', _updateStatusHandler);
  apiRouter.get('/api/orders', _getOrdersHandler);
  // ADDED: New endpoint to clear all orders.
  apiRouter.post('/api/orders/clear', _clearOrdersHandler);
  
  apiRouter.get('/ws', webSocketHandler((WebSocketChannel webSocket, String? protocol) {
    _clients.add(webSocket);
    print('WebSocket client connected. Total clients: ${_clients.length}');
    webSocket.stream.listen((message) {},
     onDone: () {
      _clients.remove(webSocket);
      print('WebSocket client disconnected. Total clients: ${_clients.length}');
    });
  }));

  final dashboardPath = p.normalize(p.join(Directory.current.path, '..', 'dashboard'));
  final staticHandler = createStaticHandler(dashboardPath, defaultDocument: 'index.html');

  final cascade = Cascade().add(apiRouter.call).add(staticHandler);

  final server = await shelf_io.serve(
    const Pipeline().addMiddleware(logRequests()).addHandler(cascade.handler),
    '0.0.0.0',
    8080,
  );

  print('Server running on http://${server.address.host}:${server.port}');
  print('Dashboard available at http://${server.address.host}:${server.port}');
}

// ADDED: Handler to clear all orders from the database.
Future<Response> _clearOrdersHandler(Request request) async {
  await _db.clearAllOrders();
  // Inform all connected clients that the data has changed.
  _broadcastToClients({'type': 'clear'});
  print('All orders have been cleared.');
  return Response.ok(jsonEncode({'message': 'All orders cleared successfully'}));
}

Future<Response> _getOrdersHandler(Request request) async {
    final orders = _db.getAllOrders();
    return Response.ok(jsonEncode(orders.map((o) => o.toJson()).toList()),
        headers: {'Content-Type': 'application/json'});
}

Future<Response> _loginHandler(Request request) async {
  final payload = await request.readAsString();
  final data = jsonDecode(payload);
  final user = _db.getUserByUsername(data['username']);
  if (user == null || !AuthService.verifyPassword(data['password'], user.passwordHash)) {
    return Response.unauthorized(jsonEncode({'error': 'Invalid credentials'}));
  }
  final token = AuthService.generateToken(user.id, user.username, user.department);
  return Response.ok(jsonEncode({'user': user.toJson(), 'token': token}), headers: {'Content-Type': 'application/json'});
}

Future<Response> _signupHandler(Request request) async {
  final payload = await request.readAsString();
  final data = jsonDecode(payload);
  final user = User(
    id: _uuid.v4(),
    username: data['username'],
    email: data['email'],
    passwordHash: AuthService.hashPassword(data['password']),
    department: "General", // Default department for customers
    createdAt: DateTime.now(),
  );
  await _db.createUser(user);
  final token = AuthService.generateToken(user.id, user.username, user.department);
  return Response(201, body: jsonEncode({'user': user.toJson(), 'token': token}), headers: {'Content-Type': 'application/json'});
}

Future<Response> _createOrderHandler(Request request) async {
    final authHeader = request.headers['authorization'];
    if (authHeader == null) return Response.unauthorized(jsonEncode({'error': 'Unauthorized'}));
    final token = authHeader.replaceFirst('Bearer ', '');
    final payload = AuthService.verifyToken(token);
    if (payload == null) return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));

    final body = await request.readAsString();
    final data = jsonDecode(body);
    final order = Order(
      id: _uuid.v4(),
      toyId: data['toy_id'],
      toyName: data['toy_name'],
      category: data['category'],
      rfidUid: data['rfid_uid'],
      assignedPerson: data['assigned_person'],
      status: 'PENDING',
      createdAt: DateTime.now(),
      department: data['department'],
      totalAmount: (data['total_amount'] ?? 0).toDouble(),
    );
    await _db.createOrder(order);
    _broadcastToClients(order.toJson());
    return Response(201, body: jsonEncode(order.toJson()), headers: {'Content-Type': 'application/json'});
}

Future<Response> _updateStatusHandler(Request request) async {
  final payload = await request.readAsString();
  final data = jsonDecode(payload);
  final rfidUid = data['rfid_uid'];
  final order = _db.getOrderByRfidUid(rfidUid);
  if (order == null) return Response.notFound(jsonEncode({'error': 'Order not found'}));
  
  final updatedOrder = order.copyWith(status: data['status'], updatedAt: DateTime.now());
  await _db.updateOrder(updatedOrder);
  _broadcastToClients(updatedOrder.toJson());
  return Response.ok(jsonEncode(updatedOrder.toJson()), headers: {'Content-Type': 'application/json'});
}

void _broadcastToClients(Map<String, dynamic> data) {
  final message = jsonEncode(data);
  for (final client in _clients) {
    try {
      client.sink.add(message);
    } catch (e) {
      // Ignore errors for disconnected clients
    }
  }
}
