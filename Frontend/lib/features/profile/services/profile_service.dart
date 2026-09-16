import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/services/api_config.dart';
import '../../../core/services/auth_storage.dart';
import '../../../core/services/auth_service.dart';

class ProfileService {

  static Future<bool> updateProfile(String name) async {
    try {

      String? token = await AuthStorage.getToken();
      final email = await AuthStorage.getEmail();
      final refreshToken = await AuthStorage.getRefreshToken();

      http.Response response = await http.patch(
        Uri.parse("${ApiConfig.baseUrl}/api/user/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"name": name}),
      );

      /// 🔥 HANDLE TOKEN EXPIRED
      if (response.statusCode == 401) {
        print("Access token expired → refreshing...");

        final newToken = await AuthService.refreshAccessToken();

        /// ❌ Refresh failed → logout
        if (newToken == null) {
          await AuthStorage.logout();
          return false;
        }

        /// 🔁 RETRY REQUEST WITH NEW TOKEN
        response = await http.patch(
          Uri.parse("${ApiConfig.baseUrl}/api/user/profile"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $newToken",
          },
          body: jsonEncode({"name": name}),
        );

        token = newToken; // update local reference
      }

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      /// ✅ SUCCESS
      if (response.statusCode == 200) {

        await AuthStorage.saveUser(
          token: token ?? "",
          refreshToken: refreshToken ?? "",
          name: name,
          email: email ?? "",
        );

        return true;
      }

      return false;

    } catch (e) {
      print("ERROR: $e");
      return false;
    }
  }
}