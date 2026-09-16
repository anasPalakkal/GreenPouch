// lib/features/transactions/ui/filter_screen.dart (or wherever your path is)

import 'package:flutter/material.dart';
import 'package:front_end/core/models/account_model.dart';
import 'package:front_end/core/constants/app_colors.dart';

class FilterScreen extends StatefulWidget {
  final String selectedType;
  final String selectedCategory;
  final String? selectedAccountId; // Nullable string to accept ID or null
  final DateTime? startDate;
  final DateTime? endDate;
  final List<AccountModel> availableAccounts;

  const FilterScreen({
    super.key,
    required this.selectedType,
    required this.selectedCategory,
    this.selectedAccountId, 
    this.startDate,
    this.endDate,
    required this.availableAccounts,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  int selectedMenuIndex = 0;

  late String type;
  late String category;
  String? accountId; 

  DateTime? startDate;
  DateTime? endDate;

  final List<String> leftMenu = [
    "Transaction Type",
    "Category",
    "Account",
    "Date",
  ];

  final List<String> types = [
    "All Type",
    "Income",
    "Expense",
    "Reserve",
    "Transfer",
  ];

  final List<String> categories = [
    "All",
    "Food", "Transport", "Shopping", "Bills", "Health", "Travel", "Edu", "Fun", "Groceries", "Gifts", "Rent",
    "Salary", "Freelance", "Invest", "Business", "Rental", "Grants", "Refunds",
    "Emergency", "Vacation", "Taxes", "Gadget", "Vehicle", "Home",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    type = widget.selectedType;
    category = widget.selectedCategory;
    accountId = widget.selectedAccountId; 
    startDate = widget.startDate;
    endDate = widget.endDate;
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        startDate = date;
        if (endDate != null && endDate!.isBefore(date)) {
          endDate = null;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: endDate ?? (startDate ?? DateTime.now()),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => endDate = date);
  }

  void _clearAll() {
    setState(() {
      type = "All Type";
      category = "All";
      accountId = null; 
      startDate = null;
      endDate = null;
    });
  }

  int get _activeFilterCount {
    int count = 0;
    if (type != "All Type") count++;
    if (category != "All") count++;
    if (accountId != null) count++; 
    if (startDate != null || endDate != null) count++;
    return count;
  }

  bool get _hasDateFilter => startDate != null || endDate != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final leftMenuBg = isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary;
    final leftMenuSelectedBg = isDark ? AppColors.darkBgPrimary : AppColors.lightBgPrimary;
    final leftMenuUnselectedText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Filters"),
            if (_activeFilterCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(12)),
                child: Text("$_activeFilterCount", style: TextStyle(color: colorScheme.onPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: colorScheme.primary),
        ),
        actions: [
          TextButton(
            onPressed: _clearAll,
            child: Text("Clear", style: TextStyle(color: colorScheme.primary)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 150,
                  color: leftMenuBg,
                  child: ListView.builder(
                    itemCount: leftMenu.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedMenuIndex == index;
                      final hasDot = _sectionHasActiveFilter(index);

                      return InkWell(
                        onTap: () => setState(() => selectedMenuIndex = index),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? leftMenuSelectedBg : leftMenuBg,
                            border: Border(left: BorderSide(color: isSelected ? colorScheme.primary : Colors.transparent, width: 4)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  leftMenu[index],
                                  style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? colorScheme.primary : leftMenuUnselectedText),
                                ),
                              ),
                              if (hasDot) Container(width: 7, height: 7, decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(child: _buildRightPanel(isDark, colorScheme)),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: BoxDecoration(color: colorScheme.surface, border: Border(top: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider))),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      "type": type,
                      "category": category,
                      "accountId": accountId, 
                      "startDate": startDate,
                      "endDate": endDate,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Apply", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _sectionHasActiveFilter(int index) {
    switch (index) {
      case 0: return type != "All Type";
      case 1: return category != "All";
      case 2: return accountId != null; 
      case 3: return _hasDateFilter;
      default: return false;
    }
  }

  Widget _buildRightPanel(bool isDark, ColorScheme colorScheme) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    switch (selectedMenuIndex) {
      case 0:
        return ListView(
          children: types.map((e) {
            return RadioListTile<String>(
              title: Text(e, style: TextStyle(color: textColor)),
              value: e,
              groupValue: type,
              activeColor: colorScheme.primary,
              onChanged: (v) => setState(() => type = v!),
            );
          }).toList(),
        );
      case 1:
        return ListView(
          children: categories.map((e) {
            return RadioListTile<String>(
              title: Text(e, style: TextStyle(color: textColor)),
              value: e,
              groupValue: category,
              activeColor: colorScheme.primary,
              onChanged: (v) => setState(() => category = v!),
            );
          }).toList(),
        );
      case 2:
        return ListView(
          children: [
            RadioListTile<String?>(
              title: Text("All Accounts", style: TextStyle(color: textColor)),
              secondary: Icon(Icons.all_inclusive, color: subtitleColor),
              value: null, 
              groupValue: accountId,
              activeColor: colorScheme.primary,
              onChanged: (v) => setState(() => accountId = v),
            ),
            ...widget.availableAccounts.map((a) {
              final isCash = a.type == "CASH";
              return RadioListTile<String?>(
                title: Text(a.name, style: TextStyle(color: textColor)),
                secondary: Icon(
                  isCash ? Icons.account_balance_wallet_rounded : Icons.account_balance,
                  color: isCash ? AppColors.incomeAmount : AppColors.savingsPrimary,
                ),
                value: a.id, 
                groupValue: accountId,
                activeColor: colorScheme.primary,
                onChanged: (v) => setState(() => accountId = v),
              );
            }),
          ],
        );
      case 3:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DatePickerTile(label: "Start Date", date: startDate, isDark: isDark, textColor: textColor, subtitleColor: subtitleColor, onTap: _pickStartDate, onClear: startDate != null ? () => setState(() => startDate = null) : null),
              const SizedBox(height: 12),
              _DatePickerTile(label: "End Date", date: endDate, isDark: isDark, textColor: textColor, subtitleColor: subtitleColor, onTap: _pickEndDate, onClear: endDate != null ? () => setState(() => endDate = null) : null),
              if (_hasDateFilter) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: isDark ? AppColors.darkBgCard : AppColors.lightBgSecondary, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: subtitleColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          startDate != null && endDate == null
                              ? "Showing transactions from ${_fmt(startDate!)} onwards."
                              : startDate == null && endDate != null
                                  ? "Showing transactions up to ${_fmt(endDate!)}."
                                  : "Showing transactions from ${_fmt(startDate!)} to ${_fmt(endDate!)}.",
                          style: TextStyle(color: subtitleColor, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      default:
        return const SizedBox();
    }
  }

  String _fmt(DateTime d) => "${d.day.toString().padLeft(2, '0')} / ${d.month.toString().padLeft(2, '0')} / ${d.year}";
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool isDark;
  final Color textColor;
  final Color subtitleColor;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DatePickerTile({
    required this.label, required this.date, required this.isDark, required this.textColor, required this.subtitleColor, required this.onTap, this.onClear,
  });

  String get _displayDate {
    if (date == null) return "Select date";
    return "${date!.day.toString().padLeft(2, '0')} / ${date!.month.toString().padLeft(2, '0')} / ${date!.year}";
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: isDark ? AppColors.darkBgCard : AppColors.lightBgSecondary, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 18, color: subtitleColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: subtitleColor, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(_displayDate, style: TextStyle(color: date != null ? textColor : subtitleColor, fontSize: 15, fontWeight: date != null ? FontWeight.w700 : FontWeight.normal)),
                ],
              ),
            ),
            if (onClear != null) GestureDetector(onTap: onClear, child: Icon(Icons.close, size: 18, color: subtitleColor)),
          ],
        ),
      ),
    );
  }
}