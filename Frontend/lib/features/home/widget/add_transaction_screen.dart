import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:front_end/core/models/account_model.dart';
import 'package:front_end/core/services/account_service.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/account_provider.dart';
import 'package:front_end/core/providers/transaction_provider.dart';
import 'package:front_end/features/analytics/provider/analytics_provider.dart';
import 'package:front_end/core/constants/app_colors.dart';
import 'package:front_end/core/services/sound_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final bool initialIsExpense;

  const AddTransactionScreen({
    super.key,
    this.initialIsExpense = false,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String amount = "";
  DateTime selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isFetchingAccounts = true;
  late bool _isExpense;

  List<AccountModel> _accounts = [];
  String? _selectedAccountId;
  String? _selectedAccountName;
  String? _selectedCategory;
  bool _showAccountOptions = false;

  final TextEditingController _amountController = TextEditingController(); // ✅ FIX 4: controller for amount to clear on toggle
  final TextEditingController descriptionController = TextEditingController();

  final List<Map<String, dynamic>> _incomeCategories = [
    {"name": "Salary", "icon": Icons.payments, "color": AppColors.catSalary},
    {
      "name": "Freelance",
      "icon": Icons.laptop_mac,
      "color": AppColors.catFreelance
    },
    {"name": "Invest", "icon": Icons.trending_up, "color": AppColors.catInvest},
    {
      "name": "Business",
      "icon": Icons.storefront,
      "color": AppColors.catBusiness
    },
    {"name": "Rental", "icon": Icons.home, "color": AppColors.catRental},
    {
      "name": "Grants",
      "icon": Icons.card_giftcard,
      "color": AppColors.catGrants
    },
    {
      "name": "Refunds",
      "icon": Icons.assignment_return,
      "color": AppColors.catHealth
    },
    {"name": "Other", "icon": Icons.more_horiz, "color": AppColors.catOther},
  ];

  final List<Map<String, dynamic>> _expenseCategories = [
    {"name": "Food", "icon": Icons.restaurant, "color": AppColors.catFood},
    {
      "name": "Transport",
      "icon": Icons.directions_bus,
      "color": AppColors.catTransport
    },
    {
      "name": "Shopping",
      "icon": Icons.shopping_bag,
      "color": AppColors.catShopping
    },
    {"name": "Bills", "icon": Icons.bolt, "color": AppColors.catBills},
    {
      "name": "Health",
      "icon": Icons.medical_services,
      "color": AppColors.catHealth
    },
    {"name": "Travel", "icon": Icons.flight, "color": AppColors.catTravel},
    {"name": "Edu", "icon": Icons.school, "color": AppColors.catRental},
    {"name": "Fun", "icon": Icons.movie, "color": AppColors.catShopping},
    {
      "name": "Groceries",
      "icon": Icons.local_grocery_store,
      "color": AppColors.catSalary
    },
    {
      "name": "Gifts",
      "icon": Icons.card_giftcard,
      "color": AppColors.catGrants
    },
    {"name": "Rent", "icon": Icons.home_work, "color": AppColors.catOther},
    {"name": "Other", "icon": Icons.more_horiz, "color": AppColors.catOther},
  ];

  @override
  void initState() {
    super.initState();
    _isExpense = widget.initialIsExpense;
    _loadWallets();
  }

  @override
  void dispose() {
    _amountController.dispose(); // ✅ FIX 4: dispose amount controller
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadWallets() async {
    try {
      final result = await AccountService.getAccountDashboard();
      if (!mounted) return;
      final accountsData = result['accounts'];
      _accounts = accountsData is List<AccountModel> ? accountsData : [];
      if (_accounts.isNotEmpty) {
        final primary = _accounts.firstWhere(
          (acc) => acc.isDefault == true,
          orElse: () => _accounts.firstWhere(
            (acc) => acc.type == "CASH",
            orElse: () => _accounts.first,
          ),
        );
        _selectedAccountId = primary.id;
        _selectedAccountName = primary.name;
      }
      setState(() => _isFetchingAccounts = false);
    } catch (e) {
      if (mounted) setState(() => _isFetchingAccounts = false);
    }
  }

  Future<void> _handleSave() async {
    if (_selectedAccountId == null ||
        amount.isEmpty ||
        double.tryParse(amount) == null ||
        double.parse(amount) <= 0 ||
        _selectedCategory == null) {
      _showSnackBar("Please fill all required fields properly", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ FIX 1: Use noon to avoid timezone date shifting
      final transactedAt = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        12, 0, 0,
      ).toIso8601String();

      // ✅ FIX 2: Use UUID for idempotency key to avoid collisions
      final idempotencyKey = const Uuid().v4();

      final result = await TransactionService.processTransaction(
        accountId: _selectedAccountId!,
        amount: amount,
        type: _isExpense ? "EXPENSE" : "INCOME",
        direction: "STANDARD",
        category: _selectedCategory!,
        description: descriptionController.text,
        idempotencyKey: idempotencyKey,
        transactedAt: transactedAt,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        await context.read<AccountProvider>().loadAccounts();
        await context.read<TransactionProvider>().fetchTransactions();
        await context.read<AnalyticsProvider>().reload();

        // ✅ FIX 3: Play sound BEFORE pop so it doesn't get killed
        await SoundService.instance.playTransaction(
          _isExpense ? TransactionSound.expense : TransactionSound.income,
        );

        Navigator.pop(
            context, "${_isExpense ? 'Expense' : 'Income'} saved successfully!");
      } else {
        _showSnackBar(result['message'] ?? "Failed to save");
      }
    } catch (e) {
      if (mounted) _showSnackBar("Transaction failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? theme.colorScheme.error : theme.colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleType(bool isExpense) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isExpense = isExpense;
      _selectedCategory = null;
      _showAccountOptions = false;
      // ✅ FIX 4: Clear amount on type toggle
      amount = "";
      _amountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTopToggle(),
            _isFetchingAccounts
                ? const Expanded(
                    child: Center(child: CircularProgressIndicator()))
                : Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Amount"),
                          _buildAmountField(),
                          const SizedBox(height: 16),
                          _buildLabel("Description (Optional)"),
                          _buildDefaultField(
                            controller: descriptionController,
                            hint: "What was this for?",
                          ),
                          const SizedBox(height: 16),
                          _buildLabel("Date"),
                          _datePicker(),
                          const SizedBox(height: 24),
                          _buildLabel("Account Type"),
                          _buildAccountSelectorBox(),
                          if (_showAccountOptions) _buildAccountList(),
                          const SizedBox(height: 24),
                          _buildLabel("Category"),
                          _buildTwoLineCategories(),
                        ],
                      ),
                    ),
                  ),
            _buildStickySaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new,
                size: 18, color: theme.colorScheme.primary),
          ),
          Text(
            "Add Transaction",
            style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildTopToggle() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _toggleBtn("Income", !_isExpense, AppColors.success, isDark),
            _toggleBtn("Expense", _isExpense, AppColors.error, isDark),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, Color borderColor, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _toggleType(label == "Expense"),
        child: Container(
          margin: const EdgeInsets.all(4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? (isDark ? AppColors.darkBgCard : AppColors.lightBgPrimary)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: active ? Border.all(color: borderColor, width: 2.5) : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active
                  ? borderColor
                  : (isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ✅ FIX 4: Separate amount field using _amountController
  Widget _buildAmountField() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
      ],
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
      decoration: InputDecoration(
        prefixText: "₹ ",
        hintText: "0.00",
        filled: true,
        fillColor: isDark ? AppColors.darkBgCard : AppColors.lightBgSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (val) => amount = val,
    );
  }

  Widget _buildDefaultField({
    TextEditingController? controller,
    required String hint,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      style: TextStyle(
        fontSize: 16,
        color: theme.colorScheme.primary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDark ? AppColors.darkBgCard : AppColors.lightBgSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _datePicker() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (d != null) setState(() => selectedDate = d);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBgCard : AppColors.lightBgSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd MMM, yyyy').format(selectedDate),
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary),
            ),
            Icon(Icons.calendar_month,
                size: 20,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelectorBox() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _showAccountOptions = !_showAccountOptions),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBgCard : AppColors.lightBgSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedAccountName ?? "Select Account",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary),
            ),
            Icon(Icons.keyboard_arrow_down,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountList() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgCard : AppColors.lightBgPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: ListView(
        shrinkWrap: true,
        children: _accounts.map((acc) {
          return ListTile(
            dense: true,
            title: Text(
              acc.name,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
            onTap: () => setState(() {
              _selectedAccountId = acc.id;
              _selectedAccountName = acc.name;
              _showAccountOptions = false;
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTwoLineCategories() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cats = _isExpense ? _expenseCategories : _incomeCategories;

    return SizedBox(
      height: 180,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),
        itemCount: cats.length,
        itemBuilder: (context, index) {
          final item = cats[index];
          final isSel = _selectedCategory == item['name'];

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = item['name']),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBgCard : AppColors.lightBgPrimary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSel
                      ? theme.colorScheme.primary
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'], color: item['color'] as Color, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    item['name'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSel
                          ? theme.colorScheme.primary
                          : (isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStickySaveButton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSecondary : AppColors.lightBgPrimary,
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.onPrimary,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  "Save ${_isExpense ? 'Expense' : 'Income'}",
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}