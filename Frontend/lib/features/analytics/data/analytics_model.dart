import 'package:flutter/material.dart';
import '../../../core/utils/parse_utils.dart';

class CategoryData {
  final String name;
  final double amount;
  final double percentage;
  final Color color;

  CategoryData({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      name: json["name"]?.toString() ?? "Unknown",
      amount: toDouble(json["amount"]),
      percentage: toDouble(json["percentage"]),
      color: _parseColor(json["color"]),
    );
  }

  static Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    final clean = hex.replaceFirst('#', '');
    if (clean.length != 6 && clean.length != 8) return Colors.grey;
    return Color(int.parse('ff$clean', radix: 16));
  }
}

class AnalyticsModel {
  final String timeRange;
  final double income;
  final double expense;
  final double netSavings;
  final bool isDeficit;
  final double savingsRate;
  final double spendPercentage;
  final String healthStatus;
  final int totalTransactions;
  final List<CategoryData> categories;

  AnalyticsModel({
    required this.timeRange,
    required this.income,
    required this.expense,
    required this.netSavings,
    required this.isDeficit,
    required this.savingsRate,
    required this.spendPercentage,
    required this.healthStatus,
    required this.totalTransactions,
    required this.categories,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    final d = json["data"] ?? {};
    return AnalyticsModel(
      timeRange: d["timeRange"]?.toString() ?? "Month",
      income: toDouble(d["income"]),
      expense: toDouble(d["expense"]),
      netSavings: toDouble(d["netSavings"]),
      isDeficit: d["isDeficit"] == true,
      savingsRate: toDouble(d["savingsRate"]),
      spendPercentage: toDouble(d["spendPercentage"]),
      healthStatus: d["healthStatus"]?.toString() ?? "Healthy",
      totalTransactions: int.tryParse(d["totalTransactions"].toString()) ?? 0,
      categories: (d["categories"] is List)
          ? (d["categories"] as List)
              .map((e) => CategoryData.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  String get netSavingsFormatted {
    final formatted = _formatAmount(netSavings.abs());
    return isDeficit ? '-₹$formatted' : '₹$formatted';
  }

  String get savingsRateFormatted {
    return isDeficit
        ? '-${savingsRate.abs().toStringAsFixed(1)}%'
        : '${savingsRate.toStringAsFixed(1)}%';
  }

  double get spendPercentageClamped => spendPercentage.clamp(0.0, 100.0);

  static String _formatAmount(double v) {
    return v.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}
