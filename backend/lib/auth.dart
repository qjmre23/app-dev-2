import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  static const String secretKey = 'smart_toy_store_secret_key_2024';

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  static bool verifyPassword(String password, String hash) {
    return hashPassword(password) == hash;
  }

  static String generateToken(String userId, String username, String department) {
    final jwt = JWT({
      'user_id': userId,
      'username': username,
      'department': department,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch ~/ 1000,
    });

    return jwt.sign(SecretKey(secretKey));
  }

  static Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(secretKey));
      return jwt.payload;
    } catch (e) {
      print('Token verification error: $e');
      return null;
    }
  }
}
