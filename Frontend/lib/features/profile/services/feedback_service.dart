import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/api_config.dart';

class FeedbackService {
  static String get baseUrl => "${ApiConfig.baseUrl}/api/feedback";

  /// ⭐ UPDATE RATING
  static Future<void> updateRating(int rating, String token) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/rating"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"rating": rating}),
    );

    if (response.statusCode != 200) {
      throw Exception("Rating failed: ${response.body}");
    }
  }

  /// 📝 SUBMIT FEEDBACK
  static Future<void> submitFeedback({
    required String token,
    required String category,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "category": category,
        "description": description,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Submit failed: ${response.body}");
    }
  }
}