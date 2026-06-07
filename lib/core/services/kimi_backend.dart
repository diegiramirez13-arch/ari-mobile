import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/cloud_secrets.dart';
import '../models/ai_response.dart';
import '../models/ai_service_config.dart';
import 'ai_backend.dart';

/// Moonshot Kimi backend using its OpenAI-compatible chat completions API.
///
/// This backend is only intended for development/offline fallback scenarios
/// where a `KIMI_API_KEY` is explicitly provided to the mobile runtime. In
/// production, provider keys should remain server-side behind Cloud Run.
class KimiBackend implements AIBackend {
  KimiBackend({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _endpoint = 'https://api.moonshot.ai/v1/chat/completions';
  static const String _defaultModel = 'moonshot-v1-8k';

  @override
  String get name => 'Kimi Moonshot';

  @override
  bool get isAvailable => true;

  @override
  Future<String> generateResponse(String prompt) async {
    final response = await sendMessage(
      prompt,
      AIServiceConfig(
        apiKey: CloudSecrets.kimiKey,
        modelName: _defaultModel,
      ),
    );
    return response.text;
  }

  @override
  Future<AIResponse> sendMessage(String prompt, AIServiceConfig config) async {
    if (!config.hasApiKey) {
      return AIResponse.error(
        'API key de Kimi no configurada',
        code: 'NO_API_KEY',
        metadata: {'backend': name},
      );
    }

    try {
      final response = await _client.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer ${config.apiKey}',
        },
        body: jsonEncode({
          'model': config.modelName ?? _defaultModel,
          'messages': [
            {
              'role': 'system',
              'content':
                  'Eres ARI, asistente de productividad en español. '
                  'Sé conciso, técnico y accionable.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': config.maxTokens,
          'temperature': config.temperature,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        final firstChoice = choices?.isNotEmpty == true
            ? choices!.first as Map<String, dynamic>
            : null;
        final message = firstChoice?['message'] as Map<String, dynamic>?;
        final text = message?['content'] as String? ?? 'Sin respuesta';
        final usage = data['usage'] as Map<String, dynamic>?;
        final tokens = usage?['total_tokens'] as int?;

        return AIResponse.success(
          text,
          tokens: tokens,
          metadata: {
            'backend': name,
            'model': config.modelName ?? _defaultModel,
          },
        );
      }

      if (response.statusCode == 401) {
        return AIResponse.error(
          'API key de Kimi inválida',
          code: 'INVALID_API_KEY',
          metadata: {'backend': name},
        );
      }

      return AIResponse.error(
        'Error Kimi ${response.statusCode}: ${response.body}',
        code: 'KIMI_ERROR',
        metadata: {'backend': name},
      );
    } catch (error) {
      return AIResponse.error(
        'Error de conexión Kimi: $error',
        code: 'NETWORK_ERROR',
        metadata: {'backend': name},
      );
    }
  }

  @override
  void dispose() {
    _client.close();
  }
}
