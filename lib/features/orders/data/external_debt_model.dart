class ExternalDebt {
  final String id;
  final String source;
  final String description;
  final double amount;
  final DateTime date;
  final bool isSettled;
  final String? createdBy;
  final DateTime createdAt;

  const ExternalDebt({
    required this.id,
    required this.source,
    required this.description,
    required this.amount,
    required this.date,
    this.isSettled = false,
    this.createdBy,
    required this.createdAt,
  });

  factory ExternalDebt.fromMap(String id, Map<String, dynamic> map) {
    return ExternalDebt(
      id: id,
      source: map['source'] as String? ?? '',
      description: map['description'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: (map['date'] as dynamic)?.toDate() ?? DateTime.now(),
      isSettled: map['isSettled'] as bool? ?? false,
      createdBy: map['createdBy'] as String?,
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'source': source,
      'description': description,
      'amount': amount,
      'date': date,
      'isSettled': isSettled,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }

  ExternalDebt copyWith({
    String? id,
    String? source,
    String? description,
    double? amount,
    DateTime? date,
    bool? isSettled,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return ExternalDebt(
      id: id ?? this.id,
      source: source ?? this.source,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      isSettled: isSettled ?? this.isSettled,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
