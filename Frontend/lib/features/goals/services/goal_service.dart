import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../data/goal_model.dart';
import 'package:front_end/core/services/api_client.dart';

class GoalService {
  final String baseUrl;

  GoalService({required this.baseUrl});

  // 🛡️ Helper: Safely decode JSON
  dynamic _safeJsonDecode(http.Response response) {
    if (response.headers['content-type']?.contains('application/json') != true) {
      throw const FormatException("Invalid server response format. Expected JSON.");
    }
    return jsonDecode(response.body);
  }

  // 🚨 Helper: Extract backend error messages
  String _extractErrorMessage(http.Response response) {
    try {
      final decoded = _safeJsonDecode(response);
      if (decoded is Map && decoded.containsKey('message')) {
        return decoded['message'];
      }
      return "Server Error: ${response.statusCode}";
    } catch (_) {
      return "An unexpected server error occurred (${response.statusCode}).";
    }
  }

  // 🚨 Helper: Format connection errors
  String _formatCatchError(dynamic e) {
    if (e is TimeoutException) return "Connection timed out. Please check your internet.";
    if (e is FormatException) return "Server configuration error. Try again later.";
    return "Network error. Please try again.";
  }

  /// GET ALL GOALS
  Future<List<GoalModel>> getGoals({int page = 1, int limit = 20, String? status}) async {
    try {
      final headers = await ApiClient.getHeaders();
      String query = "?page=$page&limit=$limit";
      if (status != null) query += "&status=$status";

      final response = await http
          .get(Uri.parse("$baseUrl/goals$query"), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic body = _safeJsonDecode(response);
        List data = [];
        if (body is Map && body.containsKey('data')) {
          data = body['data'];
        } else if (body is List) {
          data = body;
        }
        return data.map((json) => GoalModel.fromJson(json)).toList();
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      throw Exception(_formatCatchError(e));
    }
  }

  /// CREATE GOAL
  Future<Map<String, dynamic>> createGoal(GoalModel goal) async {
    try {
      final headers = await ApiClient.getHeaders();
      final response = await http
          .post(
            Uri.parse("$baseUrl/goals"),
            headers: headers,
            body: jsonEncode(goal.toJson(isCreate: true)),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'message': _extractErrorMessage(response)};
      }
    } catch (e) {
      return {'success': false, 'message': _formatCatchError(e)};
    }
  }

  /// UPDATE GOAL
  Future<Map<String, dynamic>> updateGoal(GoalModel goal) async {
    try {
      final headers = await ApiClient.getHeaders();
      final response = await http
          .put(
            Uri.parse("$baseUrl/goals/${goal.id}"),
            headers: headers,
            body: jsonEncode(goal.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'message': _extractErrorMessage(response)};
      }
    } catch (e) {
      return {'success': false, 'message': _formatCatchError(e)};
    }
  }

  /// DEPOSIT MONEY TO GOAL
  Future<Map<String, dynamic>> depositToGoal(
    String goalId,
    String accountId,
    double amount,
    String idempotencyKey, {
    String? transactedAt,
  }) async {
    try {
      final headers = await ApiClient.getHeaders();
      final Map<String, dynamic> body = {
        "accountId": accountId,
        "amount": amount,
        "idempotencyKey": idempotencyKey,
        if (transactedAt != null) "transactedAt": transactedAt,
      };

      final response = await http
          .post(
            Uri.parse("$baseUrl/goals/$goalId/deposit"),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 409) {
        final decoded = _safeJsonDecode(response);
        return {
          'success': true,
          'txid': decoded['txid'],
          'availableBalance': decoded['availableBalance'],
          'isDuplicate': response.statusCode == 409
        };
      } else {
        return {'success': false, 'message': _extractErrorMessage(response)};
      }
    } catch (e) {
      return {'success': false, 'message': _formatCatchError(e)};
    }
  }

  /// WITHDRAW MONEY FROM GOAL
  Future<Map<String, dynamic>> withdrawFromGoal(
    String goalId,
    String accountId,
    double amount,
    String idempotencyKey, {
    String? transactedAt,
  }) async {
    try {
      final headers = await ApiClient.getHeaders();
      final Map<String, dynamic> body = {
        "accountId": accountId,
        "amount": amount,
        "idempotencyKey": idempotencyKey,
        if (transactedAt != null) "transactedAt": transactedAt,
      };

      final response = await http
          .post(
            Uri.parse("$baseUrl/goals/$goalId/withdraw"),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 409) {
        final decoded = _safeJsonDecode(response);
        return {
          'success': true,
          'txid': decoded['txid'],
          'availableBalance': decoded['availableBalance'],
          'isDuplicate': response.statusCode == 409
        };
      } else {
        return {'success': false, 'message': _extractErrorMessage(response)};
      }
    } catch (e) {
      return {'success': false, 'message': _formatCatchError(e)};
    }
  }

  /// DELETE GOAL
  Future<Map<String, dynamic>> deleteGoal(String goalId) async {
    try {
      final headers = await ApiClient.getHeaders();
      final response = await http
          .delete(Uri.parse("$baseUrl/goals/$goalId"), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      } else {
        return {'success': false, 'message': _extractErrorMessage(response)};
      }
    } catch (e) {
      return {'success': false, 'message': _formatCatchError(e)};
    }
  }

  /// GET INDIVIDUAL GOAL TRANSACTION HISTORY
  Future<List<dynamic>> getGoalHistory(String goalId) async {
    try {
      final headers = await ApiClient.getHeaders();
      final response = await http
          .get(
            Uri.parse("$baseUrl/goals/$goalId/history"),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = _safeJsonDecode(response);
        return body['data'] is List ? body['data'] : [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}