import 'dart:convert';

import 'package:http/http.dart' as http;

class HomeworkApiService {
  // Android emulator connects to the Windows PC through this address.
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<String> askQuestion(String question) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/homework/ask'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'question': question}),
          )
          .timeout(const Duration(seconds: 120));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['answer'] as String;
      }

      if (response.statusCode == 422) {
        throw Exception('Please enter a question with at least 3 characters.');
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
