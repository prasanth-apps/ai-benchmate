import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String role;
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {'role': role, 'content': content, 'createdAt': createdAt};
  }

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessage(
      id: id,
      role: map['role'] as String,
      content: map['content'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
