import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/homework_controller.dart';
import 'chat_history_screen.dart';

import 'package:flutter_markdown/flutter_markdown.dart';

class HomeworkScreen extends StatelessWidget {
  HomeworkScreen({super.key});

  final HomeworkController controller = Get.put(HomeworkController());

  static const Color primaryColor = Color(0xFF673AB7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        title: const Text('Homework Help'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ask AI anything!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Get simple explanations for your homework questions.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: controller.questionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type your homework question here...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: Obx(
                  () => ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.askQuestion,
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(
                      controller.isLoading.value
                          ? 'Generating Answer...'
                          : 'Ask AI',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (controller.answer.value.isEmpty) {
                    return const Center(
                      child: Text(
                        'Your AI answer will appear here.',
                        style: TextStyle(color: Colors.black45),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome, color: primaryColor),
                              SizedBox(width: 8),
                              Text(
                                'AI Answer',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          MarkdownBody(
                            data: controller.answer.value,
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: Colors.black87,
                              ),
                              h1: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              h2: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                              h3: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              strong: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: controller.clearQuestion,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Ask another question'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
