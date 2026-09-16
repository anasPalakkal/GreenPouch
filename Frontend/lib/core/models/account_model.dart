class AccountModel {
  final String id;
  final String name;
  final String type;
  final String availableBalance;
  final String reservedBalance;
  final String totalBalance;
  final String minBalance; // Fix #2: was missing
  final String currency;
  final bool isDefault;
  final String status;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.availableBalance,
    required this.reservedBalance,
    required this.totalBalance,
    required this.minBalance,
    required this.currency,
    required this.isDefault,
    required this.status,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? 'unknown_id',
      name: json['name'] ?? 'Unnamed Account',
      type: json['type'] ?? 'CASH',
      availableBalance: json['available']?.toString() ?? '0.00',
      reservedBalance: json['reserved']?.toString() ?? '0.00',
      totalBalance: json['total']?.toString() ?? '0.00',
      minBalance: json['minBalance']?.toString() ?? '0.00', // Fix #2
      currency: json['currency'] ?? 'INR',
      isDefault: json['isDefault'] == true, // Fix #1
      status: json['status'] ?? 'ACTIVE',
    );
  }

  // Fix #3: toJson for caching / state serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'available': availableBalance,
        'reserved': reservedBalance,
        'total': totalBalance,
        'minBalance': minBalance,
        'currency': currency,
        'isDefault': isDefault,
        'status': status,
      };

  // Fix #4: copyWith for provider state updates
  AccountModel copyWith({
    String? id,
    String? name,
    String? type,
    String? availableBalance,
    String? reservedBalance,
    String? totalBalance,
    String? minBalance,
    String? currency,
    bool? isDefault,
    String? status,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      availableBalance: availableBalance ?? this.availableBalance,
      reservedBalance: reservedBalance ?? this.reservedBalance,
      totalBalance: totalBalance ?? this.totalBalance,
      minBalance: minBalance ?? this.minBalance,
      currency: currency ?? this.currency,
      isDefault: isDefault ?? this.isDefault,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) => other is AccountModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
