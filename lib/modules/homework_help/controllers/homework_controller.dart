import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/chat_message.dart';
import '../services/homework_api_service.dart';
import '../services/chat_history_service.dart';

class HomeworkController extends GetxController {
  final HomeworkApiService _apiService = HomeworkApiService();
  final ChatHistoryService _chatHistoryService = ChatHistoryService();

  final questionController = TextEditingController();

  final isLoading = false.obs;
  final answer = ''.obs;
  final errorMessage = ''.obs;

  final currentConversationId = ''.obs;

  Future<void> askQuestion() async {
    final question = questionController.text.trim();

    if (question.isEmpty) {
      Get.snackbar(
        'Empty Question',
        'Please enter your homework question.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      answer.value = '';
      errorMessage.value = '';

      // Create a conversation for the first question.
      if (currentConversationId.value.isEmpty) {
        currentConversationId.value = await _chatHistoryService
            .createConversation(
              question.length > 50
                  ? '${question.substring(0, 50)}...'
                  : question,
            );
      }

      final conversationId = currentConversationId.value;

      // Save the user's question.
      final userMessage = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        role: 'user',
        content: question,
        createdAt: DateTime.now(),
      );

      await _chatHistoryService.saveMessage(conversationId, userMessage);

      // Get the AI response.
      final response = await _apiService.askQuestion(question);

      answer.value = response;

      // Save the AI response.
      final aiMessage = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        role: 'assistant',
        content: response,
        createdAt: DateTime.now(),
      );

      await _chatHistoryService.saveMessage(conversationId, aiMessage);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');

      debugPrint('HOMEWORK ERROR: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearQuestion() {
    questionController.clear();
    answer.value = '';
    errorMessage.value = '';
  }

  @override
  void onClose() {
    questionController.dispose();
    super.onClose();
  }
}
