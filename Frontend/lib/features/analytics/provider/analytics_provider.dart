import 'package:flutter/material.dart';
import '../data/analytics_model.dart';
import '../service/service.dart'; // Ensure this path matches

class AnalyticsProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  String currentAccountId = "all";
  String currentTimeframe = "Month";
  String? customMonthLabel; 

  AnalyticsModel? data;
  int _activeRequestId = 0;

  // ─── FETCH DASHBOARD (STANDARD TIMEFRAMES) ───────────────────────
  Future<void> fetchDashboard({
    String? accountId,
    String? timeframe,
  }) async {
    // 🔥 Prevent Pull-To-Refresh from wiping out the custom month selection
    if (timeframe == null && currentTimeframe == 'Custom' && customMonthLabel != null) {
       final parts = customMonthLabel!.split(' ');
       final monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
       int m = monthNames.indexOf(parts[0]) + 1;
       int y = int.parse(parts[1]);
       if (accountId != null) currentAccountId = accountId;
       return fetchDashboardByMonth(m, y);
    }

    final int requestId = ++_activeRequestId;
    isLoading = true;
    error = null;

    if (accountId != null) currentAccountId = accountId;
    if (timeframe != null) currentTimeframe = timeframe;

    notifyListeners();

    try {
      final result = await AnalyticsService.getDashboardData(
        accountId: currentAccountId,
        timeframe: currentTimeframe,
      );

      if (requestId == _activeRequestId) {
        data = result;
      }
    } catch (e) {
      if (requestId == _activeRequestId) {
        error = e.toString().replaceAll("Exception: ", "");
      }
    } finally {
      if (requestId == _activeRequestId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  // ─── FETCH BY SPECIFIC MONTH (CUSTOM FILTER) ─────────────────────
  Future<void> fetchDashboardByMonth(int month, int year) async {
    final int requestId = ++_activeRequestId;
    isLoading = true;
    error = null;
    
    final monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    customMonthLabel = "${monthNames[month - 1]} $year";
    currentTimeframe = "Custom"; 
    notifyListeners();

    try {
      // 🔥 CRITICAL FIX: explicitly passing 'Custom' so the service knows what to do
      final result = await AnalyticsService.getDashboardData(
        accountId: currentAccountId,
        timeframe: 'Custom', 
        month: month.toString(),
        year: year.toString(),
      );

      if (requestId == _activeRequestId) {
        data = result;
      }
    } catch (e) {
      if (requestId == _activeRequestId) {
        error = e.toString().replaceAll("Exception: ", "");
      }
    } finally {
      if (requestId == _activeRequestId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  // ─── GETTERS & HELPERS ────────────────────────────────────────
  String get timeframeLabel {
    switch (currentTimeframe) {
      case 'Day': return "Today";
      case 'Week': return "This Week";
      case 'Year': return "This Year";
      case 'Custom': return customMonthLabel ?? "Selected Month";
      default: return "This Month";
    }
  }

  Future<void> changeTimeframe(String timeframe) async {
    const valid = ['Day', 'Week', 'Month', 'Year'];
    if (!valid.contains(timeframe)) return;
    if (timeframe == currentTimeframe) return;
    await fetchDashboard(timeframe: timeframe);
  }

  Future<void> changeAccount(String accountId) async {
    if (accountId == currentAccountId) return;
    await fetchDashboard(accountId: accountId);
  }

  Future<void> retry() async {
    await fetchDashboard();
  }
  // ─── RELOAD CURRENT DATA ─────────────────────────────────────
Future<void> reload() async {
  if (currentTimeframe == 'Custom' && customMonthLabel != null) {
    final parts = customMonthLabel!.split(' ');
    final monthNames = [
      "Jan","Feb","Mar","Apr","May","Jun",
      "Jul","Aug","Sep","Oct","Nov","Dec"
    ];

    int month = monthNames.indexOf(parts[0]) + 1;
    int year = int.parse(parts[1]);

    await fetchDashboardByMonth(month, year);
  } else {
    await fetchDashboard(
      accountId: currentAccountId,
      timeframe: currentTimeframe,
    );
  }
}
}