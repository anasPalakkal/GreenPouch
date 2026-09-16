import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/api_config.dart';

class AuthService {

  static String get baseUrl => "${ApiConfig.baseUrl}/api";

  /// ---------------- REGISTER ----------------
  static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      return {
        "success": response.statusCode == 200 ||
            response.statusCode == 201,
        "message": data["message"] ?? "Registration failed",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Network error: $e",
      };
    }
  }

  /// ---------------- VERIFY OTP ----------------
  static Future<Map<String, dynamic>> verifyOtp(
    String email,
    String otp,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-email'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "otp": otp,
          "purpose": "signup", // ✅ FIXED (VERY IMPORTANT)
        }),
      );

      if (response.body.startsWith("<")) {
        return {
          "success": false,
          "message": "Wrong API endpoint",
        };
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {
        "success": false,
        "message": "Network error: $e",
      };
    }
  }

  /// ---------------- RESEND OTP ----------------
  static Future<Map<String, dynamic>> resendOtp(
    String email,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/otp/resend'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "purpose": "signup", // ✅ FIXED (VERY IMPORTANT)
        }),
      );

      final data = jsonDecode(response.body);

      return {
        "success": response.statusCode == 200,
        "message": data["message"] ?? "OTP resent",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Network error: $e",
      };
    }
  }
}