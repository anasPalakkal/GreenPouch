import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

// ⚠️ Ensure these imports match your actual project structure
import '../../../core/providers/account_provider.dart';
import '../provider/analytics_provider.dart';
import '../data/analytics_model.dart';
import 'package:front_end/navigation/navigation_service.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  // 🔥 CLEAN ACCENT COLOR
  final Color primaryAccent =
      const Color(0xFF3B82F6); // Sleek, professional blue

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AnalyticsProvider>().fetchDashboard();
      context.read<AccountProvider>().loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final anaP = context.watch<AnalyticsProvider>();
    final accP = context.watch<AccountProvider>();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? Colors.white70 : const Color(0xFF64748B);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      // 🔥 Deepened the light theme background slightly for better contrast against white cards
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(theme, textPrimary, textSecondary, isDark),
      body: Stack(
        children: [
          // ─── SUBTLE AMBIENT BACKGROUND ORBS ───
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                // 🔥 Slightly darker top orb in light mode
                color: isDark
                    ? Colors.white.withOpacity(0.02)
                    : Colors.black.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 200,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                // 🔥 Boosted the blue accent orb in light mode to add visual interest
                color: isDark
                    ? primaryAccent.withOpacity(0.03)
                    : primaryAccent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: const SizedBox(),
            ),
          ),

          // ─── MAIN CONTENT ───
          SafeArea(
            child: anaP.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                        color: isDark ? Colors.white : const Color(0xFF0F172A)))
                : anaP.error != null
                    ? _buildError(anaP, textSecondary)
                    : RefreshIndicator(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        backgroundColor:
                            isDark ? const Color(0xFF1E1E2C) : Colors.white,
                        onRefresh: () => anaP.fetchDashboard(),
                        child: ListView(
                          physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          children: [
                            _buildMasterControlsRow(
                                anaP, accP, isDark, textPrimary, textSecondary),
                            const SizedBox(height: 24),
                            if (anaP.data != null) ...[
                              _buildSummaryCards(anaP.data!, colorScheme,
                                  textPrimary, textSecondary, isDark),
                              const SizedBox(height: 16),

                              _buildIncomeExpenseCard(anaP.data!, colorScheme,
                                  textPrimary, textSecondary, isDark),
                              const SizedBox(height: 16),

                              _buildSpendGaugeCard(anaP.data!, colorScheme,
                                  textPrimary, textSecondary, isDark),
                              const SizedBox(height: 16),

                              _buildSpendingInsightsCard(
                                  anaP.data!,
                                  colorScheme,
                                  textPrimary,
                                  textSecondary,
                                  isDark),
                              const SizedBox(height: 16),

                              _buildSummaryStatisticsCard(
                                  anaP.data!,
                                  textPrimary,
                                  textSecondary,
                                  isDark), // ✅ add here
                            ] else
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 60),
                                  child: Text(
                                    "No data available.",
                                    style: TextStyle(
                                        color: textSecondary, fontSize: 15),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // ─── APPBAR ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
      ThemeData theme, Color textPrimary, Color textSecondary, bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: textPrimary, size: 20),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            NavigationService.bottomIndex.value = 0;
          }
        },
      ),
      title: Text(
        "Analytics",
        style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5),
      ),
    );
  }

  // ─── MASTER CONTROLS ROW ───────────────────────────────────────────────────
  Widget _buildMasterControlsRow(AnalyticsProvider anaP, AccountProvider accP,
      bool isDark, Color textPrimary, Color textSecondary) {
    final bool isCustomActive = anaP.currentTimeframe == 'Custom';

    String currentAccountName = "All Assets";
    if (anaP.currentAccountId != "all") {
      final allAccounts = [...accP.cashAccounts, ...accP.bankAccounts];
      try {
        currentAccountName =
            allAccounts.firstWhere((a) => a.id == anaP.currentAccountId).name;
      } catch (_) {}
    }

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: _buildSelectorButton(
            label: currentAccountName,
            isDark: isDark,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            onTap: () => _showAccountPicker(
                context, anaP, accP, isDark, textPrimary, textSecondary),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: _buildSelectorButton(
            label: isCustomActive ? "Custom" : anaP.currentTimeframe,
            isDark: isDark,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            onTap: () => _showTimeframePicker(
                context, anaP, isDark, textPrimary, textSecondary),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showMonthPicker(context, anaP, isDark, textPrimary, textSecondary);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: _glassContainer(
              isDark: isDark,
              padding: const EdgeInsets.all(14),
              customColor: isCustomActive
                  ? primaryAccent.withOpacity(isDark ? 0.2 : 0.1)
                  : null,
              child: Icon(
                Icons.calendar_month_outlined, // Minimalist icon
                size: 22,
                color: isCustomActive ? primaryAccent : textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectorButton({
    required String label,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: _glassContainer(
        isDark: isDark,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.unfold_more_rounded,
                color: textSecondary, size: 18), // Cleaner dropdown indicator
          ],
        ),
      ),
    );
  }

  // ─── BOTTOM SHEETS ─────────────────────────────────────────────────────────
  void _showAccountPicker(
      BuildContext context,
      AnalyticsProvider anaP,
      AccountProvider accP,
      bool isDark,
      Color textPrimary,
      Color textSecondary) {
    final accounts = [...accP.cashAccounts, ...accP.bankAccounts];

    _showCustomModal(context, isDark, textPrimary, "Select Account", [
      _buildSheetOption(
        label: "All Assets",
        icon: Icons.account_balance_wallet_outlined,
        isSelected: anaP.currentAccountId == "all",
        isDark: isDark,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        onTap: () {
          anaP.changeAccount("all");
          Navigator.pop(context);
        },
      ),
      ...accounts.map((a) {
        IconData accIcon = Icons.account_balance_wallet_outlined;
        if (a.name.toLowerCase().contains('bank'))
          accIcon = Icons.account_balance_outlined;
        if (a.name.toLowerCase().contains('cash'))
          accIcon = Icons.payments_outlined;
        if (a.name.toLowerCase().contains('card'))
          accIcon = Icons.credit_card_outlined;

        return _buildSheetOption(
          label: a.name,
          icon: accIcon,
          isSelected: anaP.currentAccountId == a.id,
          isDark: isDark,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          onTap: () {
            anaP.changeAccount(a.id);
            Navigator.pop(context);
          },
        );
      }),
    ]);
  }

  void _showTimeframePicker(BuildContext context, AnalyticsProvider anaP,
      bool isDark, Color textPrimary, Color textSecondary) {
    final options = [
      {"label": "Day", "icon": Icons.calendar_view_day_outlined},
      {"label": "Week", "icon": Icons.view_week_outlined},
      {"label": "Month", "icon": Icons.calendar_view_month_outlined},
      {"label": "Year", "icon": Icons.calendar_today_outlined},
    ];

    _showCustomModal(
        context,
        isDark,
        textPrimary,
        "Timeframe",
        options.map((opt) {
          final label = opt["label"] as String;
          final icon = opt["icon"] as IconData;

          return _buildSheetOption(
            label: label,
            icon: icon,
            isSelected: anaP.currentTimeframe == label,
            isDark: isDark,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            onTap: () {
              anaP.changeTimeframe(label);
              Navigator.pop(context);
            },
          );
        }).toList());
  }

  void _showCustomModal(BuildContext context, bool isDark, Color textPrimary,
      String title, List<Widget> children) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2)),
                ),
                Text(title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary)),
                const SizedBox(height: 24),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(children: children),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔥 CLEAN, MONOCHROME SHEET OPTION
  Widget _buildSheetOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    // Only use the primaryAccent color if selected, otherwise neutral
    final activeColor = isSelected ? primaryAccent : textSecondary;
    final bgColor = isSelected
        ? primaryAccent.withOpacity(isDark ? 0.15 : 0.08)
        : Colors.transparent;
    final borderColor =
        isSelected ? primaryAccent.withOpacity(0.3) : Colors.transparent;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: activeColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? primaryAccent : textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, color: primaryAccent, size: 22),
          ],
        ),
      ),
    );
  }

  // ─── SUMMARY CARDS ─────────────────────────────────────────────────────────
  Widget _buildSummaryCards(AnalyticsModel data, ColorScheme colorScheme,
      Color textPrimary, Color textSecondary, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            title:
                "${context.watch<AnalyticsProvider>().timeframeLabel} Income",
            amount: data.income,
            icon: Icons.trending_up_rounded,
            accentColor: const Color(0xFF10B981),
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _summaryCard(
            title:
                "${context.watch<AnalyticsProvider>().timeframeLabel} Expense",
            amount: data.expense,
            icon: Icons.trending_down_rounded,
            accentColor: const Color(0xFFEF4444),
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(
      {required String title,
      required double amount,
      required IconData icon,
      required Color accentColor,
      required Color textPrimary,
      required Color textSecondary,
      required bool isDark}) {
    return _baseGlassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 24, color: accentColor),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textSecondary)),
          const SizedBox(height: 4),
          Text(
            "₹${_fmt(amount)}",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: textPrimary,
                letterSpacing: -0.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─── INCOME VS EXPENSE CHART ───────────────────────────────────────────────
  Widget _buildIncomeExpenseCard(AnalyticsModel data, ColorScheme colorScheme,
      Color textPrimary, Color textSecondary, bool isDark) {
    int touchedIndex = -1;
    final bool hasIncome = data.income > 0;
    final bool hasExpense = data.expense > 0;
    final colorGreen = const Color(0xFF10B981);
    final colorRed = const Color(0xFFEF4444);
    final colorEmpty = isDark ? Colors.white10 : Colors.grey.shade300;

    return StatefulBuilder(
      builder: (context, setState) {
        List<PieChartSectionData> showingSections() {
          if (!hasIncome && !hasExpense)
            return [
              PieChartSectionData(
                  value: 1, color: colorEmpty, radius: 25, showTitle: false)
            ];
          final List<PieChartSectionData> list = [];
          if (hasIncome)
            list.add(PieChartSectionData(
                value: data.income,
                color: colorGreen,
                radius: touchedIndex == 0 ? 35 : 25,
                showTitle: false));
          if (hasExpense)
            list.add(PieChartSectionData(
                value: data.expense,
                color: colorRed,
                radius: touchedIndex == 1 ? 35 : 25,
                showTitle: false));
          return list;
        }

        return _baseGlassCard(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Income Vs Expense",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textPrimary)),
              const SizedBox(height: 24),
              SizedBox(
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: 75,
                        sectionsSpace: 4,
                        sections: showingSections(),
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  response == null ||
                                  response.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex =
                                  response.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          touchedIndex == 0
                              ? "₹${_fmt(data.income)}"
                              : touchedIndex == 1
                                  ? "₹${_fmt(data.expense)}"
                                  : data.netSavingsFormatted,
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: touchedIndex == 1
                                  ? colorRed
                                  : touchedIndex == 0
                                      ? colorGreen
                                      : (data.isDeficit
                                          ? colorRed
                                          : textPrimary)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          touchedIndex == 0
                              ? "Income"
                              : touchedIndex == 1
                                  ? "Expense"
                                  : "Net Savings",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.03)
                        : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text("Savings Rate",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textSecondary)),
                        const SizedBox(height: 4),
                        Text(data.savingsRateFormatted,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: data.isDeficit ? colorRed : colorGreen)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── SPEND GAUGE ───────────────────────────────────────────────────────────
  Widget _buildSpendGaugeCard(AnalyticsModel data, ColorScheme colorScheme,
      Color textPrimary, Color textSecondary, bool isDark) {
    final double pct = data.spendPercentageClamped;
    final Color gaugeColor = _getGaugeColor(pct);

    return _baseGlassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Spending Health",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textPrimary)),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: OverflowBox(
              maxHeight: 200,
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        startDegreeOffset: 180,
                        centerSpaceRadius: 60,
                        sectionsSpace: 0,
                        sections: [
                          PieChartSectionData(
                              value: pct,
                              color: gaugeColor,
                              radius: 22,
                              showTitle: false),
                          PieChartSectionData(
                              value: 100 - pct,
                              color: isDark
                                  ? Colors.white10
                                  : Colors.grey.shade300,
                              radius: 22,
                              showTitle: false),
                          PieChartSectionData(
                              value: 100,
                              color: Colors.transparent,
                              radius: 22,
                              showTitle: false),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 75,
                      child: Column(
                        children: [
                          Text("${pct.toStringAsFixed(1)}%",
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: textPrimary,
                                  letterSpacing: -1.0)),
                          const SizedBox(height: 2),
                          Text("of income spent",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
                color: gaugeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14)),
            child: Text("Status: ${data.healthStatus}",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: gaugeColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // ─── SPENDING INSIGHTS ─────────────────────────────────────────────────────
  Widget _buildSpendingInsightsCard(
      AnalyticsModel data,
      ColorScheme colorScheme,
      Color textPrimary,
      Color textSecondary,
      bool isDark) {
    final totalSpend = data.categories.fold(0.0, (sum, c) => sum + c.amount);

    if (data.categories.isEmpty) {
      return _baseGlassCard(
        isDark: isDark,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text("No spending data for this period.",
                style: TextStyle(
                    color: textSecondary, fontWeight: FontWeight.w500)),
          ),
        ),
      );
    }

    int? touchedIndex;
    return StatefulBuilder(
      builder: (context, setState) {
        List<PieChartSectionData> showingSections() {
          return data.categories.asMap().entries.map((entry) {
            final isTouched = entry.key == touchedIndex;
            return PieChartSectionData(
                value: entry.value.amount,
                color: entry.value.color,
                radius: isTouched ? 35 : 25,
                showTitle: false);
          }).toList();
        }

        final bool isTouched = touchedIndex != null &&
            touchedIndex! >= 0 &&
            touchedIndex! < data.categories.length;
        final selected = isTouched ? data.categories[touchedIndex!] : null;

        return _baseGlassCard(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Top Categories",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textPrimary)),
              const SizedBox(height: 24),
              SizedBox(
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: 75,
                        sectionsSpace: 3,
                        sections: showingSections(),
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  response == null ||
                                  response.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex =
                                  response.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            isTouched
                                ? "₹${_fmt(selected!.amount)}"
                                : "₹${_fmt(totalSpend)}",
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: textPrimary,
                                letterSpacing: -0.5)),
                        const SizedBox(height: 4),
                        Text(isTouched ? selected!.name : "Total Spending",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ...data.categories.asMap().entries.map((entry) {
                return _categoryRow(
                    entry.value,
                    entry.key,
                    touchedIndex,
                    textPrimary,
                    textSecondary,
                    (i) => setState(() => touchedIndex = i));
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _categoryRow(CategoryData cat, int index, int? touchedIndex,
      Color textPrimary, Color textSecondary, Function(int?) onHover) {
    final isActive = touchedIndex == index;
    return MouseRegion(
      onEnter: (_) => onHover(index),
      onExit: (_) => onHover(-1),
      child: GestureDetector(
        onTap: () => onHover(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
              color:
                  isActive ? cat.color.withOpacity(0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Container(
                  width: 14,
                  height: 14,
                  decoration:
                      BoxDecoration(color: cat.color, shape: BoxShape.circle)),
              const SizedBox(width: 14),
              Expanded(
                  child: Text(cat.name,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isActive ? FontWeight.w800 : FontWeight.w600,
                          color: textPrimary))),
              Text("₹${_fmt(cat.amount)}",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isActive ? cat.color : textPrimary)),
              const SizedBox(width: 12),
              SizedBox(
                  width: 44,
                  child: Text("${cat.percentage}%",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textSecondary))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStatisticsCard(
    AnalyticsModel data,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return _baseGlassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Summary Statistics",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _statItem(
                  title: "Total Transactions",
                  value: "${data.totalTransactions ?? 0}",
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              Expanded(
                child: _statItem(
                  title: "Total Income",
                  value: "₹${_fmt(data.income)}",
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statItem(
                  title: "Total Expense",
                  value: "₹${_fmt(data.expense)}",
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              Expanded(
                child: _statItem(
                  title: "Savings Rate",
                  value: data.savingsRateFormatted,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  highlight: !data.isDeficit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required String title,
    required String value,
    required Color textPrimary,
    required Color textSecondary,
    bool highlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: highlight ? const Color(0xFF10B981) : textPrimary,
          ),
        ),
      ],
    );
  }

  // ─── ERROR STATE ───────────────────────────────────────────────────────────
  Widget _buildError(AnalyticsProvider anaP, Color textSec) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
            const SizedBox(height: 16),
            Text(anaP.error ?? "Something went wrong.",
                textAlign: TextAlign.center,
                style: TextStyle(color: textSec, fontSize: 15)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: anaP.retry,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              child: const Text("Retry",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── CUSTOM MONTH PICKER BOTTOM SHEET ──────────────────────────────────────
  void _showMonthPicker(BuildContext context, AnalyticsProvider anaP,
      bool isDark, Color textPrimary, Color textSecondary) {
    int selectedYear = DateTime.now().year;
    final List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          icon: Icon(Icons.chevron_left_rounded,
                              color: textPrimary),
                          onPressed: () => setModalState(() => selectedYear--)),
                      Text(selectedYear.toString(),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: textPrimary)),
                      IconButton(
                          icon: Icon(Icons.chevron_right_rounded,
                              color: textPrimary),
                          onPressed: () => setModalState(() => selectedYear++)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 2),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                          anaP.fetchDashboardByMonth(index + 1, selectedYear);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white10
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: Text(months[index],
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── SHARED GLASS HELPERS ──────────────────────────────────────────────────
  Widget _baseGlassCard(
      {required Widget child, required bool isDark, EdgeInsets? padding}) {
    return _glassContainer(
      isDark: isDark,
      padding: padding ?? const EdgeInsets.all(24),
      borderRadius: 28,
      child: child,
    );
  }

  Widget _glassContainer(
      {required Widget child,
      required bool isDark,
      EdgeInsets padding = EdgeInsets.zero,
      double borderRadius = 16,
      Color? customColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            // 🔥 Higher opacity for light theme so it separates from the background
            color: customColor ??
                (isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.white.withOpacity(0.85)),
            borderRadius: BorderRadius.circular(borderRadius),
            // 🔥 Subtle dark border instead of white for light theme to create edges
            border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05),
                width: 1.0),
            // 🔥 Slightly stronger shadow for depth
            boxShadow: [
              if (!isDark)
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 8))
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Color _getGaugeColor(double pct) {
    if (pct <= 40) return const Color(0xFF10B981);
    if (pct <= 70) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _fmt(double v) => v.abs().toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
