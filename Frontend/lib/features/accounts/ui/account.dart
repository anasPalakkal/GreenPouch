import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/account_model.dart';
import '../../../core/services/account_service.dart';
import '../../../core/providers/account_provider.dart';
import '../../../core/constants/app_colors.dart';

import 'package:front_end/navigation/navigation_service.dart';
import 'package:front_end/features/transactions/ui/transactionlist_screen.dart';
import 'package:front_end/features/transactions/ui/reserve_funds_screen.dart';

// ✅ Import the two new dedicated screens
import 'create_account_screen.dart';
import 'edit_account_screen.dart';

class AccountsOverviewScreen extends StatefulWidget {
  const AccountsOverviewScreen({super.key});

  @override
  State<AccountsOverviewScreen> createState() => _AccountsOverviewScreenState();
}

class _AccountsOverviewScreenState extends State<AccountsOverviewScreen>
    with SingleTickerProviderStateMixin {
  String _activeFilter = "ALL";

  // --- PREMIUM RADIAL FAB ANIMATION CONTROLLERS ---
  late AnimationController _fabController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;
  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));

    _expandAnimation =
        CurvedAnimation(parent: _fabController, curve: Curves.easeOutBack);
    _fadeAnimation =
        CurvedAnimation(parent: _fabController, curve: Curves.easeOut);
    _rotationAnimation =
        CurvedAnimation(parent: _fabController, curve: Curves.easeOutBack);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AccountProvider>().loadAccounts();
      }
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  Future<void> _handleSetPrimary(String accountId) async {
    await context.read<AccountProvider>().setPrimary(accountId);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!context.mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: TextStyle(
                color: theme.colorScheme.surface,
                fontWeight: FontWeight.w600)),
        backgroundColor:
            isError ? AppColors.expenseAmount : AppColors.incomeAmount,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // --- NAVIGATE TO CREATE ACCOUNT SCREEN ---
  void _navigateToCreateAccount({String initialType = "CASH"}) {
    if (_isFabOpen) _toggleFab();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateAccountScreen(initialType: initialType),
      ),
    ).then((created) {
      // Refresh list if account was created
      if (created == true && mounted) {
        context.read<AccountProvider>().loadAccounts();
      }
    });
  }

  // --- NAVIGATE TO EDIT ACCOUNT SCREEN ---
  void _navigateToEditAccount(AccountModel acc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAccountScreen(account: acc),
      ),
    ).then((updated) {
      // Refresh list if account was updated
      if (updated == true && mounted) {
        context.read<AccountProvider>().loadAccounts();
      }
    });
  }

  // --- PREMIUM DELETE FLOW ---
  Future<void> _handleDeleteAccount(AccountModel acc) async {
    final double totalBalance = double.tryParse(acc.totalBalance) ?? 0.0;

    if (totalBalance > 0) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (ctx) {
          final theme = Theme.of(ctx);
          final colorScheme = theme.colorScheme;
          final isDark = theme.brightness == Brightness.dark;

          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
              backgroundColor: colorScheme.surface,
              elevation: 24,
              shadowColor: Colors.black45,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
                            width: 2),
                      ),
                      child: const Icon(Icons.lock_rounded,
                          color: AppColors.warning, size: 40),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Funds Remaining",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "This account still holds ₹$totalBalance.\n\nPlease transfer or withdraw all your funds before closing it.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          height: 1.5,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Got it",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32)),
            backgroundColor: colorScheme.surface,
            elevation: 24,
            shadowColor: Colors.black45,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorBg.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.error, size: 28),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        icon: Icon(Icons.close_rounded,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted),
                        style: IconButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.darkBgSecondary
                                : AppColors.lightBgSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text("Delete Account?",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.onSurface)),
                  const SizedBox(height: 12),
                  Text(
                    "Are you sure you want to permanently close '${acc.name}'? This action cannot be undone.",
                    style: TextStyle(
                        fontSize: 15,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        height: 1.5,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              foregroundColor: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text("Cancel",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              shadowColor:
                                  AppColors.error.withValues(alpha: 0.5),
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text("Delete",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      try {
        final result = await AccountService.deleteAccount(acc.id);
        if (!context.mounted) return;
        if (result['success'] == true) {
          _showSnackBar("Account successfully closed.");
          context.read<AccountProvider>().loadAccounts();
        } else {
          _showSnackBar(result['message'] ?? "Failed to delete account.",
              isError: true);
        }
      } catch (e) {
        if (context.mounted) {
          _showSnackBar("Connection error. Could not delete account.",
              isError: true);
        }
      }
    }
  }

  // --- SMART RESERVE MANAGER ---
  void _handleManageReservesFabAction() {
    _toggleFab();
    final provider = context.read<AccountProvider>();
    final allAccounts = [...provider.cashAccounts, ...provider.bankAccounts];

    if (allAccounts.isEmpty) {
      _showSnackBar("You don't have any accounts yet.", isError: true);
      return;
    }

    if (allAccounts.length == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReserveFundsScreen(
            accountId: allAccounts.first.id,
            accountName: allAccounts.first.name,
          ),
        ),
      );
    } else {
      _showAccountSelectionSheet(allAccounts);
    }
  }

  void _showAccountSelectionSheet(List<AccountModel> accounts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        final textSec =
            isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              24,
              20,
              MediaQuery.of(ctx).padding.bottom + 32,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                          color: textSec.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Select Account",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Which account's reserves do you want to manage?",
                    style: TextStyle(
                        fontSize: 14,
                        color: textSec,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  ...accounts.map((acc) {
                    final baseColor = acc.type == "CASH"
                        ? AppColors.incomeAmount
                        : AppColors.savingsPrimary;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                              color: baseColor.withValues(alpha: 0.2),
                              width: 1.5),
                        ),
                        tileColor: baseColor.withValues(alpha: 0.05),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: baseColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                              acc.type == 'CASH'
                                  ? Icons.wallet_rounded
                                  : Icons.account_balance_rounded,
                              color: baseColor,
                              size: 20),
                        ),
                        title: Text(acc.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Available: ₹${acc.availableBalance}",
                            style: TextStyle(
                                color: textSec,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        trailing: Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: textSec),
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReserveFundsScreen(
                                accountId: acc.id,
                                accountName: acc.name,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconFabOption({
    required IconData icon,
    required Color bgColor,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Tooltip(
        message: tooltip,
        preferBelow: false,
        verticalOffset: 30,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: bgColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: bgColor.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              child: Icon(icon, color: bgColor, size: 28),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<AccountProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text("My Assets",
            style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface, size: 20),
          onPressed: () => NavigationService.bottomIndex.value = 0,
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: provider.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                        color: colorScheme.primary))
                : RefreshIndicator(
                    onRefresh: () async => provider.loadAccounts(),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      padding: const EdgeInsets.only(bottom: 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPremiumNetWorthCard(provider, isDark),
                          _buildActionHub(colorScheme, isDark),
                          const SizedBox(height: 8),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_activeFilter == "ALL" ||
                                    _activeFilter == "CASH") ...[
                                  _buildSectionHeader(
                                      "CASH WALLETS", isDark),
                                  ...provider.cashAccounts.map((acc) =>
                                      _buildSleekDataCard(
                                          acc, theme, colorScheme, isDark)),
                                  const SizedBox(height: 20),
                                ],
                                if (_activeFilter == "ALL" ||
                                    _activeFilter == "BANK") ...[
                                  _buildSectionHeader(
                                      "BANK ACCOUNTS", isDark),
                                  ...provider.bankAccounts.map((acc) =>
                                      _buildSleekDataCard(
                                          acc, theme, colorScheme, isDark)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // --- INVISIBLE OVERLAY ---
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_isFabOpen,
              child: GestureDetector(
                onTap: _toggleFab,
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // RADIAL OPTION 2: Manage Reserves
          AnimatedBuilder(
            animation: _fabController,
            builder: (context, child) {
              return Positioned(
                right: 22 + (65 * _expandAnimation.value),
                bottom: 26 + (75 * _expandAnimation.value),
                child: IgnorePointer(
                  ignoring: !_isFabOpen,
                  child: Transform.scale(
                    scale: _expandAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                      child: _buildIconFabOption(
                        icon: Icons.lock_clock_rounded,
                        bgColor: AppColors.warning,
                        tooltip: "Manage Reserves",
                        onTap: _handleManageReservesFabAction,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // RADIAL OPTION 1: Add Account → navigates to CreateAccountScreen
          AnimatedBuilder(
            animation: _fabController,
            builder: (context, child) {
              return Positioned(
                right: 22,
                bottom: 26 + (95 * _expandAnimation.value),
                child: IgnorePointer(
                  ignoring: !_isFabOpen,
                  child: Transform.scale(
                    scale: _expandAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                      child: _buildIconFabOption(
                        icon: Icons.add_card_rounded,
                        bgColor: AppColors.incomeAmount,
                        tooltip: "Add Account",
                        onTap: () => _navigateToCreateAccount(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // MAIN FAB TRIGGER
          Positioned(
            right: 20,
            bottom: 24,
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 3.14159 * 2,
                  child: FloatingActionButton(
                    onPressed: _toggleFab,
                    backgroundColor: isDark
                        ? const Color(0xFF2A2D3E)
                        : colorScheme.primary,
                    foregroundColor:
                        isDark ? Colors.white : colorScheme.onPrimary,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.add_rounded, size: 30),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionHub(ColorScheme colorScheme, bool isDark) {
    const double uniformHeight = 42.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          Expanded(
              child: _buildFilterChip(
                  "ALL", Icons.apps_rounded, colorScheme, isDark, uniformHeight)),
          const SizedBox(width: 8),
          Expanded(
              child: _buildFilterChip("CASH", Icons.wallet_rounded, colorScheme,
                  isDark, uniformHeight)),
          const SizedBox(width: 8),
          Expanded(
              child: _buildFilterChip("BANK",
                  Icons.account_balance_rounded, colorScheme, isDark, uniformHeight)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, ColorScheme colorScheme,
      bool isDark, double height) {
    bool isSel = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSel
              ? colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSel
                ? colorScheme.primary
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 14,
                color: isSel
                    ? colorScheme.primary
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(label,
                  style: TextStyle(
                      color: isSel
                          ? colorScheme.primary
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                      fontWeight:
                          isSel ? FontWeight.bold : FontWeight.w600,
                      fontSize: 11),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleekDataCard(AccountModel acc, ThemeData theme,
      ColorScheme colorScheme, bool isDark) {
    final textSec =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final baseColor =
        acc.type == "CASH" ? AppColors.incomeAmount : AppColors.savingsPrimary;
    final double minBalDouble = double.tryParse(acc.minBalance) ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? baseColor.withValues(alpha: 0.06)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark
                ? baseColor.withValues(alpha: 0.15)
                : baseColor.withValues(alpha: 0.1),
            width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: baseColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(
                    acc.type == "CASH"
                        ? Icons.wallet_rounded
                        : Icons.account_balance_rounded,
                    color: baseColor,
                    size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                          child: Text(acc.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: colorScheme.onSurface),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                      if (acc.isDefault) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.verified_rounded,
                            color: baseColor, size: 16)
                      ],
                    ]),
                    const SizedBox(height: 4),
                    Text("Available: ₹${acc.availableBalance}",
                        style: TextStyle(
                            fontSize: 13,
                            color: textSec,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              if (minBalDouble > 0) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_active_rounded,
                          size: 12, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text("₹${acc.minBalance}",
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              PopupMenuButton<String>(
                icon:
                    Icon(Icons.more_horiz_rounded, color: textSec, size: 22),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                onSelected: (val) {
                  if (val == 'primary') _handleSetPrimary(acc.id);
                  if (val == 'history') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                TransactionListScreen(accountId: acc.id)));
                  }
                  // ✅ Navigate to EditAccountScreen instead of bottom sheet
                  if (val == 'edit') _navigateToEditAccount(acc);
                  if (val == 'delete') _handleDeleteAccount(acc);
                },
                itemBuilder: (ctx) => [
                  if (!acc.isDefault)
                    const PopupMenuItem(
                        value: 'primary',
                        child: Text("Set as Primary Account",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500))),
                  const PopupMenuItem(
                      value: 'history',
                      child: Text("View Transaction History",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500))),
                  const PopupMenuItem(
                      value: 'edit',
                      child: Text("Edit Account",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500))),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Text("Delete Account",
                          style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                              fontWeight: FontWeight.w700))),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(
                height: 1,
                color: isDark
                    ? baseColor.withValues(alpha: 0.15)
                    : baseColor.withValues(alpha: 0.1)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniData(
                  "Reserved", acc.reservedBalance, AppColors.warning),
              _buildMiniData(
                  "Total Worth", acc.totalBalance, colorScheme.onSurface),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumNetWorthCard(AccountProvider provider, bool isDark) {
    final Color gradStart =
        isDark ? AppColors.accountsCardBg : const Color(0xFF1E293B);
    final Color gradEnd =
        isDark ? AppColors.darkBgSecondary : const Color(0xFF0F172A);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [gradStart, gradEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("TOTAL NET WORTH",
              style: TextStyle(
                  color: AppColors.darkTextPrimary.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2)),
          const SizedBox(height: 6),
          Text("₹${provider.totalAll.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkTextPrimary,
                  letterSpacing: -1.0)),
          const SizedBox(height: 24),
          Row(children: [
            _buildGlassStatCard(
                "Cash", provider.totalCash, AppColors.incomeAmount),
            const SizedBox(width: 12),
            _buildGlassStatCard(
                "Bank", provider.totalBank, AppColors.savingsPrimary),
          ]),
        ],
      ),
    );
  }

  Widget _buildGlassStatCard(String label, double amount, Color accCol) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkTextPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.darkTextPrimary.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                  width: 6,
                  height: 6,
                  decoration:
                      BoxDecoration(color: accCol, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color:
                          AppColors.darkTextPrimary.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 6),
            Text("₹${amount.toStringAsFixed(0)}",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkTextPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(title,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted)),
    );
  }

  Widget _buildMiniData(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: color.withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text("₹ $value",
            style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}