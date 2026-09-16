import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../services/account_service.dart';

class AccountProvider extends ChangeNotifier {
  bool isLoading = true;

  List<AccountModel> cashAccounts = [];
  List<AccountModel> bankAccounts = [];
  AccountModel? defaultAccount;

  double totalCash = 0;
  double totalBank = 0;
  double totalAll = 0;

  // 🛠️ FIX: Replaced the null getter with the actual combined list!
  List<AccountModel> get accounts => [...cashAccounts, ...bankAccounts];

  /// Load accounts dashboard
  Future<void> loadAccounts() async {
    isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> data =
          await AccountService.getAccountDashboard();

      final List<AccountModel> all =
          (data['accounts'] as List<dynamic>?)?.cast<AccountModel>() ?? [];

      /// Separate accounts
      cashAccounts = all.where((a) => a.type == "CASH").toList();
      bankAccounts = all.where((a) => a.type == "BANK").toList();

      /// Default account
      if (all.isNotEmpty) {
        defaultAccount =
            all.firstWhere((acc) => acc.isDefault, orElse: () => all.first);
      }

      /// Totals
      totalCash =
          cashAccounts.fold(0, (sum, item) => sum + double.parse(item.totalBalance));

      totalBank =
          bankAccounts.fold(0, (sum, item) => sum + double.parse(item.totalBalance));

      totalAll = totalCash + totalBank;

    } catch (e) {
      debugPrint("AccountProvider error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// Set primary account
  Future<void> setPrimary(String accountId) async {
    // 🛠️ FIX: Calls the Service, doesn't do the HTTP call itself
    final success = await AccountService.setPrimaryAccount(accountId);

    if (success) {
      await loadAccounts(); // refresh accounts to update the star in the UI
    }
  }

  /// Update existing account
  Future<void> updateAccount(String accountId, {String? name, String? type, String? minBalance}) async {
    try {
      await AccountService.updateAccount(
        accountId, 
        name: name, 
        type: type, 
        minBalance: minBalance
      );
      await loadAccounts(); // Refresh the dashboard after updating
    } catch (e) {
      debugPrint("Failed to update account: $e");
      rethrow; // Let the UI catch this to show an error SnackBar
    }
  }
}