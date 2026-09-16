
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/api_config.dart';

class AuthService {

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {

    final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/login');

    try {

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email.trim(),
          "password": password.trim(),
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      /// DEBUG (optional)
      print("AUTH LOGIN RESPONSE: $data");

      if (response.statusCode == 200 && data["accessToken"] != null) {
        return data;
      }

      throw Exception(data["message"] ?? "Login failed");

    } catch (e) {

      print("AUTH LOGIN ERROR: $e");

      throw Exception("Network error. Please check your connection.");
    }
  }
}

