import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'api_config.dart';

class NotificationService {
  static String get baseUrl => "${ApiConfig.baseUrl}/api/notifications";

  static Future<List<dynamic>> fetchNotifications() async {
    try {
      final headers = await ApiClient.getHeaders();
      final response = await http.get(Uri.parse(baseUrl), headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 🔥 NEW: PATCH request for a single notification
  static Future<bool> markAsRead(String id) async {
    try {
      final headers = await ApiClient.getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/$id/read'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> markAllAsRead() async {
    try {
      final headers = await ApiClient.getHeaders();
      final response =
          await http.patch(Uri.parse('$baseUrl/read-all'), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  // ... existing code ...

  // 🔥 DELETE SINGLE (Separate Clear)
  static Future<bool> deleteNotification(String id) async {
    try {
      final headers = await ApiClient.getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'), // Hits router.delete('/:id')
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 🔥 DELETE ALL (Super Clear)
  static Future<bool> deleteAllNotifications() async {
    try {
      final headers = await ApiClient.getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/delete-all'), // Hits router.delete('/delete-all')
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 🔥 UPDATE FCM TOKEN
  static Future<void> updateFcmToken(String fcmToken) async {
    try {
      final headers = await ApiClient.getHeaders();
      // [PROD] Use dedicated user endpoint for token registration.
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/api/user/fcm-token'),
        headers: headers,
        body: json.encode({'fcmToken': fcmToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ FCM token registered — HTTP ${response.statusCode}");
      } else {
        debugPrint(
            "❌ FCM token registration failed — HTTP ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ FCM token registration threw an error: $e");
    }
  }
}
