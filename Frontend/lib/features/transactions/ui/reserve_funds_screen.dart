import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/account_provider.dart';
import 'package:front_end/core/providers/transaction_provider.dart';
import 'package:front_end/features/analytics/provider/analytics_provider.dart';
import 'package:front_end/core/constants/app_colors.dart';
import 'package:front_end/core/services/sound_service.dart';

class ReserveFundsScreen extends StatefulWidget {
  final String accountId;
  final String accountName;
  final bool initialIsReserveOut;

  const ReserveFundsScreen({
    super.key,
    required this.accountId,
    required this.accountName,
    this.initialIsReserveOut = false,
  });

  @override
  State<ReserveFundsScreen> createState() => _ReserveFundsScreenState();
}

class _ReserveFundsScreenState extends State<ReserveFundsScreen> {
  String amount = "";
  bool _isLoading = false;
  late bool _isReserveOut;
  String? _selectedCategory;

  final TextEditingController descriptionController = TextEditingController();

  // Unified categories for reserving/releasing funds
  final List<Map<String, dynamic>> _reserveCategories = [
    {"name": "Emergency", "icon": Icons.medical_services, "color": AppColors.catHealth},
    {"name": "Vacation", "icon": Icons.flight_takeoff, "color": AppColors.catTravel},
    {"name": "Taxes", "icon": Icons.receipt_long, "color": AppColors.catBills},
    {"name": "Gadget", "icon": Icons.smartphone, "color": AppColors.catShopping},
    {"name": "Vehicle", "icon": Icons.directions_car, "color": AppColors.catTransport},
    {"name": "Home", "icon": Icons.home, "color": AppColors.catRental},
    {"name": "Invest", "icon": Icons.trending_up, "color": AppColors.catInvest},
    {"name": "Other", "icon": Icons.more_horiz, "color": AppColors.catOther},
  ];

  @override
  void initState() {
    super.initState();
    _isReserveOut = widget.initialIsReserveOut;
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (amount.isEmpty ||
        double.tryParse(amount) == null ||
        double.parse(amount) <= 0 ||
        _selectedCategory == null) {
      _showSnackBar("Please fill all required fields properly", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await TransactionService.reserveFunds(
        accountId: widget.accountId,
        amount: amount,
        action: _isReserveOut ? "RELEASE" : "RESERVE", // RELEASE = Out to available, RESERVE = In to reserved
        category: _selectedCategory!,
        description: descriptionController.text,
        idempotencyKey: DateTime.now().millisecondsSinceEpoch.toString(), 
      );

      if (!mounted) return;

      if (result['success'] == true) {
        await context.read<AccountProvider>().loadAccounts();
        await context.read<TransactionProvider>().fetchTransactions();
        await context.read<AnalyticsProvider>().reload();
        await SoundService.instance.playTransaction(
      _isReserveOut ? TransactionSound.income : TransactionSound.expense,
    );

        Navigator.pop(context, "Funds ${_isReserveOut ? 'released to Available' : 'locked in Reserve'} successfully!");
      } else {
        _showSnackBar(result['message'] ?? result['error'] ?? "Failed to process reserve");
      }
    } catch (e) {
      if (mounted) _showSnackBar("Transaction failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? AppColors.expenseAmount : AppColors.incomeAmount,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _toggleType(bool isReserveOut) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isReserveOut = isReserveOut;
      _selectedCategory = null;
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Amount"),
                    _buildDefaultField(hint: "0.00", isAmount: true),
                    const SizedBox(height: 16),
                    _buildLabel("Reason / Description (Optional)"),
                    _buildDefaultField(
                      controller: descriptionController,
                      hint: "What is this reserve for?",
                    ),
                    const SizedBox(height: 24),
                    _buildLabel("Reserve Category"),
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
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: theme.colorScheme.onSurface),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Manage Reserves",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface),
              ),
              Text(
                widget.accountName,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopToggle() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBgCard : AppColors.lightBgSecondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _toggleBtn("Reserve In", !_isReserveOut, AppColors.warning, isDark),
            _toggleBtn("Reserve Out", _isReserveOut, AppColors.incomeAmount, isDark),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, Color activeColor, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _toggleType(label == "Reserve Out"),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: active ? Border.all(color: activeColor, width: 2) : Border.all(color: Colors.transparent, width: 2),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? activeColor : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultField({TextEditingController? controller, required String hint, bool isAmount = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = _isReserveOut ? AppColors.incomeAmount : AppColors.warning;

    return TextField(
      controller: controller,
      keyboardType: isAmount ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      inputFormatters: isAmount ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))] : [],
      style: TextStyle(
        fontSize: isAmount ? 24 : 16,
        fontWeight: isAmount ? FontWeight.w900 : FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        prefixText: isAmount ? "₹ " : null,
        prefixStyle: TextStyle(color: activeColor, fontSize: 24, fontWeight: FontWeight.w900),
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted, fontWeight: FontWeight.normal),
        filled: true,
        fillColor: isDark ? AppColors.darkBgCard : AppColors.lightBgSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: activeColor, width: 2)),
      ),
      onChanged: isAmount ? (val) => amount = val : null,
    );
  }

  Widget _buildTwoLineCategories() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeBorderColor = _isReserveOut ? AppColors.incomeAmount : AppColors.warning;

    return SizedBox(
      height: 180, 
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _reserveCategories.length,
        itemBuilder: (context, index) {
          final item = _reserveCategories[index];
          final isSel = _selectedCategory == item['name'];

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = item['name']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSel ? activeBorderColor.withValues(alpha: 0.1) : (isDark ? AppColors.darkBgCard : AppColors.lightBgSecondary),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSel ? activeBorderColor : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'], color: isSel ? activeBorderColor : (item['color'] as Color), size: 28),
                  const SizedBox(height: 8),
                  Text(
                    item['name'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                      color: isSel ? activeBorderColor : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
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
    final activeColor = _isReserveOut ? AppColors.incomeAmount : AppColors.warning;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: activeColor,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: activeColor.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Text(
                    _isReserveOut ? "Confirm Release" : "Confirm Reserve",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, letterSpacing: 0.5),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}