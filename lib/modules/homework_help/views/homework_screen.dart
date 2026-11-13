import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../controllers/homework_controller.dart';
import 'chat_history_screen.dart';

class HomeworkScreen extends StatelessWidget {
  HomeworkScreen({super.key});

  final HomeworkController controller = Get.put(HomeworkController());

  static const Color primaryColor = Color(0xFF673AB7);
  static const Color backgroundColor = Color(0xFFF8F7FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        title: const Text(
          'AI Mate',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'New Chat',
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: controller.startNewChat,
          ),
          IconButton(
            tooltip: 'Chat History',
            icon: const Icon(Icons.history),
            onPressed: () {
              Get.to(() => ChatHistoryScreen());
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Chat messages
            Expanded(
              child: Obx(() {
                final messages = controller.messages.reversed.toList();

                if (messages.isEmpty &&
                    !controller.isLoading.value &&
                    controller.errorMessage.value.isEmpty) {
                  return _buildWelcomeScreen();
                }

                final showLoading = controller.isLoading.value;
                final showError = controller.errorMessage.value.isNotEmpty;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      messages.length +
                      (showLoading ? 1 : 0) +
                      (showError ? 1 : 0),
                  itemBuilder: (context, index) {
                    var messageIndex = index;

                    // Latest loading indicator
                    if (showLoading && index == 0) {
                      return _buildTypingIndicator();
                    }

                    if (showLoading) {
                      messageIndex--;
                    }

                    // Latest error message
                    if (showError && messageIndex == 0) {
                      return _buildErrorMessage(controller.errorMessage.value);
                    }

                    if (showError) {
                      messageIndex--;
                    }

                    final message = messages[messageIndex];

                    return _buildMessageBubble(
                      message.content,
                      message.role == 'user',
                    );
                  },
                );
              }),
            ),

            // Bottom message input
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  // Welcome screen
  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: primaryColor,
                size: 36,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'What would you like to learn today?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF251442),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Ask homework questions, understand concepts, '
              'create revision notes, summarise chapters '
              'or practise for exams.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Individual message bubble

  Widget _buildMessageBubble(String content, bool isUser) {
    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          margin: const EdgeInsets.only(bottom: 18, left: 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: SelectableText(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: MarkdownBody(
        data: content,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(fontSize: 15, height: 1.7, color: Colors.black87),
          h1: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
          h2: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
          h3: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
          strong: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          listBullet: const TextStyle(fontSize: 15, height: 1.7),
          code: const TextStyle(
            fontSize: 13,
            backgroundColor: Color(0xFFECE8F2),
          ),
        ),
      ),
    );
  }

  // AI thinking indicator
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: primaryColor,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'AI Mate is thinking...',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // Error message
  Widget _buildErrorMessage(String error) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(error, style: const TextStyle(color: Colors.red)),
    );
  }

  // Bottom input area
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFECE8F2))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller.questionController,
              minLines: 1,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) {
                if (!controller.isLoading.value) {
                  controller.askQuestion();
                }
              },
              decoration: InputDecoration(
                hintText: 'Ask AI Mate anything...',
                filled: true,
                fillColor: backgroundColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          Obx(
            () => IconButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.askQuestion,
              style: IconButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.all(13),
              ),
              icon: const Icon(Icons.send_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
