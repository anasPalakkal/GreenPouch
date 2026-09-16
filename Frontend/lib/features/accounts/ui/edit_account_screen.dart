import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/account_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/account_provider.dart';

class EditAccountScreen extends StatefulWidget {
  final AccountModel account;

  const EditAccountScreen({super.key, required this.account});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  late TextEditingController _nameController;
  late TextEditingController _minBalanceController;
  late String _selectedType;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account.name);
    _minBalanceController =
        TextEditingController(text: widget.account.minBalance);
    _selectedType = widget.account.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final minBal = _minBalanceController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      await context.read<AccountProvider>().updateAccount(
            widget.account.id,
            name: name,
            type: _selectedType,
            minBalance: minBal.isEmpty ? "0" : minBal,
          );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Failed to update account"),
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
    final textSec =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

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
          "Update Account",
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
              padding: const EdgeInsets.only(top: 8, left: 12, bottom: 24),
              child: Text(
                "This is how the account will appear in your lists and charts.",
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

            // --- ACCOUNT TYPE ---
            Text(
              "ACCOUNT TYPE",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: textSec,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTypeOption(
                  "CASH",
                  Icons.wallet_rounded,
                  _selectedType == "CASH",
                  AppColors.incomeAmount,
                  isDark,
                  textSec,
                  () => setState(() => _selectedType = "CASH"),
                ),
                const SizedBox(width: 16),
                _buildTypeOption(
                  "BANK",
                  Icons.account_balance_rounded,
                  _selectedType == "BANK",
                  AppColors.savingsPrimary,
                  isDark,
                  textSec,
                  () => setState(() => _selectedType = "BANK"),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // --- SAVE BUTTON ---
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
                onPressed: _isProcessing ? null : _handleSave,
                child: _isProcessing
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: colorScheme.onPrimary, strokeWidth: 2.5),
                      )
                    : const Text(
                        "Save Changes",
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