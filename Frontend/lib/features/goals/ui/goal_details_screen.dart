import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../data/goal_model.dart';
import '../services/goal_service.dart';
import 'package:front_end/core/services/api_config.dart';
import 'package:front_end/core/providers/account_provider.dart';
import 'package:provider/provider.dart';
import 'package:front_end/core/providers/transaction_provider.dart';
import '../provider/goal_provider.dart';
import '../../analytics/provider/analytics_provider.dart';
import 'package:front_end/core/constants/app_colors.dart';
import 'package:front_end/core/services/sound_service.dart';

class GoalDetailsScreen extends StatefulWidget {
  final GoalModel goal;
  const GoalDetailsScreen({super.key, required this.goal});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  late final GoalService _goalService =
      GoalService(baseUrl: "${ApiConfig.baseUrl}/api");

  bool _isLoading = false;
  late double _currentAmount;
  List<dynamic> _history = [];
  bool _isLoadingHistory = true;

  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _currentAmount = widget.goal.currentAmount;
    _amountController = TextEditingController();
    _loadHistory();
    // Pre-load accounts for the transaction dropdown
    Future.microtask(() {
      context.read<AccountProvider>().loadAccounts();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GoalDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.goal.currentAmount != widget.goal.currentAmount || 
        oldWidget.goal.status != widget.goal.status) {
      _currentAmount = widget.goal.currentAmount;
    }
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final history = await _goalService.getGoalHistory(widget.goal.id);
      if (mounted) setState(() => _history = history);
    } catch (e) {
      debugPrint("History load error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  void _refreshProviders() {
    if (!mounted) return;
    Future.wait([
      context.read<AccountProvider>().loadAccounts(),
      context.read<TransactionProvider>().fetchTransactions(),
      context.read<GoalProvider>().fetchGoals(),
      context.read<AnalyticsProvider>().reload(),
    ]);
  }

  void _showTransactionBottomSheet(BuildContext context, bool isDeposit) {
    _amountController.clear();
    String? selectedAccountId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer<AccountProvider>(
          builder: (context, accountProvider, child) {
            final accounts = accountProvider.accounts;
            
            // STABILITY FIX 1: Ensure selectedAccountId is always valid.
            if (selectedAccountId == null && accounts.isNotEmpty) {
              selectedAccountId = accounts.first.id;
            } else if (selectedAccountId != null && !accounts.any((a) => a.id == selectedAccountId)) {
              selectedAccountId = accounts.isNotEmpty ? accounts.first.id : null;
            }

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateSheet) {
                final isDark = Theme.of(ctx).brightness == Brightness.dark;
                final sheetBg = isDark ? AppColors.darkBgCard : AppColors.lightBgPrimary;
                final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
                final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
                final inputFill = isDark ? AppColors.darkBgElevated : AppColors.lightBgSecondary;
                final inputBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
                final handleColor = isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated;
                final depositColor = AppColors.savingsPrimary;
                final withdrawColor = AppColors.expenseAmount;

                return Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
                  child: Container(
                    decoration: BoxDecoration(
                      color: sheetBg,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(color: handleColor, borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        Text(
                          isDeposit ? "Deposit Funds" : "Withdraw Funds",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isDeposit ? "Move money into this goal envelope." : "Return money to an account.",
                          style: TextStyle(color: textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        
                        Text(
                          isDeposit ? "From Account" : "To Account",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textSecondary),
                        ),
                        const SizedBox(height: 8),
                        
                        accounts.isEmpty 
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Loading accounts...", style: TextStyle(color: Colors.grey)),
                            )
                          : DropdownButtonFormField<String>(
                              value: selectedAccountId,
                              dropdownColor: sheetBg,
                              isExpanded: true, // STABILITY FIX 2: Prevents text overflow crashes
                              borderRadius: BorderRadius.circular(16),
                              icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary),
                              decoration: InputDecoration(
                                filled: true, fillColor: inputFill,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: inputBorder)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: inputBorder)),
                              ),
                              items: accounts.map((acc) {
                                return DropdownMenuItem(
                                  value: acc.id,
                                  child: Row(
                                    children: [
                                      // UI FIX: Added Icon for accounts
                                      Icon(
                                        Icons.account_balance_wallet_outlined, 
                                        color: textSecondary, 
                                        size: 20
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          acc.name, 
                                          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) => setStateSheet(() => selectedAccountId = val),
                            ),

                        const SizedBox(height: 20),
                        Text("Amount", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textSecondary)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _amountController,
                          autofocus: true,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
                          decoration: InputDecoration(
                            prefixText: "₹ ",
                            prefixStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textSecondary),
                            hintText: "0.00", hintStyle: TextStyle(color: textSecondary),
                            filled: true, fillColor: inputFill,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: inputBorder)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: inputBorder)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: isDeposit ? depositColor : withdrawColor, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity, height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDeposit ? depositColor : withdrawColor,
                              foregroundColor: AppColors.darkTextPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0,
                            ),
                            onPressed: () {
                              final amount = double.tryParse(_amountController.text) ?? 0;
                              if (amount <= 0 || selectedAccountId == null) {
                                _showSnackBar("Please select an account and enter a valid amount", isError: true);
                                return;
                              }
                              Navigator.pop(ctx);

                              if (isDeposit) {
                                _performDeposit(amount, selectedAccountId!);
                              } else {
                                _performWithdraw(amount, selectedAccountId!);
                              }
                            },
                            child: Text(
                              isDeposit ? "Confirm Deposit" : "Confirm Withdrawal",
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            );
          }
        );
      },
    );
  }

