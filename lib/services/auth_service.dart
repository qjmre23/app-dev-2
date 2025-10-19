import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user.dart';

class AuthService {
  // Use a relative path for API calls, which is more robust.
  static const String baseUrl = 'http://192.168.137.1:8080/api';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  Future<User?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        final token = data['token'];

        await _saveAuthData(token, user);
        return user.copyWith(token: token);
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<User?> signup(String username, String email, String password, String department) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'department': department,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        final token = data['token'];

        await _saveAuthData(token, user);
        return user.copyWith(token: token);
      }
      return null;
    } catch (e) {
      print('Signup error: $e');
      return null;
    }
  }

  Future<void> _saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setString(userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(tokenKey);
      final userData = prefs.getString(userKey);

      if (token != null && userData != null && !JwtDecoder.isExpired(token)) {
        final user = User.fromJson(jsonDecode(userData));
        return user.copyWith(token: token);
      }
      return null;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      return true;
    }
    return false;
  }
}
