import 'dart:convert';
import 'package:http/http.dart' as http;

class AnalyticsService {
  static const String baseUrl = "http://localhost:5000/api/analytics";

  Map<String, String> _headers(String token) => {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

  Future<dynamic> _get(String endpoint, String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: _headers(token),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      return data["data"];
    } else {
      throw Exception(data["message"] ?? "API Error");
    }
  }

  Future getDashboard(String token, {String timeframe = "month"}) =>
      _get("/dashboard?timeframe=$timeframe", token);

  Future getGoalProgress(String token) =>
      _get("/progress", token);

  Future getCategoryStats(String token) =>
      _get("/category", token);

  Future getMonthlySavings(String token) =>
      _get("/monthly", token);

  Future getProgressDistribution(String token) =>
      _get("/progress-distribution", token);

  Future getAverageCompletion(String token) =>
      _get("/average-completion-time", token);

  Future getCategorySavings(String token) =>
      _get("/category-savings", token);
}