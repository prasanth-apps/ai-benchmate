import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/chat_history_service.dart';
import 'chat_detail_screen.dart';

class ChatHistoryScreen extends StatelessWidget {
  ChatHistoryScreen({super.key});

  final ChatHistoryService _service = ChatHistoryService();

  static const Color primaryColor = Color(0xFF673AB7);

  String formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Just now';

    final date = (timestamp as Timestamp).toDate();
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }

    if (date.year == now.year) {
      return '${date.day}/${date.month}';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  void openConversation(
    BuildContext context,
    String conversationId,
    String title,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChatDetailScreen(conversationId: conversationId, title: title),
      ),
    );
  }

  Future<void> confirmDelete(
    BuildContext context,
    String conversationId,
    String title,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete conversation?'),
          content: Text(
            'Are you sure you want to delete "$title"? '
            'This will permanently delete all its messages.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _service.deleteConversation(conversationId);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversation deleted successfully.')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete conversation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        title: const Text('Chat History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _service.getConversations(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load chat history.',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          final conversations = snapshot.data?.docs ?? [];

          if (conversations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 60, color: Colors.black26),
                  SizedBox(height: 16),
                  Text(
                    'No chat history yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your previous conversations will appear here.',
                    style: TextStyle(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: conversations.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final document = conversations[index];
              final conversation = document.data();

              final title =
                  conversation['title'] as String? ?? 'Untitled conversation';

              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEDE7F6),
                    child: Icon(Icons.chat_bubble_outline, color: primaryColor),
                  ),
                  title: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      formatDate(conversation['updatedAt']),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        confirmDelete(context, document.id, title);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    openConversation(context, document.id, title);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
