class GoalModel {
  final String id;

  /// Basic Info
  String title;
  String category;

  /// Money
  double targetAmount;
  double currentAmount;

  /// Dates
  DateTime targetDate;
  DateTime createdAt;

  /// Status
  String status;

  /// Optional
  String? description;
  String reminderFrequency;
  String transactionType;

  /// Backend calculated fields
  final int? daysLeft;
  final double? requiredDailySaving;
  final double? progressPercentage;
  final bool isOverdue;

  GoalModel({
    required this.id,
    required this.title,
    required this.category,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.createdAt,
    required this.status,
    this.description,
    this.reminderFrequency = 'weekly',
    this.transactionType = 'expense',
    this.daysLeft,
    this.requiredDailySaving,
    this.progressPercentage,
    this.isOverdue = false,
  });

  /// ✅ FROM JSON
  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',

      targetAmount: (json['targetAmount'] as num? ?? 0).toDouble(),
      currentAmount: (json['currentAmount'] as num? ?? 0).toDouble(),

      // ✅ Enforce local timezones
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'].toString()).toLocal()
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString()).toLocal()
          : DateTime.now(),

      status: json['status'] ?? 'active',
      description: json['description'],
      reminderFrequency: json['reminderFrequency'] ?? 'weekly',
      transactionType: json['transactionType'] ?? 'expense',

      // Allow mapping from either backend naming convention
      daysLeft: (json['daysLeft'] ?? json['remainingDays']) != null
          ? ((json['daysLeft'] ?? json['remainingDays']) as num).toInt()
          : null,

      requiredDailySaving: json['requiredDailySaving'] != null
          ? (json['requiredDailySaving'] as num).toDouble()
          : null,

      progressPercentage: json['progressPercentage'] != null
          ? (json['progressPercentage'] as num).toDouble()
          : null,

      isOverdue: json['isOverdue'] ?? false,
    );
  }

  /// ✅ TO JSON (for create/update)
  Map<String, dynamic> toJson({bool isCreate = false}) {
    return {
      if (!isCreate && id.isNotEmpty) "_id": id,
      "title": title,
      "category": category,
      "targetAmount": targetAmount,
      "currentAmount": currentAmount,
      "status": status,
      "targetDate": targetDate.toIso8601String(),
      if (description != null && description!.isNotEmpty)
        "description": description,
      "reminderFrequency": reminderFrequency,
      "transactionType": transactionType,
    };
  }

  // ✅ Helper method to calculate progress dynamically if the backend doesn't send it
  double get progress => progressPercentage != null && progressPercentage! > 0
      ? (progressPercentage! / 100).clamp(0.0, 1.0)
      : (targetAmount == 0
          ? 0
          : (currentAmount / targetAmount).clamp(0.0, 1.0));
}