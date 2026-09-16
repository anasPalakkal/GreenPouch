import 'package:flutter/material.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'package:front_end/core/models/transaction_model.dart';
class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _isFetchingMore = false; // Separate state for pagination
  String? _errorMessage;
  String? _nextCursor; // 🎯 TRACK THE CURSOR

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  String? get error => _errorMessage;
  bool get hasMore => _nextCursor != null;

  /// Initial Fetch (or Pull-to-Refresh)
  Future<void> fetchTransactions({bool isRefresh = false}) async {
    if (isRefresh) {
      _nextCursor = null; // Reset pagination on refresh
    }

    try {
      if (_transactions.isEmpty || isRefresh) {
        _isLoading = true;
      } else {
        _isFetchingMore = true;
      }
      notifyListeners();

      final response = await TransactionService.getHistory();

      if (isRefresh) {
        _transactions = response.transactions;
      } else {
        _transactions.addAll(response.transactions); // 🎯 APPEND, DON'T OVERWRITE
      }

      _nextCursor = response.nextCursor;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Connection error. Please try again.";
    } finally {
      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  /// 🎯 OPTIMISTIC UI: Add transaction locally immediately
  void addTransactionLocally(TransactionModel newTx) {
    _transactions.insert(0, newTx);
    notifyListeners();
  }
}