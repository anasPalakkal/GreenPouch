class GlobalSummary {
  final String totalAvailable;
  final String totalReserved;
  final String netWorth;

  GlobalSummary({
    required this.totalAvailable,
    required this.totalReserved,
    required this.netWorth,
  });

  factory GlobalSummary.fromJson(Map<String, dynamic> json) {
    return GlobalSummary(
      totalAvailable: json['totalAvailable'] ?? "0.00",
      totalReserved: json['totalReserved'] ?? "0.00",
      netWorth: json['netWorth'] ?? "0.00",
    );
  }
}