
class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String type;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  // Cash, Bank, or Record Only
  final String paymentSource;

  // Whether this transaction changed an available balance
  final bool affectsBalance;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.description,
    required this.date,
    required this.createdAt,
    this.paymentSource = 'Record Only',
    this.affectsBalance = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'paymentSource': paymentSource,
      'affectsBalance': affectsBalance,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      type: map['type'] as String,
      description: map['description'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      paymentSource: map['paymentSource'] as String? ?? 'Record Only',
      affectsBalance: map['affectsBalance'] as bool? ?? false,
    );
  }
}
