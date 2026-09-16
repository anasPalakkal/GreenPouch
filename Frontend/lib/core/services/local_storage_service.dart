import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _jwtKey = "auth_jwt";

  // =============================
  // Save JWT
  // =============================
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _jwtKey, value: token);
  }

  // =============================
  // Get JWT
  // =============================
  static Future<String?> getToken() async {
    return await _storage.read(key: _jwtKey);
  }

  // =============================
  // Delete JWT (Logout)
  // =============================
  static Future<void> deleteToken() async {
    await _storage.delete(key: _jwtKey);
  }

  // =============================
  // Check if Logged In
  // =============================
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}