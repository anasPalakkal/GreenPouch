
import 'auth_storage.dart';

class ApiClient {
  static Future<Map<String, String>> getHeaders() async {
    final token = await AuthStorage.getToken();

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }
}