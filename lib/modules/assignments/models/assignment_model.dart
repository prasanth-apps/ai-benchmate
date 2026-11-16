class AssignmentModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final DateTime dueDate;
  final String priority;
  final bool isCompleted;
  final DateTime createdAt;

  const AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    required this.createdAt,
  });

  // Convert assignment object into a Map for local storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert stored Map back into an assignment object.
  factory AssignmentModel.fromMap(Map<String, dynamic> map) {
    return AssignmentModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      subject: map['subject'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      priority: map['priority'] as String,
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // Create an updated copy without changing the original object.
  AssignmentModel copyWith({
    String? title,
    String? description,
    String? subject,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
  }) {
    return AssignmentModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}
