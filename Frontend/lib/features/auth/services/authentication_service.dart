import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:front_end/core/services/api_config.dart';

class AuthService {

  static String get baseUrl => "${ApiConfig.baseUrl}/api";

  /// SEND OTP
  static Future<String?> forgotPassword(String email) async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/forgot-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data["message"];
    }

    return data["message"];

  } catch (e) {
    print("ERROR: $e");
    return null;
  }
}

  /// VERIFY OTP
  static Future<String?> verifyOtp(String email, String otp) async {

    final response = await http.post(
      Uri.parse("$baseUrl/otp/verify"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
        "purpose": "reset_password"
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["resetToken"];
    }

    return null;
  }

  // resend otp
static Future<bool> resendOtp(String email) async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/otp/resend"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "purpose": "reset_password"
      }),
    );

    print("Resend OTP response: ${response.statusCode} ${response.body}");

    if (response.statusCode == 200) {
      // Backend returns a message, assume success if 200
      return true;
    }

    return false;
  } catch (e) {
    print("Resend OTP ERROR: $e");
    return false;
  }
}

  /// RESET PASSWORD
  static Future<bool> resetPassword(
      String resetToken, String password) async {

    final response = await http.post(
      Uri.parse("$baseUrl/auth/reset-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "resetToken": resetToken,
        "newPassword": password
      }),
    );

    return response.statusCode == 200;
  }
}
