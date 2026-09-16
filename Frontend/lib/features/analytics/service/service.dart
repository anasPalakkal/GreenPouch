import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:front_end/core/services/api_config.dart';
import '../../../../core/services/api_client.dart';
import '../data/analytics_model.dart';

class AnalyticsService {
  /// Fetches the dashboard data using dynamic query parameters
  /// timeframe: 'Day', 'Week', 'Month', 'Year', 'Custom'
  /// accountId: 'all' or a specific MongoDB ObjectId
  /// month & year: Specific strings for custom month filtering
  static Future<AnalyticsModel> getDashboardData({
    String accountId = "all", 
    String timeframe = "Month",
    String? month, // 🔥 Added month parameter
    String? year,  // 🔥 Added year parameter
  }) async {
    try {
      final headers = await ApiClient.getHeaders();
      
      // 1. Build the query parameters map dynamically
      final Map<String, dynamic> queryParams = {};
      
      if (accountId != "all") {
        queryParams['accountId'] = accountId;
      }
      
      // Only send timeframe if it's not the "Custom" flag we use in the provider
      if (timeframe != 'Custom') {
        queryParams['timeframe'] = timeframe;
      }
      
      // Attach month and year if they were provided
      if (month != null) {
        queryParams['month'] = month;
      }
      if (year != null) {
        queryParams['year'] = year;
      }

      // 2. Build the URL safely using Uri.replace
      final baseUrl = Uri.parse("${ApiConfig.baseUrl}/api/analytics/dashboard");
      final url = baseUrl.replace(queryParameters: queryParams);

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        if (json['success'] == true) {
          // Pass the JSON to the factory constructor in your model
          return AnalyticsModel.fromJson(json);
        } else {
          throw Exception(json['message'] ?? "Failed to parse dashboard data");
        }
      } else {
        // Handle unauthorized or server errors
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      // Re-throw so the Provider can catch it and update the 'error' state
      throw Exception("AnalyticsService: $e");
    }
  }
}