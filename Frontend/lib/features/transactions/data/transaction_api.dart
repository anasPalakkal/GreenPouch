import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/services/local_storage_service.dart';

class TransactionApi {
  static const String baseUrl = "https://your-api.com"; // 🔁 Replace with your API

  // =========================================
  // Common Headers Builder (JWT Included)
  // =========================================
  Future<Map<String, String>> _buildHeaders() async {
    final token = await LocalStorageService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("User not authenticated");
    }

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // =========================================
  // GET All Transactions
  // =========================================
  Future<List<dynamic>> getTransactions() async {
    final headers = await _buildHeaders();

    final response = await http.get(
      Uri.parse("$baseUrl/transactions"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized - Token expired");
    } else {
      throw Exception("Failed to load transactions");
    }
  }

  // =========================================
  // GET Single Transaction
  // =========================================
  Future<Map<String, dynamic>> getTransactionById(String id) async {
    final headers = await _buildHeaders();

    final response = await http.get(
      Uri.parse("$baseUrl/transactions/$id"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      throw Exception("Transaction not found");
    }
  }

  // =========================================
  // CREATE Transaction
  // =========================================
  Future<Map<String, dynamic>> createTransaction(
      Map<String, dynamic> data) async {
    final headers = await _buildHeaders();

    final response = await http.post(
      Uri.parse("$baseUrl/transactions"),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      throw Exception("Failed to create transaction");
    }
  }

  // =========================================
  // DELETE Transaction
  // =========================================
  Future<void> deleteTransaction(String id) async {
    final headers = await _buildHeaders();

    final response = await http.delete(
      Uri.parse("$baseUrl/transactions/$id"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      throw Exception("Failed to delete transaction");
    }
  }
}