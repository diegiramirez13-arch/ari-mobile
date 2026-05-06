import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ai_response.dart';
import '../models/ai_service_config.dart';
import 'ai_backend.dart';

class GeminiBackend implements AIBackend {
  final http.Client _client = http.Client();

  @override
  String get name => 'Google Gemini';

  @override
  bool get isAvailable => true;

  @override
  Future<String> generateResponse(String prompt) async {
    final response = await sendMessage(prompt, const AIServiceConfig());
    return response.text;
  }

  @override
  Future<AIResponse> sendMessage(String prompt, AIServiceConfig config) async {
    if (!config.hasApiKey) {
      return AIResponse.error(
        'API key de Gemini no configurada',
        code: 'NO_API_KEY',
      );
    }

    try {
      final response = await _client.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${config.apiKey}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'Eres ARI, asistente de productividad en español. Sé conciso.\n\nUsuario: $prompt',
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': config.temperature,
            'maxOutputTokens': config.maxTokens,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
            'Sin respuesta';
        return AIResponse.success(text);
      } else {
        return AIResponse.error(
          'Error Gemini ${response.statusCode}: ${response.body}',
          code: 'GEMINI_ERROR',
        );
      }
    } catch (e) {
      return AIResponse.error(
        'Error de conexión Gemini: $e',
        code: 'NETWORK_ERROR',
      );
    }
  }

  @override
  void dispose() {
    _client.close();
  }
}
