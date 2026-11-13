import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/chat_message.dart';
import '../services/homework_api_service.dart';
import '../services/chat_history_service.dart';

class HomeworkController extends GetxController {
  final HomeworkApiService _apiService = HomeworkApiService();
  final ChatHistoryService _chatHistoryService = ChatHistoryService();

  final questionController = TextEditingController();

  // Conversation messages displayed in the chat interface.
  final messages = <ChatMessage>[].obs;

  final isLoading = false.obs;
  final answer = ''.obs;
  final errorMessage = ''.obs;

  final currentConversationId = ''.obs;

  Future<void> askQuestion() async {
    final question = questionController.text.trim();

    if (question.isEmpty) {
      Get.snackbar(
        'Empty Question',
        'Please enter your question.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isLoading.value) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      answer.value = '';

      // Create a new conversation if necessary.
      if (currentConversationId.value.isEmpty) {
        currentConversationId.value = await _chatHistoryService
            .createConversation(
              question.length > 50
                  ? '${question.substring(0, 50)}...'
                  : question,
            );
      }

      final conversationId = currentConversationId.value;

      // Create the user's message.
      final userMessage = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        role: 'user',
        content: question,
        createdAt: DateTime.now(),
      );

      // Display immediately in the chat.
      messages.add(userMessage);
      questionController.clear();

      // Save the question to Firestore.
      await _chatHistoryService.saveMessage(conversationId, userMessage);

      // Request the AI response.
      final conversationHistory = messages
          .where((message) => message.id != userMessage.id)
          .map((message) => {'role': message.role, 'content': message.content})
          .toList();

      final response = await _apiService.askQuestion(
        question,
        conversationHistory: conversationHistory,
      );

      answer.value = response;

      // Create the AI message.
      final aiMessage = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        role: 'assistant',
        content: response,
        createdAt: DateTime.now(),
      );

      // Display the AI response.
      messages.add(aiMessage);

      // Save the AI response to Firestore.
      await _chatHistoryService.saveMessage(conversationId, aiMessage);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');

      debugPrint('AI MATE ERROR: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Clears the current answer without starting another conversation.
  void clearQuestion() {
    questionController.clear();
    answer.value = '';
    errorMessage.value = '';
  }

  // Starts a completely new conversation.
  void startNewChat() {
    if (isLoading.value) {
      Get.snackbar(
        'Please wait',
        'The current question is still being processed.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    currentConversationId.value = '';
    questionController.clear();

    messages.clear();
    answer.value = '';
    errorMessage.value = '';

    Get.snackbar(
      'New Chat',
      'Started a new conversation.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    questionController.dispose();
    super.onClose();
  }
}
