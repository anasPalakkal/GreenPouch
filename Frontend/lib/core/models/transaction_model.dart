// lib/core/models/transaction_model.dart

class TransactionModel {
  final String id;
  final String accountId;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;      // Maps to transactedAt (User-facing calendar grouping)
  final DateTime createdAt; // Maps to exact machine timestamp (Sorting within groups)
  final String type;
  final String category;
  final String direction;
  final String accountName;
  final String? idempotencyKey;
  final String status;
  final bool isCancelled;
  final String? transferGroupId;
  final String? linkedAccountName;

  TransactionModel({
    required this.id,
    required this.accountId,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.createdAt,
    required this.type,
    required this.category,
    required this.direction,
    required this.accountName,
    this.idempotencyKey,
    required this.status,
    this.isCancelled = false,
    this.transferGroupId,
    this.linkedAccountName,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id']?.toString() ?? '',
      accountId: (json['accountId'] is Map)
          ? json['accountId']['_id']?.toString() ?? ''
          : json['accountId']?.toString() ?? '',
      title: json['category'] ?? 'General',
      subtitle: json['description'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,

      date: () {
        if (json['transactedAt'] != null) {
          return DateTime.parse(json['transactedAt'].toString()).toLocal();
        }
        if (json['createdAt'] != null) {
          return DateTime.parse(json['createdAt'].toString()).toLocal();
        }
        return DateTime.now();
      }(),

      createdAt: () {
        if (json['createdAt'] != null) {
          return DateTime.parse(json['createdAt'].toString()).toLocal();
        }
        if (json['transactedAt'] != null) {
          return DateTime.parse(json['transactedAt'].toString()).toLocal();
        }
        return DateTime.now();
      }(),

      type: (json['transactionType'] ?? 'EXPENSE').toString().toUpperCase(),
      category: json['category'] ?? 'General',
      direction: (json['direction'] ?? 'STANDARD').toString().toUpperCase(),
      accountName: (json['accountName'] ?? 'Unknown Account').toString(),
      idempotencyKey: json['idempotencyKey']?.toString(),
      status: (json['status'] ?? 'COMPLETED').toString().toUpperCase(),
      isCancelled: json['isCancelled'] == true,
      transferGroupId: json['transferGroupId']?.toString(),
      linkedAccountName: null,
    );
  }
}

class TransactionHistoryResponse {
  final int count;
  final String? nextCursor;
  final List<TransactionModel> transactions;

  TransactionHistoryResponse({
    required this.count,
    required this.nextCursor,
    required this.transactions,
  });

  factory TransactionHistoryResponse.fromJson(Map<String, dynamic> json) {
    final List dataList = json['data'] ?? [];
    return TransactionHistoryResponse(
      count: json['count'] ?? 0,
      nextCursor: json['nextCursor']?.toString(),
      transactions:
          dataList.map((item) => TransactionModel.fromJson(item)).toList(),
    );
  }
}