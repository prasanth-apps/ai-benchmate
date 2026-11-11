import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/chat_message.dart';
import '../services/chat_history_service.dart';

class ChatDetailScreen extends StatelessWidget {
  final String conversationId;
  final String title;

  ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.title,
  });

  final ChatHistoryService _service = ChatHistoryService();

  static const Color primaryColor = Color(0xFF673AB7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: StreamBuilder<List<ChatMessage>>(
        stream: _service.getMessages(conversationId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load messages.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          final messages = snapshot.data ?? [];

          if (messages.isEmpty) {
            return const Center(
              child: Text('No messages in this conversation.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isUser = message.role == 'user';

              return Align(
                alignment: isUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85,
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser ? primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: isUser
                      ? Text(
                          message.content,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        )
                      : MarkdownBody(
                          data: message.content,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              height: 1.5,
                            ),
                            strong: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
