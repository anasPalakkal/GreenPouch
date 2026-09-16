import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/account_model.dart';
import '../services/account_service.dart';
import '../services/transfer_service.dart';
import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';

class TransferProvider extends ChangeNotifier {
  List<AccountModel> accounts = [];

  AccountModel? fromAccount;
  AccountModel? toAccount;

  bool loading = false;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String idempotencyKey = const Uuid().v4();

  /// Load Accounts
  Future<void> loadAccounts() async {
    try {
      final result = await AccountService.getAccountDashboard();
      accounts = result['accounts'] as List<AccountModel>;

      // Clear selections — old references are now stale
      fromAccount = null;
      toAccount = null;

      notifyListeners();
    } catch (e) {
      debugPrint("Load accounts failed: $e");
    }
  }

  /// Select From Account — clears toAccount if same
  void setFromAccount(AccountModel account) {
    fromAccount = account;

    // ✅ clear toAccount if it matches the new fromAccount
    if (toAccount?.id == account.id) {
      toAccount = null;
    }

    notifyListeners();
  }

  /// Select To Account
  void setToAccount(AccountModel account) {
    toAccount = account;
    notifyListeners();
  }

  /// Submit Transfer
  Future<String?> submitTransfer(BuildContext context) async {
    final amount = double.tryParse(amountController.text.trim());

    if (fromAccount == null || toAccount == null) {
      return "Please select both accounts";
    }

    if (amount == null || amount <= 0) {
      return "Enter a valid amount";
    }

    if (fromAccount!.id == toAccount!.id) {
      return "Accounts cannot be the same";
    }

    loading = true;
    notifyListeners();

    try {
      await TransferService.accountTransfer(
        fromAccountId: fromAccount!.id,
        toAccountId: toAccount!.id,
        amount: amount,
        category: "TRANSFER",
        description: descriptionController.text.trim(),
        idempotencyKey: idempotencyKey,
      );

      /// Refresh Dashboard + History
      await Future.wait([
        context.read<AccountProvider>().loadAccounts(),
        context.read<TransactionProvider>().fetchTransactions(),
      ]);

      /// Reset form
      amountController.clear();
      descriptionController.clear();
      fromAccount = null;
      toAccount = null;
      idempotencyKey = const Uuid().v4();
      loading = false;
      notifyListeners();

      return null;
    } catch (e) {
      loading = false;
      notifyListeners();

      return "Transfer failed: $e";
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}