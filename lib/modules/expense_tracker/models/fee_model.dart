
class FeeModel {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final DateTime createdAt;

  const FeeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'isPaid': isPaid,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FeeModel.fromMap(Map<String, dynamic> map) {
    return FeeModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      amount: (map['amount'] as num).toDouble(),
      dueDate: DateTime.parse(map['dueDate'] as String),
      isPaid: map['isPaid'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  FeeModel copyWith({
    String? title,
    String? description,
    double? amount,
    DateTime? dueDate,
    bool? isPaid,
  }) {
    return FeeModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt,
    );
  }
}
