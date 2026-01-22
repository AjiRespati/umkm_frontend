import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static final _storage = const FlutterSecureStorage();

  static Future<void> saveToken(String token) async =>
      await _storage.write(key: 'jwt_token', value: token);

  static Future<String?> getToken() async =>
      await _storage.read(key: 'jwt_token');

  static Future<void> clear() async => await _storage.deleteAll();
}