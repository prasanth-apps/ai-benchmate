import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/homework_api_service.dart';

class HomeworkController extends GetxController {
  final HomeworkApiService _apiService = HomeworkApiService();

  final questionController = TextEditingController();

  final isLoading = false.obs;
  final answer = ''.obs;
  final errorMessage = ''.obs;

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

      final response = await _apiService.askQuestion(question);

      answer.value = response;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');

      debugPrint('HOMEWORK API ERROR: $e');
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
