import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    // Assume using an Android emulator (10.0.2.2) or iOS simulator (localhost)
    // You may need to change this depending on your environment.
    baseUrl: 'http://10.0.2.2:3000/api/auth',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
  
  final _storage = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        await _storage.write(key: 'jwt_token', value: token);
        return true;
      }
      return false;
    } catch (e) {
      print('Login Error: $e');
      throw Exception('Failed to login. Please check your credentials.');
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      final response = await _dio.post('/register', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print('Register Error: $e');
      throw Exception('Registration failed. Email might already exist.');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: 'jwt_token');
    return token != null;
  }
}

final authService = AuthService();
