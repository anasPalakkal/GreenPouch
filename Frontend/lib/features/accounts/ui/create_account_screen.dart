import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/account_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/account_provider.dart';

class CreateAccountScreen extends StatefulWidget {
  final String initialType;

  const CreateAccountScreen({super.key, this.initialType = "CASH"});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _minBalanceController = TextEditingController();
  late String _selectedType;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _depositController.dispose();
    _minBalanceController.dispose();
    super.dispose();
  }

  InputDecoration _getPremiumDecoration(
    ThemeData theme,
    ColorScheme colorScheme,
    Color textSec, {
    required String label,
    required IconData icon,
    String? prefixText,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: textSec, fontWeight: FontWeight.w500),
      floatingLabelStyle:
          TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w800),
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : colorScheme.onSurface.withValues(alpha: 0.04),
      prefixIcon: Icon(icon,
          color: colorScheme.primary.withValues(alpha: 0.8), size: 22),
      prefixText: prefixText,
      prefixStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
    );
  }

  Widget _buildTypeOption(
    String label,
    IconData icon,
    bool isSel,
    Color col,
    bool isDark,
    Color txt,
    VoidCallback onTap,
  ) {
    final unselectedBg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.03);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSel ? col.withValues(alpha: 0.15) : unselectedBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSel ? col : Colors.transparent,
              width: isSel ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSel ? col : txt.withValues(alpha: 0.7), size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSel ? col : txt,
                  fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCreate() async {
    final name = _nameController.text.trim();
    final deposit = _depositController.text.trim();
    final minBal = _minBalanceController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      await AccountService.createAccount(
        name: name,
        type: _selectedType,
        initialDeposit: deposit.isEmpty ? "0" : deposit,
        minBalance: minBal.isEmpty ? "0" : minBal,
      );
      if (!mounted) return;

      context.read<AccountProvider>().loadAccounts();
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Failed to create account"),
            backgroundColor: AppColors.expenseAmount,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final textSec = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "New Account",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ACCOUNT NAME ---
            TextField(
              controller: _nameController,
              autofocus: true,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              decoration: _getPremiumDecoration(
                theme,
                colorScheme,
                textSec,
                label: "Account Name",
                icon: Icons.account_balance_wallet_rounded,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12, bottom: 20),
              child: Text(
                "e.g., Main Wallet, Salary Account, Travel Fund",
                style: TextStyle(
                    fontSize: 12, color: textSec.withValues(alpha: 0.8)),
              ),
            ),

            // --- ACCOUNT TYPE DROPDOWN (moved up so it opens downward) ---
            // --- ACCOUNT TYPE CUSTOM DROPDOWN ---
            PopupMenuButton<String>(
              initialValue: _selectedType,
              onSelected: (val) => setState(() => _selectedType = val),
              offset: const Offset(0, 56), // opens strictly below
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              color: colorScheme.surface,
              constraints: const BoxConstraints(minWidth: double.infinity),
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: "CASH",
                  child: Row(
                    children: [
                      Icon(Icons.wallet_rounded,
                          color: AppColors.incomeAmount, size: 20),
                      const SizedBox(width: 12),
                      Text("Cash Wallet",
                          style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "BANK",
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_rounded,
                          color: AppColors.savingsPrimary, size: 20),
                      const SizedBox(width: 12),
                      Text("Bank Account",
                          style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : colorScheme.onSurface.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedType == "CASH"
                          ? Icons.wallet_rounded
                          : Icons.account_balance_rounded,
                      color: colorScheme.primary.withValues(alpha: 0.8),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedType == "CASH"
                            ? "Cash Wallet"
                            : "Bank Account",
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        color: textSec, size: 22),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12, bottom: 20),
              child: Text(
                "Select whether this is a physical wallet or a bank account.",
                style: TextStyle(
                    fontSize: 12, color: textSec.withValues(alpha: 0.8)),
              ),
            ),
            // --- OPENING BALANCE ---
            TextField(
              controller: _depositController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              decoration: _getPremiumDecoration(
                theme,
                colorScheme,
                textSec,
                label: "Opening Balance",
                icon: Icons.payments_rounded,
                prefixText: "₹ ",
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12, bottom: 20),
              child: Text(
                "The current amount of money already in this account.",
                style: TextStyle(
                    fontSize: 12, color: textSec.withValues(alpha: 0.8)),
              ),
            ),

            // --- LOW BALANCE REMINDER ---
            TextField(
              controller: _minBalanceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              decoration: _getPremiumDecoration(
                theme,
                colorScheme,
                textSec,
                label: "Low Balance Reminder",
                icon: Icons.notifications_active_rounded,
                prefixText: "₹ ",
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12, bottom: 32),
              child: Text(
                "We'll visually notify you if funds drop below this limit.",
                style: TextStyle(
                    fontSize: 12, color: textSec.withValues(alpha: 0.8)),
              ),
            ),

            // --- CREATE BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shadowColor: colorScheme.primary.withValues(alpha: 0.4),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isProcessing ? null : _handleCreate,
                child: _isProcessing
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: colorScheme.onPrimary, strokeWidth: 2.5),
                      )
                    : const Text(
                        "Create Account",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
