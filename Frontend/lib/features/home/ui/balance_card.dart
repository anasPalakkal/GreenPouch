import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/account_model.dart';
import '../../../core/providers/account_provider.dart';
import 'package:front_end/navigation/navigation_service.dart';
import 'package:front_end/core/constants/app_colors.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  String _fmt(String value) {
    final n = double.tryParse(value) ?? 0;
    return NumberFormat('#,##,###').format(n);
  }

  @override
  Widget build(BuildContext context) {
    // Detect if the app is currently in dark mode
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // --- PREMIUM FINTECH BRAND COLORS ---
    const Color premiumGreen = Color(0xFF0F766E); // Grasshopper Green
    const Color premiumDarkGreen = Color(0xFF4A6B36); // Earthy Dark Green for gradients

    // Dynamic colors based on theme
    final Color textColor = isDark ? Colors.white : AppColors.darkTextPrimary;
    final Color chartColor = isDark ? premiumGreen : AppColors.incomeAmount;
    final Color reservedColor =
        isDark ? const Color(0xFFEAB308) : AppColors.warning;
    final Color worthColor = isDark ? premiumGreen : AppColors.incomeAmount;

    final provider = context.watch<AccountProvider>();
    final AccountModel? account = provider.defaultAccount;

    if (provider.isLoading) {
      return _shell(
        isDark: isDark,
        textColor: textColor,
        premiumGreen: premiumGreen,
        premiumDarkGreen: premiumDarkGreen,
        child: SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(
              color: textColor,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (account == null) return const SizedBox.shrink();

    return _shell(
      isDark: isDark,
      textColor: textColor,
      premiumGreen: premiumGreen,
      premiumDarkGreen: premiumDarkGreen,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: account label + wallet icon ─────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: textColor.withOpacity(0.20), width: 0.8),
                  ),
                  child: Text(
                    account.name.toUpperCase(),
                    style: TextStyle(
                      color: textColor.withOpacity(0.70),
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: textColor.withOpacity(0.10),
                    border: Border.all(
                        color: textColor.withOpacity(0.20), width: 0.8),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: textColor.withOpacity(0.70),
                    size: 17,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ── Row 2: Balance ─────────────────────────────────────────
            Text(
              "₹ ${_fmt(account.availableBalance)}",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -1.2,
                height: 1,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Available Balance",
              style: TextStyle(
                color: textColor.withOpacity(0.50),
                fontSize: 12,
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 16),

            // ── Sparkline chart ────────────────────────────────────────
            SizedBox(
              height: 56,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  lineTouchData: const LineTouchData(enabled: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      curveSmoothness: 0.4,
                      barWidth: 2.5,
                      color: chartColor,
                      dotData: const FlDotData(show: false),
                      spots: const [
                        FlSpot(0, 1.0),
                        FlSpot(1, 1.4),
                        FlSpot(2, 1.2),
                        FlSpot(3, 1.9),
                        FlSpot(4, 1.5),
                        FlSpot(5, 2.2),
                        FlSpot(6, 2.0),
                      ],
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            chartColor.withOpacity(isDark ? 0.40 : 0.28),
                            chartColor.withOpacity(0.00),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Divider ────────────────────────────────────────────────
            Container(height: 0.6, color: textColor.withOpacity(0.20)),

            const SizedBox(height: 16),

            // ── Stats row ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _stat(
                    icon: Icons.lock_outline_rounded,
                    label: "Reserved",
                    value: account.reservedBalance,
                    color: reservedColor,
                    textColor: textColor,
                  ),
                ),
                Container(
                  width: 0.6,
                  height: 36,
                  color: textColor.withOpacity(0.20),
                ),
                Expanded(
                  child: _stat(
                    icon: Icons.trending_up_rounded,
                    label: "Total Worth",
                    value: account.totalBalance,
                    color: worthColor,
                    textColor: textColor,
                    alignRight: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ── Manage Wallets button ──────────────────────────────────
            GestureDetector(
              onTap: () {
                NavigationService.bottomIndex.value = 2;
                context.read<AccountProvider>().loadAccounts();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: textColor.withOpacity(isDark ? 0.08 : 0.10),
                  border: Border.all(
                      color: textColor.withOpacity(0.20), width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Manage Wallets",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: textColor.withOpacity(0.70),
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dynamic Shell (Handles Light & Dark modes) ───────────
  Widget _shell({
    required Widget child,
    required bool isDark,
    required Color textColor,
    required Color premiumGreen,
    required Color premiumDarkGreen,
  }) {
    // 1. Decorative Circles
    final decorativeCircles = Stack(
      children: [
        Positioned(
          top: -32,
          right: -32,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: textColor.withOpacity(0.07),
            ),
          ),
        ),
        Positioned(
          bottom: -20,
          left: 20,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: textColor.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          right: -10,
          child: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: textColor.withOpacity(0.04),
            ),
          ),
        ),
        child,
      ],
    );

    // 2. Light Theme Shell
    if (!isDark) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              premiumGreen, 
              premiumDarkGreen, 
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: premiumGreen.withOpacity(0.50), 
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: decorativeCircles,
        ),
      );
    }

    // 3. Dark Theme Shell (Rich Dark Green Gradient)
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        // A deep, premium dark green gradient for dark mode
        gradient: const LinearGradient(
          colors: [
            Color(0xFF14452F), // Rich Dark Green
            Color(0xFF092215), // Very Dark Forest Green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14452F).withOpacity(0.30), // Matching subtle green glow
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.08), // Subtle outline for depth
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: decorativeCircles,
      ),
    );
  }

  Widget _stat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color textColor,
    bool alignRight = false,
  }) {
    final formatted =
        NumberFormat('#,##,###').format(double.tryParse(value) ?? 2);

    return Padding(
      padding: EdgeInsets.only(
        left: alignRight ? 16 : 0,
        right: alignRight ? 0 : 16,
      ),
      child: Row(
        mainAxisAlignment:
            alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!alignRight) ...[
            _iconPill(icon, color),
            const SizedBox(width: 10),
          ],
          Column(
            crossAxisAlignment:
                alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: textColor.withOpacity(0.50),
                  fontSize: 11,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "₹ $formatted",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (alignRight) ...[
            const SizedBox(width: 10),
            _iconPill(icon, color),
          ],
        ],
      ),
    );
  }

  Widget _iconPill(IconData icon, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
      ),
      child: Icon(icon, color: color, size: 15),
    );
  }
}