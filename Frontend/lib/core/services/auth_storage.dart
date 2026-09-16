import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {

  static const _storage = FlutterSecureStorage();

  // 🔑 Keys
  static const tokenKey = "auth_token";
  static const refreshTokenKey = "refresh_token";
  static const nameKey = "user_name";
  static const emailKey = "user_email";

  /// ================================
  /// ✅ SAVE USER DATA (ACCESS + REFRESH TOKEN)
  /// ================================
  static Future<void> saveUser({
    required String token,
    required String refreshToken,
    required String name,
    required String email,
  }) async {
    await _storage.write(key: tokenKey, value: token);
    await _storage.write(key: refreshTokenKey, value: refreshToken);
    await _storage.write(key: nameKey, value: name);
    await _storage.write(key: emailKey, value: email);
  }

  /// ================================
  /// 🔑 GET ACCESS TOKEN
  /// ================================
  static Future<String?> getToken() async {
    return await _storage.read(key: tokenKey);
  }

  /// 🔄 GET REFRESH TOKEN
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: refreshTokenKey);
  }

  /// 👤 GET NAME
  static Future<String?> getName() async {
    return await _storage.read(key: nameKey);
  }

  /// 📧 GET EMAIL
  static Future<String?> getEmail() async {
    return await _storage.read(key: emailKey);
  }

  /// ================================
  /// ✏️ UPDATE NAME ONLY
  /// ================================
  static Future<void> updateName(String name) async {
    await _storage.write(key: nameKey, value: name);
  }

  /// ================================
  /// 🔄 UPDATE ONLY ACCESS TOKEN (after refresh)
  /// ================================
  static Future<void> updateAccessToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
  }

  /// 🔄 UPDATE BOTH TOKENS (after refresh rotation)
  static Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: tokenKey, value: accessToken);
    await _storage.write(key: refreshTokenKey, value: refreshToken);
  }

  /// ================================
  /// 🚪 LOGOUT (CLEAR EVERYTHING)
  /// ================================
  static Future<void> logout() async {
    await _storage.deleteAll();
  }
}