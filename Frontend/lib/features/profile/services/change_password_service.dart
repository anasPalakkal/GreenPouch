import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/services/api_config.dart';
import 'package:front_end/core/services/auth_storage.dart';

class ChangePasswordService {
  static Future<Map<String, dynamic>> changePassword(
      String currentPassword,
      String newPassword) async {

    final token = await AuthStorage.getToken();

    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/user/password'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "currentPassword": currentPassword,
        "newPassword": newPassword
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data["message"] ?? "Password change failed");
    }

    return data;
  }
}