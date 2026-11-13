import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class HomeworkApiService {
  static const String baseUrl = 'https://ai-benchmate.onrender.com';

  Future<String> askQuestion(
    String question, {
    List<Map<String, String>> conversationHistory = const [],
  }) async {
    try {
      // Get the authenticated Firebase user.
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Please log in to use AI Mate.');
      }

      // Obtain Firebase ID token.
      final idToken = await user.getIdToken();

      if (idToken == null) {
        throw Exception('Authentication failed. Please log in again.');
      }

      // Prepare request with conversation context.
      final requestBody = {
        'question': question,
        'conversation_history': conversationHistory,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/homework/ask'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 120));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['answer'] as String;
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Session expired. Please log in again.');
      }

      if (response.statusCode == 422) {
        throw Exception('Invalid question or conversation data.');
      }

      if (response.statusCode == 429) {
        throw Exception(
          'You have reached your AI request limit. Please try again shortly.',
        );
      }

      if (response.statusCode == 503) {
        throw Exception('AI is temporarily unavailable. Please try again.');
      }

      throw Exception('Unable to process your question. Please try again.');
    } on http.ClientException {
      throw Exception('Cannot connect to the AI server. Please try again.');
    } on FormatException {
      throw Exception('Invalid response from the AI server.');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception('Something went wrong. Please try again.');
    }
  }
}
