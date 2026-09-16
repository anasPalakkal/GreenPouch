class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final String type;
  final String category;
  final String direction;
  final String accountName;
  final String? idempotencyKey;

  TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    required this.direction,
    required this.accountName,
    this.idempotencyKey,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id']?.toString() ?? '',
      
      // Map backend 'category' to 'title'
      title: json['category'] ?? 'General',
      
      // Map backend 'description' to 'subtitle'
      subtitle: json['description'] ?? '',
      
      // Parse Decimal128 securely
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      
      // ✅ Prioritize transactedAt and apply .toLocal() for timezone accuracy
      date: () {
        if (json['transactedAt'] != null) {
          return DateTime.parse(json['transactedAt']).toLocal();
        }
        if (json['createdAt'] != null) {
          return DateTime.parse(json['createdAt']).toLocal();
        }
        return DateTime.now();
      }(),
      
      // ✅ Enforce UPPERCASE to match the UI's switch statements
      type: (json['transactionType'] ?? 'EXPENSE').toString().toUpperCase(),
      
      // Keep raw category for filtering
      category: json['category'] ?? 'General',
      
      // ✅ Capture direction for Goal & Transfer logic
      direction: (json['direction'] ?? 'STANDARD').toString().toUpperCase(),
      
      // Capture the account name (your getHistory endpoint populates this)
      accountName: (json['accountName'] ?? 'Unknown Account').toString(),
      
      idempotencyKey: json['idempotencyKey']?.toString(),
    );
  }
}