import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../models/account_model.dart';
import '../services/api_client.dart';    // ✅ JWT headers
import '../services/api_config.dart';    // ✅ centralized base URL

class AccountService {
  static String get baseUrl => "${ApiConfig.baseUrl}/api/account";

  // ================= GET ACCOUNTS =================

  static Future<Map<String, dynamic>> getAccountDashboard({String type = ""}) async {
    // ✅ No userId in URL — backend reads user from JWT
    Uri uri = Uri.parse('$baseUrl/balances');

    if (type.isNotEmpty && type.toUpperCase() != "ALL") {
      uri = uri.replace(queryParameters: {'type': type.toUpperCase()});
    }

    try {
      final headers = await ApiClient.getHeaders();  // ✅ Bearer token
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<AccountModel> accounts = (data['accounts'] as List)
            .map((acc) => AccountModel.fromJson(acc))
            .toList();

        return {'accounts': accounts};
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Connection Failed: $e");
    }
  }

  // ================= CREATE ACCOUNT =================
  static Future<void> createAccount({
    required String name,
    required String type,
    String initialDeposit = "0",
    String minBalance = "0",
  }) async {
    final headers = await ApiClient.getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'type': type.toUpperCase(),
        'initialDeposit': initialDeposit,
        'minBalance': minBalance,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Could not create account: ${response.body}");
    }
  }

  // ================= UPDATE ACCOUNT =================
  static Future<void> updateAccount(String accountId, {
    String? name,
    String? type,
    String? minBalance,
  }) async {
    final headers = await ApiClient.getHeaders();
    
    final Map<String, dynamic> body = {};
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (type != null && type.isNotEmpty) body['type'] = type.toUpperCase();
    if (minBalance != null && minBalance.isNotEmpty) body['minBalance'] = minBalance;

    final response = await http.put(
      Uri.parse('$baseUrl/$accountId'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception("Could not update account: ${response.body}");
    }
  }

  // ================= SET PRIMARY =================

  static Future<bool> setPrimaryAccount(String accountId) async {
    try {
      final headers = await ApiClient.getHeaders();  // ✅ Bearer token

      final response = await http.patch(
        Uri.parse('$baseUrl/$accountId/default'),
        headers: headers,
      );
      
      if (response.statusCode != 200) {
        debugPrint("Server rejected default update: ${response.body}");
      }
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Failed to set primary account: $e");
      return false;
    }
  }

  // ================= DELETE ACCOUNT =================

  static Future<Map<String, dynamic>> deleteAccount(String accountId) async {
    try {
      final headers = await ApiClient.getHeaders();  // ✅ Bearer token

      final response = await http.delete(
        Uri.parse('$baseUrl/$accountId'),
        headers: headers,
      );

      // SAFE PARSING: Prevent crash if backend returns HTML stack trace on 500 error
      Map<String, dynamic> data = {};
      try {
        data = json.decode(response.body);
      } catch (_) {
        data = {'message': response.body}; 
      }

      if (response.statusCode == 200) {
        return {
          'success': true, 
          'message': data['message'] ?? 'Account deleted successfully'
        };
      } else {
        return {
          'success': false, 
          'message': data['error'] ?? data['message'] ?? 'Failed to delete account (Code: ${response.statusCode})'
        };
      }
    } catch (e) {
      debugPrint("Failed to delete account: $e");
      return {
        'success': false, 
        'message': 'Connection error: $e'
      };
    }
  }
}