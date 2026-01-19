class Transaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final TransactionType type;
  final DateTime timestamp;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.timestamp,
  });

  // Create a copy with modifications
  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    TransactionType? type,
    DateTime? timestamp,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

enum TransactionType { income, expense }

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    return this == TransactionType.income ? 'Income' : 'Expense';
  }

  bool get isIncome {
    return this == TransactionType.income;
  }
}
