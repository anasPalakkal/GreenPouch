import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_storage.dart';

class AuthService {

  static Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await AuthStorage.getRefreshToken();

      if (refreshToken == null) return null;

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/auth/refresh"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "refreshToken": refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final newAccessToken = data["accessToken"];
        final newRefreshToken = data["refreshToken"];

        await AuthStorage.saveUser(
          token: newAccessToken,
          refreshToken: newRefreshToken,
          name: await AuthStorage.getName() ?? "",
          email: await AuthStorage.getEmail() ?? "",
        );

        return newAccessToken;
      }

      return null;

    } catch (e) {
      return null;
    }
  }
}