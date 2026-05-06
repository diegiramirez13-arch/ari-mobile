import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/ai_response.dart';
import '../models/ai_service_config.dart';
import '../models/chat_mode.dart';
import 'ai_backend.dart';

class OpenAIBackend implements AIBackend {
  final http.Client _client = http.Client();

  @override
  String get name => 'OpenAI';

  @override
  bool get isAvailable => true;

  @override
  Future<String> generateResponse(String prompt) async {
    final response = await sendMessage(
      prompt,
      AIServiceConfig(
        apiKey: dotenv.env['OPENAI_API_KEY'],
        mode: ChatMode.pro,
      ),
    );
    return response.text;
  }

  @override
  Future<AIResponse> sendMessage(String prompt, AIServiceConfig config) async {
    if (!config.hasApiKey) {
      return AIResponse.error('API key no configurada', code: 'NO_API_KEY');
    }

    try {
      final response = await _client.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer ${config.apiKey}',
        },
        body: jsonEncode({
          'model': config.modelName ?? 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Eres ARI, asistente de productividad en español. Sé conciso y accionable.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': config.maxTokens,
          'temperature': config.temperature,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices']?[0]?['message']?['content'] ?? 'Sin respuesta';
        final tokens = data['usage']?['total_tokens'] as int?;
        return AIResponse.success(text, tokens: tokens);
      } else if (response.statusCode == 401) {
        return AIResponse.error('API key inválida', code: 'INVALID_API_KEY');
      } else {
        return AIResponse.error(
          'Error ${response.statusCode}: ${response.body}',
          code: 'API_ERROR',
        );
      }
    } catch (e) {
      return AIResponse.error('Error de conexión: $e', code: 'NETWORK_ERROR');
    }
  }

  @override
  void dispose() {
    _client.close();
  }
}
