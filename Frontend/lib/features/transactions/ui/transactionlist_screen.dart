// lib/features/transactions/ui/transactionlist_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:front_end/core/models/transaction_model.dart';
import 'package:front_end/core/models/account_model.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'package:front_end/core/constants/app_colors.dart';
import 'filter_screen.dart';

import 'package:front_end/core/providers/transaction_provider.dart';
import 'package:front_end/core/providers/account_provider.dart';
import '../../analytics/provider/analytics_provider.dart';
import '../../goals/provider/goal_provider.dart';

class TransactionListScreen extends StatefulWidget {
  final String? accountId;

  const TransactionListScreen({super.key, this.accountId});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String selectedType = "All Type";
  String selectedCategory = "All";
  String? selectedAccountId;
  DateTime? startDate;
  DateTime? endDate;
  String searchQuery = "";

  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _isProcessing = false;
  String? _nextCursor;
  List<TransactionModel> _transactions = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.accountId != null) {
      selectedAccountId = widget.accountId;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        if (!_isLoading && !_isFetchingMore) {
          _fetchMore();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _nextCursor = null;
      _transactions = [];
    });

    try {
      final historyData = await TransactionService.getHistory(
        accountId: selectedAccountId,
        category: selectedCategory == "All" ? null : selectedCategory,
        type: selectedType == "All Type" ? null : selectedType,
        startDate: startDate,
        endDate: endDate,
        searchQuery: searchQuery,
      );

      if (mounted) {
        setState(() {
          _transactions = historyData.transactions;

          _transactions.sort((a, b) {
            final aDay = DateTime(a.date.year, a.date.month, a.date.day);
            final bDay = DateTime(b.date.year, b.date.month, b.date.day);
            final dayComparison = bDay.compareTo(aDay);

            if (dayComparison != 0) return dayComparison;
            return b.createdAt.compareTo(a.createdAt);
          });

          _nextCursor = historyData.nextCursor;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("HISTORY FETCH ERROR: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar("Failed to load history.", isError: true);
      }
    }
  }

  Future<void> _fetchMore() async {
    if (_isFetchingMore || _nextCursor == null) return;
    setState(() => _isFetchingMore = true);

    try {
      final historyData = await TransactionService.getHistory(
        accountId: selectedAccountId,
        category: selectedCategory == "All" ? null : selectedCategory,
        type: selectedType == "All Type" ? null : selectedType,
        startDate: startDate,
        endDate: endDate,
        searchQuery: searchQuery,
        lastId: _nextCursor,
      );

      if (mounted) {
        setState(() {
          _transactions.addAll(historyData.transactions);

          _transactions.sort((a, b) {
            final aDay = DateTime(a.date.year, a.date.month, a.date.day);
            final bDay = DateTime(b.date.year, b.date.month, b.date.day);
            final dayComparison = bDay.compareTo(aDay);
            if (dayComparison != 0) return dayComparison;
            return b.createdAt.compareTo(a.createdAt);
          });

          _nextCursor = historyData.nextCursor;
          _isFetchingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isFetchingMore = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600)),
        backgroundColor:
            isError ? AppColors.expenseAmount : AppColors.incomeAmount,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }

  void _openFilters() async {
    final availableAccounts = context.read<AccountProvider>().accounts;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilterScreen(
          selectedType: selectedType,
          selectedCategory: selectedCategory,
          selectedAccountId: selectedAccountId,
          startDate: startDate,
          endDate: endDate,
          availableAccounts: availableAccounts,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedType = result["type"];
        selectedCategory = result["category"];
        selectedAccountId = result["accountId"];
        startDate = result["startDate"];
        endDate = result["endDate"];
      });
      _fetchData();
    }
  }

  Future<void> _handleReversal(TransactionModel tx) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: colorScheme.surface,
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text("Cancel Transaction?",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.primary))),
                    IconButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        icon: Icon(Icons.close_rounded,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints()),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                    "This will safely cancel the ₹${tx.amount.abs().toStringAsFixed(2)} transaction and instantly update your account balance.",
                    style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        height: 1.4,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.expenseAmount,
                        foregroundColor: AppColors.darkTextPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text("Confirm Cancel",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      setState(() => _isProcessing = true);

      final result = await TransactionService.reverseTransaction(originalTx: tx);

      if (result['success']) {
        if (!mounted) return;
        await Future.wait([
          context.read<TransactionProvider>().fetchTransactions(),
          context.read<AccountProvider>().loadAccounts(),
          context.read<GoalProvider>().fetchGoals(),
          context.read<AnalyticsProvider>().reload(),
        ]);

        await _fetchData();
        if (mounted) setState(() => _isProcessing = false);
        _showSnackBar("Transaction cancelled successfully!");
      } else {
        if (mounted) setState(() => _isProcessing = false);
        _showSnackBar("Cancellation Failed: ${result['message']}",
            isError: true);
      }
    }
  }

  Color _getTransactionColor(TransactionModel tx) {
    switch (tx.direction) {
      case "GOAL_ALLOCATION":
        return AppColors.savingsPrimary;
      case "GOAL_DEALLOCATION":
        return const Color(0xFF8B5CF6);
      case "GOAL_COMPLETION":
        return AppColors.chartIncome;
      case "ACCOUNT_TRANSFER_IN":
        return AppColors.incomeAmount;
      case "ACCOUNT_TRANSFER_OUT":
        return const Color(0xFFA78BFA);
      case "RESERVED_IN":
        return AppColors.warning;
      case "RESERVED_OUT":
        return AppColors.incomeAmount;
      case "REVERSAL":
        return AppColors.warning;
    }
    if (tx.type == "INCOME") return AppColors.incomeAmount;
    if (tx.type == "EXPENSE") return AppColors.expenseAmount;
    if (tx.type == "REVERSAL") return AppColors.warning;
    if (tx.type == "TRANSFER") return AppColors.dateLabel;
    return AppColors.expenseAmount;
  }

  IconData _getTransactionIcon(TransactionModel tx) {
    switch (tx.direction) {
      case "GOAL_ALLOCATION":
        return Icons.savings_rounded;
      case "GOAL_DEALLOCATION":
        return Icons.savings_outlined;
      case "GOAL_COMPLETION":
        return Icons.task_alt_rounded;
      case "ACCOUNT_TRANSFER_IN":
        return Icons.swap_horiz_rounded;
      case "ACCOUNT_TRANSFER_OUT":
        return Icons.swap_horiz_rounded;
      case "RESERVED_IN":
        return Icons.lock_outline_rounded;
      case "RESERVED_OUT":
        return Icons.lock_open_rounded;
      case "REVERSAL":
        return Icons.undo_rounded;
    }
    switch (tx.type) {
      case "INCOME":
        return Icons.trending_up_rounded;
      case "EXPENSE":
        return Icons.trending_down_rounded;
      case "TRANSFER":
        return Icons.swap_horiz_rounded;
      case "REVERSAL":
        return Icons.undo_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Widget _getTransactionLeading(TransactionModel tx) {
    final color = _getTransactionColor(tx);
    final icon = _getTransactionIcon(tx);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.8, end: 1),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22)),
        );
      },
    );
  }

  void _showTransactionDetails(BuildContext context, TransactionModel tx,
      ColorScheme colorScheme, ThemeData theme, bool isDark, bool canReverse) {
    final Color moneyColor = _getTransactionColor(tx);
    final textSec = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final textPrim = isDark ? Colors.white : const Color(0xFF0F172A);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8, bottom: 24),
                    decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2))),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _getTransactionLeading(tx),
                        const SizedBox(height: 16),
                        Text(
                            "₹${tx.amount.abs().toStringAsFixed(2)}",
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: tx.isCancelled ||
                                        tx.status == "VOIDED"
                                    ? textSec
                                    : moneyColor,
                                decoration: tx.status == "VOIDED"
                                    ? TextDecoration.lineThrough
                                    : null,
                                letterSpacing: -1)),
                        const SizedBox(height: 4),
                        Text(tx.title,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textPrim),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF161618)
                                  : colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.black.withOpacity(0.05))),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                  "Status",
                                  tx.isCancelled ? "Cancelled" : tx.status,
                                  isDark,
                                  valueColor:
                                      tx.isCancelled ? Colors.red : null),
                              _buildDetailRow(
                                  "Transacted At",
                                  DateFormat('dd MMM yyyy').format(tx.date),
                                  isDark),
                              _buildDetailRow(
                                  "Account", tx.accountName, isDark),
                              if (tx.linkedAccountName != null &&
                                  tx.linkedAccountName!.isNotEmpty &&
                                  tx.linkedAccountName!.toLowerCase() !=
                                      'null')
                                _buildDetailRow("Transferred To",
                                    tx.linkedAccountName!, isDark),
                              if (tx.category.isNotEmpty)
                                _buildDetailRow(
                                    "Category", tx.category, isDark),
                              if (tx.subtitle.isNotEmpty &&
                                  tx.subtitle.toLowerCase() != 'null')
                                _buildDetailRow(
                                    "Description", tx.subtitle, isDark),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                if (canReverse) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              theme.colorScheme.error.withOpacity(0.1),
                          foregroundColor: theme.colorScheme.error,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16))),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _handleReversal(tx);
                      },
                      child: const Text("Undo Transaction",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.copy_rounded,
                              size: 18, color: textPrim),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: textPrim,
                              side: BorderSide(
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.black12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          onPressed: () {
                            final String clipboardText =
                                """Transaction: ${tx.title}\nAmount: ₹${tx.amount.abs().toStringAsFixed(2)}\nTransacted At: ${DateFormat('dd MMM yyyy').format(tx.date)}\nAccount: ${tx.accountName}${tx.linkedAccountName != null && tx.linkedAccountName!.toLowerCase() != 'null' ? '\nTransferred To: ${tx.linkedAccountName}' : ''}${tx.subtitle.isNotEmpty && tx.subtitle.toLowerCase() != 'null' ? '\nDescription: ${tx.subtitle}' : ''}\nStatus: ${tx.isCancelled ? 'Cancelled' : tx.status}"""
                                    .trim();
                            Clipboard.setData(
                                ClipboardData(text: clipboardText));
                            Navigator.pop(ctx);
                            _showSnackBar("Receipt copied to clipboard!");
                          },
                          label: const Text("Copy",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? Colors.white10
                                  : Colors.grey.shade100,
                              foregroundColor: textPrim,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Close",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark,
      {Color? valueColor}) {
    final textSec = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final textPrim = isDark ? Colors.white : const Color(0xFF0F172A);
    final displayLabel =
        label.toLowerCase() == 'note' ? 'Description' : label;

    if (value.length > 35) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(displayLabel,
              style: TextStyle(
                  color: textSec,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3)),
          const SizedBox(height: 8),
          Text(value,
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: valueColor ?? textPrim,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5)),
        ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 2,
              child: Text(displayLabel,
                  style: TextStyle(
                      color: textSec,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3))),
          const SizedBox(width: 16),
          Expanded(
              flex: 3,
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: valueColor ?? textPrim,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(
      ThemeData theme, ColorScheme colorScheme, bool isDark) {
    final List<Widget> chips = [];
    final chipBgColor =
        theme.inputDecorationTheme.fillColor ?? colorScheme.surface;

    String displayAccountName = "All Accounts";
    if (selectedAccountId != null) {
      try {
        final accounts = context.read<AccountProvider>().accounts;
        displayAccountName =
            accounts.firstWhere((a) => a.id == selectedAccountId).name;
      } catch (_) {}
    }

    if (selectedType != "All Type")
      chips.add(_buildChip(
          selectedType,
          () => setState(() {
                selectedType = "All Type";
                _fetchData();
              }),
          chipBgColor,
          colorScheme.primary));
    if (selectedCategory != "All")
      chips.add(_buildChip(
          selectedCategory,
          () => setState(() {
                selectedCategory = "All";
                _fetchData();
              }),
          chipBgColor,
          colorScheme.primary));
    if (selectedAccountId != null)
      chips.add(_buildChip(
          displayAccountName,
          () {
            setState(() => selectedAccountId = null);
            _fetchData();
          },
          chipBgColor,
          colorScheme.primary));
    if (startDate != null && endDate != null)
      chips.add(_buildChip(
          "${DateFormat('MMM d').format(startDate!)} - ${DateFormat('MMM d').format(endDate!)}",
          () => setState(() {
                startDate = null;
                endDate = null;
                _fetchData();
              }),
          chipBgColor,
          colorScheme.primary));

    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, child: Row(children: chips)));
  }

  Widget _buildChip(
      String label, VoidCallback onRemove, Color bgColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
          label: Text(label, style: TextStyle(fontSize: 12, color: textColor)),
          deleteIcon: Icon(Icons.close, size: 16, color: textColor),
          onDeleted: onRemove,
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide.none)),
    );
  }

  Widget _buildTransactionTile(
      TransactionModel tx,
      ThemeData theme,
      ColorScheme colorScheme,
      Color textSec,
      bool isCash,
      {bool isLatest = false}) {
    final Color moneyColor = _getTransactionColor(tx);

    // 1. Removed tx.subtitle.length < 40 restriction
    // 2. Added null string check
    final bool hasSubtitle = tx.subtitle.isNotEmpty &&
        tx.subtitle.toLowerCase() != 'null' &&
        !tx.subtitle.toLowerCase().startsWith('to ') &&
        !tx.subtitle.toLowerCase().startsWith('from ') &&
        !tx.subtitle.toLowerCase().startsWith('transfer') &&
        !tx.subtitle.toLowerCase().startsWith('rev-') &&
        !tx.subtitle.toLowerCase().startsWith('reversing') &&
        !tx.subtitle.toLowerCase().startsWith('withdrawn');

    bool canReverse = !tx.isCancelled &&
        tx.type != "REVERSAL" &&
        tx.direction != "REVERSAL" &&
        tx.status != "VOIDED" &&
        isLatest;

    return InkWell(
      onTap: () => _showTransactionDetails(context, tx, colorScheme, theme,
          theme.brightness == Brightness.dark, canReverse),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _getTransactionLeading(tx),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.title,
                      style: TextStyle(
                          color: tx.isCancelled
                              ? textSec
                              : colorScheme.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: tx.status == "VOIDED"
                              ? TextDecoration.lineThrough
                              : null),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  DefaultTextStyle(
                    style: TextStyle(
                        color: textSec,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                    child: Row(
                      children: [
                        Icon(
                            isCash
                                ? Icons.wallet
                                : Icons.account_balance,
                            size: 11,
                            color: textSec),
                        const SizedBox(width: 4),
                        Flexible(
                            flex: 1,
                            child: Text(tx.accountName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis)),
                        if (tx.linkedAccountName != null &&
                            tx.linkedAccountName!.isNotEmpty &&
                            tx.linkedAccountName!.toLowerCase() != 'null') ...[
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded,
                              size: 10, color: textSec),
                          const SizedBox(width: 4),
                          Icon(
                              (tx.linkedAccountName!
                                          .toLowerCase()
                                          .contains('cash') ||
                                      tx.linkedAccountName!
                                          .toLowerCase()
                                          .contains('wallet'))
                                  ? Icons.wallet
                                  : Icons.account_balance,
                              size: 11,
                              color: textSec),
                          const SizedBox(width: 4),
                          Flexible(
                              flex: 1,
                              child: Text(tx.linkedAccountName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis)),
                        ],
                        
                        // 🔥 Description matching the Home Screen exactly
                        if (hasSubtitle) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.circle,
                              size: 4,
                              color: textSec.withOpacity(0.5)),
                          const SizedBox(width: 6),
                          Flexible(
                            flex: 2,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    tx.subtitle.length > 40
                                        ? '${tx.subtitle.substring(0, 40)}...'
                                        : tx.subtitle,
                                    style: TextStyle(color: textSec, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (tx.subtitle.length > 40) ...[
                                  const SizedBox(width: 2),
                                  Icon(Icons.arrow_outward_rounded, size: 14, color: textSec),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    "₹${tx.amount.abs().toStringAsFixed(2)}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: tx.isCancelled || tx.status == "VOIDED"
                            ? textSec
                            : moneyColor,
                        decoration: tx.status == "VOIDED"
                            ? TextDecoration.lineThrough
                            : null)),
                const SizedBox(height: 4),
                Text(DateFormat('dd MMM, yyyy').format(tx.date),
                    style: TextStyle(
                        color: textSec,
                        fontSize: 10,
                        fontWeight: FontWeight.w500)),
                if (tx.isCancelled) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.red.withOpacity(0.4))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.cancel_outlined,
                            size: 10, color: Colors.red),
                        const SizedBox(width: 4),
                        const Padding(
                            padding: EdgeInsets.only(bottom: 1),
                            child: Text("Cancelled",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    height: 1.0))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(ThemeData theme, ColorScheme colorScheme,
      bool isDark, Color textSec) {
    final list = _transactions;

    if (list.isEmpty && !_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Icon(Icons.receipt_long_outlined, size: 64, color: textSec),
          const SizedBox(height: 16),
          Center(
              child: Text("No transactions found",
                  style: TextStyle(
                      fontSize: 16,
                      color: textSec,
                      fontWeight: FontWeight.w500))),
        ],
      );
    }

    final latestTxId = list.isNotEmpty
        ? list
            .reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b)
            .id
        : null;

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 80),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: list.length + 1,
      itemBuilder: (context, i) {
        if (i == list.length) {
          if (_isFetchingMore)
            return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                    child: CircularProgressIndicator(
                        color: colorScheme.secondary, strokeWidth: 2)));
          return const SizedBox.shrink();
        }

        final tx = list[i];
        final isCash = tx.accountName.toLowerCase().contains('cash') ||
            tx.accountName.toLowerCase().contains('wallet');

        bool showHeader = false;
        if (i == 0) {
          showHeader = true;
        } else {
          final prevTx = list[i - 1];
          final currentDay =
              DateTime(tx.date.year, tx.date.month, tx.date.day);
          final prevDay = DateTime(
              prevTx.date.year, prevTx.date.month, prevTx.date.day);
          if (!currentDay.isAtSameMomentAs(prevDay)) showHeader = true;
        }

        Widget tileContent = Column(
          key: ValueKey(tx.id),
          children: [
            _buildTransactionTile(tx, theme, colorScheme, textSec, isCash,
                isLatest: tx.id == latestTxId),
            Divider(
                color: theme.dividerColor.withOpacity(0.05),
                height: 1,
                indent: 16,
                endIndent: 16),
          ],
        );

        if (showHeader) {
          String headerText;
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final yesterday = today.subtract(const Duration(days: 1));
          final txDate =
              DateTime(tx.date.year, tx.date.month, tx.date.day);

          if (txDate.isAtSameMomentAs(today)) {
            headerText = "Today";
          } else if (txDate.isAtSameMomentAs(yesterday)) {
            headerText = "Yesterday";
          } else if (txDate.year == now.year) {
            headerText = DateFormat('EEEE, dd MMM').format(tx.date);
          } else {
            headerText = DateFormat('dd MMM, yyyy').format(tx.date);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 28.0, bottom: 8.0, left: 16, right: 16),
                child: Row(
                  children: [
                    Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            color:
                                colorScheme.secondary.withOpacity(0.5),
                            shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Text(headerText.toUpperCase(),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: headerText == "Today"
                                ? colorScheme.secondary
                                : textSec.withOpacity(0.7))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Divider(
                            color: theme.dividerColor.withOpacity(0.05),
                            thickness: 1)),
                  ],
                ),
              ),
              tileContent,
            ],
          );
        }

        return tileContent;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final textSec =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final surfaceAlt =
        theme.inputDecorationTheme.fillColor ?? colorScheme.surface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.arrow_back_ios_new,
                                  size: 18, color: colorScheme.primary),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints()),
                          const SizedBox(width: 8),
                          Text("History",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: colorScheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                  color: surfaceAlt,
                                  borderRadius: BorderRadius.circular(12)),
                              child: TextField(
                                onChanged: (v) {
                                  setState(() => searchQuery = v);
                                  Future.delayed(
                                      const Duration(milliseconds: 500),
                                      () {
                                    if (searchQuery == v) _fetchData();
                                  });
                                },
                                style:
                                    TextStyle(color: colorScheme.primary),
                                decoration: InputDecoration(
                                    hintText: "Search transactions...",
                                    hintStyle: TextStyle(color: textSec),
                                    prefixIcon:
                                        Icon(Icons.search, color: textSec),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            vertical: 12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                              onTap: _openFilters,
                              child: Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                      color: surfaceAlt,
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  child: Icon(Icons.tune,
                                      color: colorScheme.primary))),
                        ],
                      ),
                      _buildActiveFilters(theme, colorScheme, isDark),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                              color: colorScheme.secondary))
                      : RefreshIndicator(
                          color: colorScheme.secondary,
                          backgroundColor: colorScheme.surface,
                          onRefresh: _fetchData,
                          child: _buildTransactionList(
                              theme, colorScheme, isDark, textSec),
                        ),
                ),
              ],
            ),
            if (_isProcessing)
              Container(
                  color: AppColors.darkBgPrimary.withOpacity(0.3),
                  child: Center(
                      child: CircularProgressIndicator(
                          color: colorScheme.primary))),
          ],
        ),
      ),
    );
  }
}