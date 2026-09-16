import 'package:front_end/core/services/auth_storage.dart';

class AuthHelper {
  /// ✅ Get Access Token
  static Future<String?> getToken() async {
    return await AuthStorage.getToken();
  }

  /// ✅ Get User Email
  static Future<String?> getEmail() async {
    return await AuthStorage.getEmail();
  }

  /// ✅ Get User Name
  static Future<String?> getName() async {
    return await AuthStorage.getName();
  }

  /// ✅ Check if logged in
  static Future<bool> isLoggedIn() async {
    final token = await AuthStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}