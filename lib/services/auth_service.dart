import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/auth_storage.dart';

class AuthService {
  Future<bool> login(String email, String password) async {
    try {
      final res = await apiClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = res.data['token'];
      await AuthStorage.saveToken(token);
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await AuthStorage.clear();
  }
}