  Future<void> _performDeposit(double amount, String accountId) async {
    setState(() => _isLoading = true);
    final nowUtc = DateTime.now().toUtc().toIso8601String();
    final idempotencyKey = const Uuid().v4();

    try {
      final result = await _goalService.depositToGoal(
        widget.goal.id,
        accountId,
        amount,
        idempotencyKey,
        transactedAt: nowUtc,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        await SoundService.instance.playTransaction(TransactionSound.goalDeposit);
        setState(() => _currentAmount += amount); 
        _refreshProviders();
        await _loadHistory();
        _showSnackBar("Funds deposited successfully!");
      } else {
        _showSnackBar(result['message'] ?? 'Deposit failed', isError: true);
      }
    } catch (e) {
      if (mounted) _showSnackBar("Error: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _performWithdraw(double amount, String accountId) async {
    setState(() => _isLoading = true);
    final nowUtc = DateTime.now().toUtc().toIso8601String();
    final idempotencyKey = const Uuid().v4();

    try {
      final result = await _goalService.withdrawFromGoal(
        widget.goal.id,
        accountId,
        amount,
        idempotencyKey,
        transactedAt: nowUtc,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        await SoundService.instance.playTransaction(TransactionSound.goalWithdraw);
        setState(() => _currentAmount -= amount);
        _refreshProviders();
        await _loadHistory();
        _showSnackBar("Withdrawal successful!");
      } else {
        _showSnackBar(result['message'] ?? 'Withdrawal failed', isError: true);
      }
    } catch (e) {
      if (mounted) _showSnackBar("Error: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final scaffoldBg = isDark ? AppColors.darkBgPrimary : const Color(0xFFF4F5F7);
    final appBarBg = isDark ? AppColors.darkBgPrimary : const Color(0xFFF4F5F7);
    final appBarTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: appBarTextColor, size: 18),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text("Goal Details",
            style: TextStyle(
                color: appBarTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildSummaryCard(isDark)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: "Deposit",
                          icon: Icons.add_rounded,
                          color: AppColors.savingsPrimary,
                          onTap: () => _showTransactionBottomSheet(context, true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          label: "Withdraw",
                          icon: Icons.remove_rounded,
                          color: AppColors.expenseAmount,
                          outlined: true,
                          disabled: _currentAmount <= 0,
                          onTap: () => _showTransactionBottomSheet(context, false),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text("History",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary)),
                ),
              ),
              SliverToBoxAdapter(child: _buildHistoryList(isDark)),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
          if (_isLoading)
            Container(
              color: isDark
                  ? AppColors.darkBgPrimary.withOpacity(0.6)
                  : AppColors.lightBgPrimary.withOpacity(0.6),
              child: Center(
                  child: CircularProgressIndicator(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary)),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    // ─── 1. State Calculations ────────────────────────────────────────────────
    final bool isCompleted = _currentAmount >= widget.goal.targetAmount;
    final bool isOverflow = _currentAmount > widget.goal.targetAmount;
    
    final double rawProgress = _currentAmount / widget.goal.targetAmount;
    final double safeProgress = rawProgress.clamp(0.0, 1.0); // Caps progress bar at 100%
    
    final double overflowAmount = _currentAmount - widget.goal.targetAmount;
    final double remaining = (widget.goal.targetAmount - _currentAmount).clamp(0.0, widget.goal.targetAmount);
    
    final int daysLeft = widget.goal.daysLeft ?? widget.goal.targetDate.difference(DateTime.now()).inDays;
    final int daysSinceCreated = DateTime.now().difference(widget.goal.createdAt).inDays;

    // ─── 2. Dynamic Colors (Active = Blue, Completed = Green) ────────────────
    final Color statusColor = isCompleted ? AppColors.success : Colors.blue;
    final Color cardBg = isDark ? statusColor.withOpacity(0.08) : statusColor.withOpacity(0.05);
    final Color cardBorder = statusColor.withOpacity(0.3);
    
    final Color textPrimary = isDark ? Colors.white : Colors.black87;
    final Color textSecondary = isDark ? Colors.white70 : Colors.black54;
    final Color textMuted = isDark ? Colors.white54 : Colors.black38;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.track_changes, size: 16, color: statusColor),
                  const SizedBox(width: 6),
                  Text(
                    widget.goal.category.toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.success.withOpacity(0.15) : Colors.blue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                    isCompleted
                        ? "Completed in ${daysSinceCreated <= 0 ? 1 : daysSinceCreated} days"
                        : "${daysLeft > 0 ? daysLeft : 0} days left",
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.goal.title,
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          
          if (!isCompleted &&
              widget.goal.requiredDailySaving != null &&
              widget.goal.requiredDailySaving! > 0) ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.dailySavingBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "DAILY SAVING NEEDED",
                          style: TextStyle(
                            color: AppColors.dailySavingText,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${(widget.goal.requiredDailySaving ?? 0).toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: AppColors.dailySavingText,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "per day to reach on time",
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ] else ...[
            const SizedBox(height: 24),
          ],
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "₹${NumberFormat('#,##,###').format(_currentAmount.toInt())}",
                style: TextStyle(
                    color: statusColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5),
              ),
              const SizedBox(width: 6),
              Text(
                "/ ₹${NumberFormat('#,##,###').format(widget.goal.targetAmount.toInt())}",
                style: TextStyle(
                    color: textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: safeProgress,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? statusColor.withOpacity(0.15)
                        : statusColor.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(statusColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${(safeProgress * 100).toInt()}%", // Safe bounded percentage
                style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
          
          if (!isCompleted) ...[
            const SizedBox(height: 12),
            Text(
              "₹${NumberFormat('#,##,###').format(remaining.toInt())} left to reach your goal",
              style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ] else ...[
            const SizedBox(height: 16),
            _buildPremiumAchievementCard(isOverflow, overflowAmount, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildPremiumAchievementCard(bool isOverflow, double overflowAmount, bool isDark) {
    // Use a premium Gold for overfunding, and your standard Success Green for reaching it exactly
    final Color highlightColor = isOverflow ? const Color(0xFFFFD700) : AppColors.success;
    
    // Create a subtle glowing background
    final Color bgColor = isDark 
        ? highlightColor.withOpacity(0.1) 
        : highlightColor.withOpacity(0.08);
    final Color borderColor = highlightColor.withOpacity(0.4);
    final Color iconBgColor = highlightColor.withOpacity(0.2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: highlightColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOverflow 
                  ? Icons.workspace_premium_rounded // Premium badge icon
                  : Icons.task_alt_rounded,         // Clean success checkmark
              color: highlightColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOverflow ? "TARGET EXCEEDED" : "GOAL COMPLETED",
                  style: TextStyle(
                    color: highlightColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOverflow 
                      ? "You saved an extra ₹${NumberFormat('#,##,###').format(overflowAmount.toInt())}!"
                      : "You've successfully reached your target!",
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(bool isDark) {
    final cardBg = isDark ? AppColors.darkBgCard : AppColors.lightBgPrimary;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final iconBg = isDark ? AppColors.darkBgElevated : AppColors.lightBgSecondary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    if (_isLoadingHistory) {
      return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()));
    }
    if (_history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text("No transactions yet",
              style: TextStyle(
                  color: textMuted, fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final direction = (item['direction'] ?? '').toString();
        final description = (item['description'] ?? '').toString();
        final amount = item['amount']?.toString() ?? '0';
        final rawDate = item['transactedAt'] ?? item['createdAt'];

        DateTime date = DateTime.now();
        if (rawDate != null) {
          try {
            date = DateTime.parse(rawDate.toString()).toLocal();
          } catch (_) {}
        }

        final isAllocation = direction == 'GOAL_ALLOCATION';
        final isCompletion = direction == 'GOAL_COMPLETION';
        final isDeallocation = direction == 'GOAL_DEALLOCATION';

        final Color dotColor = isAllocation || isCompletion
            ? AppColors.expenseAmount
            : AppColors.success;
        final IconData dotIcon =
            isAllocation || isCompletion ? Icons.add : Icons.remove;

        String label;
        if (isAllocation) {
          label = "Deposit";
        } else if (isCompletion) {
          label = "Goal Spent";
        } else if (isDeallocation) {
          label = description.contains('released') ? "Goal Released" : "Withdrawal";
        } else {
          label = direction;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
          ),
         child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(dotIcon, color: dotColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM dd, yyyy • h:mm a').format(date),
                      style: TextStyle(
                          color: textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              // --- Right Side: Amount and Account Name ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${isAllocation || isCompletion ? '+' : '-'}₹$amount",
                    style: TextStyle(
                        fontSize: 15, 
                        fontWeight: FontWeight.w800, 
                        color: dotColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['accountName'] ?? 'General Wallet', // Shows account name
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: textMuted),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final bool disabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.outlined = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 46,
      child: outlined
          ? OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: disabled
                        ? (isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder)
                        : color,
                    width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                foregroundColor: disabled
                    ? (isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted)
                    : color,
              ),
              icon: Icon(icon, size: 18),
              label: Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              onPressed: disabled ? null : onTap,
            )
          : ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: disabled
                    ? (isDark
                        ? AppColors.darkBgElevated
                        : AppColors.lightBgSecondary)
                    : color,
                foregroundColor: disabled
                    ? (isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted)
                    : AppColors.darkTextPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: Icon(icon, size: 18),
              label: Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              onPressed: disabled ? null : onTap,
            ),
    );
  }
}