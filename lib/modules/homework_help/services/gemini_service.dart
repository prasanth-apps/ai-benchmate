import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';

class GeminiService {
  final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-3.8-flash',
    generationConfig: GenerationConfig(maxOutputTokens: 800, temperature: 0.4),
    systemInstruction: Content.text(
      'You are AI BenchMate, a helpful study assistant. '
      'Explain academic questions in simple language. '
      'Use short headings, examples and bullet points when useful. '
      'Keep answers clear and concise.',
    ),
  );

  Future<String> askQuestion(String question) async {
    try {
      final response = await _model
          .generateContent([Content.text(question)])
          .timeout(const Duration(seconds: 60));

      return response.text ?? 'Sorry, I could not generate a response.';
    } on TimeoutException {
      throw Exception('Gemini is taking too long. Please try again.');
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }
}
