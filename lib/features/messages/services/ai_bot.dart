import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Simple AI bot utility calling Hugging Face router chat completions endpoint.
/// DO NOT hardcode your real key in source; inject via runtime (e.g. remote config or edge function proxy).
class AiBot {
  AiBot({String? apiKey, String? model})
      : _apiKey = apiKey ?? (dotenv.env['HF_API_KEY'] ?? 'HF_API_KEY_PLACEHOLDER'),
        // Match the model used in the working web snippet
        _model = model ?? 'swiss-ai/Apertus-8B-Instruct-2509:publicai';

  final String _apiKey;
  final String _model;
  static const _endpoint = 'https://router.huggingface.co/v1/chat/completions';

  Future<String> reply(
    List<Map<String, String>> messages, {
    bool stream = false,
    int maxTokens = 256,
    double temperature = 0.8,
  }) async {
    final resp = await http.post(
      Uri.parse(_endpoint),
      headers: {
        // Use the same Authorization scheme as the working web code
        'Authorization': 'Bearer ' + _apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'messages': messages,
        'max_tokens': maxTokens,
        'temperature': temperature,
        'stream': stream,
      }),
    );
    if (resp.statusCode >= 400) {
      throw Exception('AI error ${resp.statusCode}: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final choices = data['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw Exception('No choices in AI response');
    }
    final msg = choices.first['message'] as Map<String, dynamic>?;
    return (msg?['content'] as String?)?.trim() ?? '';
  }

  /// Convenience helper that mirrors the web snippet prompt to suggest related courses.
  Future<String> suggestCourses({
    required String searchQuery,
    required String topResultTitle,
    required List<String> courseTitles,
  }) async {
    final messages = [
      {
        'role': 'user',
        'content':
            'Based on the search query "$searchQuery" and the top result "$topResultTitle", suggest 3 related courses from: ${courseTitles.join(', ')}'
      }
    ];
    return reply(messages, stream: false);
  }
}
