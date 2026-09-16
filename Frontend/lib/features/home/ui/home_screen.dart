import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:front_end/core/constants/app_colors.dart';

import 'package:front_end/features/profile/ui/profile_screen.dart';
import 'balance_card.dart';
import 'package:front_end/features/home/widget/add_transaction_screen.dart';
import 'package:front_end/features/transactions/ui/transactionlist_screen.dart';
import 'package:front_end/core/providers/transaction_provider.dart';
import 'package:front_end/core/models/transaction_model.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'package:front_end/features/transfer/transfer.dart';
import 'package:front_end/core/providers/account_provider.dart';
import '../../analytics/provider/analytics_provider.dart';
import '../../goals/provider/goal_provider.dart';
import 'package:front_end/features/notifications/notification_screen.dart';
import 'package:front_end/core/providers/notification_provider.dart';

import 'package:front_end/features/goals/ui/financial_goals_screen.dart';
import 'package:front_end/features/goals/ui/create_new_goal.dart';
import 'package:front_end/features/goals/data/goal_model.dart';
import 'package:front_end/features/goals/ui/goal_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isProcessing = false;

  List<TransactionModel> _recentTransactions = [];
  bool _isLoadingRecent = true;
  String? _recentError;

  // Cache the provider to safely remove listeners in dispose()
  late TransactionProvider _transactionProvider;

  @override
  void initState() {
    super.initState();
    _transactionProvider = context.read<TransactionProvider>();

    // Use post-frame callback for safer provider initialization
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _transactionProvider.fetchTransactions();
      _transactionProvider.addListener(_onTransactionUpdate);

      // Fetch goals for the Active Goals section
      if (mounted) context.read<GoalProvider>().fetchGoals();

      // INITIALIZE NOTIFICATIONS & SOCKET
      if (mounted) {
        final notifProvider = context.read<NotificationProvider>();
        notifProvider.loadNotifications();
        notifProvider.initializeSocketListeners();
      }
    });
    _loadRecentTransactions();
  }

  void _onTransactionUpdate() {
    if (mounted && !_isLoadingRecent) {
      _loadRecentTransactions();
    }
  }

  @override
  void dispose() {
    // Safely remove listener using the cached instance
    _transactionProvider.removeListener(_onTransactionUpdate);
    super.dispose();
  }

  Future<void> _loadRecentTransactions() async {
    setState(() {
      _isLoadingRecent = true;
      _recentError = null;
    });

    try {
      final latest = await TransactionService.getLatestTransactions();
      if (mounted) {
        setState(() {
          _recentTransactions = latest;
          _isLoadingRecent = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _recentError = e.toString().replaceAll("Exception: ", "");
          _isLoadingRecent = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(
                color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600)),
        backgroundColor:
            isError ? AppColors.expenseAmount : AppColors.incomeAmount,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(
                      color: AppColors.errorBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.error_outline_rounded,
                        color: AppColors.error, size: 36),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        height: 1.4,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Okay",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
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
                      child: Text(
                        "Cancel Transaction?",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
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
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.expenseAmount,
                      foregroundColor: AppColors.darkTextPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      "Confirm Cancel",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
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

      final result =
          await TransactionService.reverseTransaction(originalTx: tx);

      if (result['success']) {
        if (!mounted) return;
        await Future.wait([
          context.read<TransactionProvider>().fetchTransactions(),
          context.read<AccountProvider>().loadAccounts(),
          context.read<GoalProvider>().fetchGoals(),
          context.read<AnalyticsProvider>().reload(),
        ]);

        await _loadRecentTransactions();

        if (mounted) setState(() => _isProcessing = false);
        _showSnackBar("Transaction cancelled successfully!");
      } else {
        if (mounted) setState(() => _isProcessing = false);
        _showErrorDialog(
          "Cancellation Failed",
          result['message'] ??
              "An error occurred while cancelling the transaction.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  await _transactionProvider.fetchTransactions();
                  await _loadRecentTransactions();
                  if (mounted) {
                    await context
                        .read<NotificationProvider>()
                        .loadNotifications();
                  }
                  if (mounted) await context.read<GoalProvider>().fetchGoals();
                },
                color: colorScheme.secondary,
                backgroundColor: colorScheme.surface,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAppBar(context, theme, colorScheme, isDark),
                      const SizedBox(height: 4),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: BalanceCard(),
                      ),
                      const SizedBox(height: 24),

                      // QUICK ACTIONS
                      _buildActionButtons(context, colorScheme, theme, isDark),
                      const SizedBox(height: 32),

                      // ACTIVE GOALS
                      _buildActiveGoalsSection(
                          context, colorScheme, theme, isDark),
                      const SizedBox(height: 28),

                      // RECENT ACTIVITY
                      _buildRecentHeader(context, colorScheme, theme, isDark),
                      const SizedBox(height: 8),
                      _buildTransactionList(
                          context, colorScheme, theme, isDark),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
              if (_isProcessing)
                Container(
                  color: AppColors.darkBgPrimary.withOpacity(0.3),
                  child: Center(
                    child:
                        CircularProgressIndicator(color: colorScheme.primary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ACTIVE GOALS SECTION
  // ===========================================================================

  Widget _buildActiveGoalsSection(BuildContext context, ColorScheme colorScheme,
      ThemeData theme, bool isDark) {
    final goalProvider = context.watch<GoalProvider>();

    final activeGoals =
        goalProvider.goals.where((g) => g.status != 'completed').toList();

    final double responsiveHeight =
        math.max(180.0, MediaQuery.of(context).size.height * 0.22);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Active Goals",
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FinancialGoalsScreen()),
                  ).then((_) {
                    if (mounted) {
                      context.read<GoalProvider>().fetchGoals();
                    }
                  });
                },
                child: Row(
                  children: [
                    Text(
                      "View All",
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (activeGoals.isEmpty)
          _buildEmptyGoalsState(context, colorScheme, isDark)
        else
          SizedBox(
            height: responsiveHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              itemCount: activeGoals.length,
              itemBuilder: (context, index) {
                return _buildGoalCard(
                  goal: activeGoals[index],
                  isSingle: activeGoals.length == 1,
                  context: context,
                  isDark: isDark,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildGoalCard({
    required dynamic goal,
    required bool isSingle,
    required BuildContext context,
    required bool isDark,
  }) {
    // Safe math calculation to prevent DivisionByZero/NaN exceptions
    final double targetAmount =
        (goal.targetAmount != null && goal.targetAmount > 0)
            ? goal.targetAmount
            : 1.0;
    final double progress = (goal.currentAmount / targetAmount).clamp(0.0, 1.0);

    int daysRemaining = 0;
    try {
      daysRemaining = goal.daysLeft ??
          goal.targetDate?.difference(DateTime.now()).inDays ??
          0;
    } catch (_) {}

    const Color cardBgColor = Color(0xFFEFF6FF);
    const Color cardBorderColor = Color(0xFFBFDBFE);
    const Color watermarkColor = Color(0xFFDBEAFE);

    const Color accentColor = Color(0xFF3B82F6);
    const Color iconBgColor = Color(0xFFDBEAFE);
    const Color badgeTextColor = Color(0xFF1E40AF);

    final Color textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color textSecondary =
        isDark ? Colors.white70 : const Color(0xFF64748B);
    final Color textTertiary =
        isDark ? Colors.white54 : const Color(0xFF94A3B8);

    final Color finalCardBgColor =
        isDark ? const Color(0xFF1E1E2C) : cardBgColor;
    final Color finalBorderColor = isDark ? Colors.white10 : cardBorderColor;
    final Color finalWatermarkColor =
        isDark ? Colors.white.withOpacity(0.02) : watermarkColor;
    final Color finalIconBgColor =
        isDark ? accentColor.withOpacity(0.15) : iconBgColor;

    String predictionText;
    if (goal.requiredDailySaving != null && goal.requiredDailySaving! > 0) {
      predictionText = "₹${goal.requiredDailySaving!.toStringAsFixed(0)}/day";
    } else {
      predictionText = "On track";
    }

    final double cardWidth = isSingle
        ? MediaQuery.of(context).size.width - 48
        : MediaQuery.of(context).size.width * 0.85;

    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(right: isSingle ? 0 : 16, bottom: 12),
      decoration: BoxDecoration(
        color: finalCardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: finalBorderColor, width: 1.0),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: accentColor.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            final refresh = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => GoalDetailsScreen(goal: goal)));
            if (refresh == true && context.mounted) {
              context.read<GoalProvider>().fetchGoals();
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -15,
                  child: Icon(
                    Icons.radar_rounded,
                    size: 110,
                    color: finalWatermarkColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // --- TOP ROW ---
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                                color: finalIconBgColor,
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.track_changes_rounded,
                                color: accentColor, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.title,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.category_rounded,
                                        size: 12, color: textSecondary),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        goal.category,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: textSecondary,
                                            fontWeight: FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text("•",
                                        style: TextStyle(
                                            color: textTertiary, fontSize: 11)),
                                    const SizedBox(width: 4),
                                    Text(
                                      goal.targetDate != null
                                          ? DateFormat('MMM dd, yyyy')
                                              .format(goal.targetDate)
                                          : 'No Date',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: textSecondary,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // --- MIDDLE ROW ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Saved",
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: textSecondary)),
                              const SizedBox(height: 2),
                              Text(
                                "₹${goal.currentAmount.toInt()}",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: textPrimary,
                                    letterSpacing: -0.5),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Target",
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: textSecondary)),
                              const SizedBox(height: 2),
                              Text(
                                "₹${goal.targetAmount.toInt()}",
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // --- PROGRESS BAR ---
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: isDark
                                    ? Colors.white10
                                    : Colors.black.withOpacity(0.05),
                                valueColor: const AlwaysStoppedAnimation(
                                    accentColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 36,
                            child: Text(
                              "${(progress * 100).toInt()}%",
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: accentColor),
                            ),
                          ),
                        ],
                      ),
                      // --- BOTTOM ROW ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: finalIconBgColor,
                                borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              predictionText,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? accentColor : badgeTextColor),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 12, color: textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                "${daysRemaining > 0 ? daysRemaining : 0} days left",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyGoalsState(
      BuildContext context, ColorScheme colorScheme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.incomeAmount.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_graph_rounded,
                  size: 28, color: AppColors.incomeAmount),
            ),
            const SizedBox(height: 16),
            Text(
              "No active goals yet",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Start your goal planning today and track your financial progress here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CreateNewGoalScreen()),
                ).then((_) {
                  if (mounted) {
                    context.read<GoalProvider>().fetchGoals();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 0,
              ),
              child: const Text("Create a Goal",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // EXISTING UI COMPONENTS
  // ===========================================================================

  Widget _buildAppBar(BuildContext context, ThemeData theme,
      ColorScheme colorScheme, bool isDark) {
    final iconBg = isDark
        ? Colors.white.withOpacity(0.04)
        : Colors.black.withOpacity(0.03);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);
    final iconColor = isDark ? Colors.white : Colors.black87;
    final Color premiumGreen = const Color(0xFF81AF63);
    final Color premiumText = isDark ? Colors.white : const Color(0xFF0F172A);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 60,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.asset(
                  'assets/images/homeicon.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.eco_rounded,
                    color: premiumGreen,
                    size: 26,
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Green",
                      style: TextStyle(
                        color: premiumGreen,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: "Pouch",
                      style: TextStyle(
                        color: premiumText,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Consumer<NotificationProvider>(
                builder: (context, notifProvider, child) {
                  final unreadCount = notifProvider.unreadCount;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationScreen()),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: iconBg,
                            border: Border.all(color: borderColor, width: 1),
                          ),
                          child: Icon(Icons.notifications_outlined,
                              color: iconColor, size: 22),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: premiumGreen,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.scaffoldBackgroundColor,
                                  width: 2.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProfileSettingsScreen()),
                ),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconBg,
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Icon(Icons.person_outline_rounded,
                      color: iconColor, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // QUICK ACTIONS SECTION
  // ===========================================================================

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme,
      ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "QUICK ACTIONS",
            style: TextStyle(
              color: isDark ? Colors.white54 : const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.trending_up_rounded,
                  label: "Income",
                  color: AppColors.incomeAmount,
                  surfaceColor:
                      isDark ? const Color(0xFF161618) : colorScheme.surface,
                  textColor: isDark ? Colors.white : colorScheme.primary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddTransactionScreen(
                            initialIsExpense: false)),
                  ).then((result) {
                    if (!mounted) return;
                    if (result is String) {
                      _showSnackBar(result);
                    }
                    context.read<TransactionProvider>().fetchTransactions();
                    _loadRecentTransactions();
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  icon: Icons.trending_down_rounded,
                  label: "Expense",
                  color: AppColors.expenseAmount,
                  surfaceColor:
                      isDark ? const Color(0xFF161618) : colorScheme.surface,
                  textColor: isDark ? Colors.white : colorScheme.primary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const AddTransactionScreen(initialIsExpense: true)),
                  ).then((result) {
                    if (!mounted) return;
                    if (result is String) {
                      _showSnackBar(result);
                    }
                    context.read<TransactionProvider>().fetchTransactions();
                    _loadRecentTransactions();
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  icon: Icons.swap_horiz_rounded,
                  label: "Transfer",
                  color: const Color(0xFFA78BFA),
                  surfaceColor:
                      isDark ? const Color(0xFF161618) : colorScheme.surface,
                  textColor: isDark ? Colors.white : colorScheme.primary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransferScreen()),
                  ).then((_) {
                    if (!mounted) return;
                    context.read<TransactionProvider>().fetchTransactions();
                    _loadRecentTransactions();
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color surfaceColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.20), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBgPrimary.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.13),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHeader(BuildContext context, ColorScheme colorScheme,
      ThemeData theme, bool isDark) {
    final surfaceAlt =
        theme.inputDecorationTheme.fillColor ?? colorScheme.surface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Recent Activity",
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransactionListScreen()),
            ).then((_) {
              if (!mounted) return;
              context.read<TransactionProvider>().fetchTransactions();
              _loadRecentTransactions();
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: surfaceAlt,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "See all",
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, ColorScheme colorScheme,
      ThemeData theme, bool isDark) {
    final textSec = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    if (_isLoadingRecent) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: CircularProgressIndicator(
              color: colorScheme.secondary, strokeWidth: 2),
        ),
      );
    }

    if (_recentError != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            _recentError!,
            style: TextStyle(color: textSec, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_recentTransactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, color: textSec, size: 40),
              const SizedBox(height: 12),
              Text(
                "No recent transactions",
                style: TextStyle(color: textSec, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      itemCount: _recentTransactions.length,
      itemBuilder: (context, index) {
        bool isLatest = index == 0;
        return _buildTile(
            context, _recentTransactions[index], colorScheme, theme, isDark,
            isLatest: isLatest);
      },
    );
  }
Widget _buildTile(BuildContext context, TransactionModel tx,
      ColorScheme colorScheme, ThemeData theme, bool isDark,
      {bool isLatest = false}) {
    final Color moneyColor = _getTransactionColor(tx);
    final bool isCash = tx.accountName.toLowerCase().contains('cash') ||
        tx.accountName.toLowerCase().contains('wallet');
    final textSec = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    bool canReverse = !tx.isCancelled &&
        tx.type != "REVERSAL" &&
        tx.direction != "REVERSAL" &&
        tx.status != "VOIDED" &&
        isLatest;

    return InkWell(
      onTap: () => _showTransactionDetails(
          context, tx, colorScheme, theme, isDark, canReverse),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _getTransactionLeading(tx),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        style: TextStyle(
                          color: tx.isCancelled ? textSec : colorScheme.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: tx.status == "VOIDED"
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(isCash ? Icons.wallet : Icons.account_balance,
                              size: 11, color: textSec),
                          const SizedBox(width: 4),
                          Text(
                            tx.accountName,
                            style: TextStyle(
                                color: textSec,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
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
                              child: Text(
                                tx.linkedAccountName!,
                                style: TextStyle(
                                    color: textSec,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          
                          // 🔥 UPDATED: Description on the same line with 45 char limit and proper icon placement
                          if (tx.subtitle.isNotEmpty &&
                              tx.subtitle.toLowerCase() != 'null') ...[
                            const SizedBox(width: 6),
                            Icon(Icons.circle, size: 4, color: textSec),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      // Strictly cuts at 40 characters and adds "..."
                                      tx.subtitle.length > 40
                                          ? '${tx.subtitle.substring(0, 40)}...'
                                          : tx.subtitle,
                                      style: TextStyle(
                                          color: textSec, fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Shows the extra icon ONLY if the text was cut
                                  if (tx.subtitle.length > 40) ...[
                                    const SizedBox(width: 2),
                                    Icon(Icons.arrow_outward_rounded,
                                        size: 14, color: textSec),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
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
                        color: tx.isCancelled || tx.status == "VOIDED"
                            ? textSec
                            : moneyColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        decoration: tx.status == "VOIDED"
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM, yyyy').format(tx.date),
                      style: TextStyle(
                          color: textSec,
                          fontSize: 10,
                          fontWeight: FontWeight.w500),
                    ),
                    if (tx.isCancelled) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.cancel_outlined,
                                size: 10, color: Colors.red),
                            const SizedBox(width: 4),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 1),
                              child: Text(
                                "Cancelled",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Divider(color: theme.dividerColor, height: 1),
        ],
      ),
    );
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
      case "ACCOUNT_TRANSFER_OUT":
      case "ACCOUNT_TRANSFER_IN":
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
    final Color iconColor = _getTransactionColor(tx);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12), shape: BoxShape.circle),
      child: Icon(_getTransactionIcon(tx), color: iconColor, size: 20),
    );
  }

  // ===========================================================================
  // TRANSACTION DETAILS MODAL
  // ===========================================================================

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
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
                            color: tx.isCancelled || tx.status == "VOIDED"
                                ? textSec
                                : moneyColor,
                            decoration: tx.status == "VOIDED"
                                ? TextDecoration.lineThrough
                                : null,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tx.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textPrim,
                          ),
                          textAlign: TextAlign.center,
                        ),
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
                                  : Colors.black.withOpacity(0.05),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                  "Status",
                                  tx.isCancelled ? "Cancelled" : tx.status,
                                  isDark,
                                  valueColor:
                                      tx.isCancelled ? Colors.red : null),
                              _buildDetailRow(
                                  "Date",
                                  DateFormat('dd MMM yyyy').format(tx.date),
                                  isDark),
                              _buildDetailRow(
                                  "Account", tx.accountName, isDark),
                              if (tx.linkedAccountName != null &&
                                  tx.linkedAccountName!.isNotEmpty &&
                                  tx.linkedAccountName!.toLowerCase() != 'null')
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
                            borderRadius: BorderRadius.circular(16)),
                      ),
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
                              color: isDark ? Colors.white24 : Colors.black12,
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            final String clipboardText = """
Transaction: ${tx.title}
Amount: ₹${tx.amount.abs().toStringAsFixed(2)}
Transacted At: ${DateFormat('dd MMM yyyy').format(tx.date)}
Account: ${tx.accountName}${tx.linkedAccountName != null && tx.linkedAccountName!.toLowerCase() != 'null' ? '\nTransferred To: ${tx.linkedAccountName}' : ''}${tx.subtitle.isNotEmpty && tx.subtitle.toLowerCase() != 'null' ? '\nDescription: ${tx.subtitle}' : ''}
Status: ${tx.isCancelled ? 'Cancelled' : tx.status}
"""
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
                            backgroundColor:
                                isDark ? Colors.white10 : Colors.grey.shade100,
                            foregroundColor: textPrim,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
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

    final displayLabel = label.toLowerCase() == 'note' ? 'Description' : label;

    if (value.length > 35) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayLabel,
              style: TextStyle(
                color: textSec,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: valueColor ?? textPrim,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
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
            child: Text(
              displayLabel,
              style: TextStyle(
                color: textSec,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? textPrim,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}