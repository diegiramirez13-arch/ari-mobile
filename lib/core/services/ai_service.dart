import 'package:dio/dio.dart';

enum AiProvider { openai, mistral }

class AiRequest {
  final String systemPrompt;
  final String userPrompt;
  final String? contextSummary;

  const AiRequest({
    required this.systemPrompt,
    required this.userPrompt,
    this.contextSummary,
  });
}

abstract class AiBackend {
  Future<String> generate(AiRequest request);
}

class OpenAiBackend implements AiBackend {
  final Dio _dio;
  final String? _apiKey;

  OpenAiBackend(this._dio, {String? apiKey}) : _apiKey = apiKey;

  @override
  Future<String> generate(AiRequest request) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return 'Modo Pro activo (OpenAI). Configura tu API key para respuestas inteligentes.';
    }

    final response = await _dio.post(
      'https://api.openai.com/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': request.systemPrompt},
          if (request.contextSummary != null)
            {'role': 'system', 'content': 'Resumen útil: ${request.contextSummary}'},
          {'role': 'user', 'content': request.userPrompt},
        ],
        'temperature': 0.5,
      },
    );

    final choices = response.data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      return 'No se recibió respuesta del proveedor OpenAI.';
    }

    return choices.first['message']['content'] as String? ??
        'No se recibió contenido en la respuesta.';
  }
}

class MistralBackend implements AiBackend {
  final Dio _dio;
  final String? _apiKey;

  MistralBackend(this._dio, {String? apiKey}) : _apiKey = apiKey;

  @override
  Future<String> generate(AiRequest request) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return 'Modo Pro activo (Mistral). Configura tu API key para respuestas inteligentes.';
    }

    final response = await _dio.post(
      'https://api.mistral.ai/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': 'mistral-small-latest',
        'messages': [
          {'role': 'system', 'content': request.systemPrompt},
          if (request.contextSummary != null)
            {'role': 'system', 'content': 'Resumen útil: ${request.contextSummary}'},
          {'role': 'user', 'content': request.userPrompt},
        ],
        'temperature': 0.5,
      },
    );

    final choices = response.data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      return 'No se recibió respuesta del proveedor Mistral.';
    }

    return choices.first['message']['content'] as String? ??
        'No se recibió contenido en la respuesta.';
  }
}

class AiService {
  final Map<AiProvider, AiBackend> _backends;

  AiService(this._backends);

  Future<String> generateResponse({
    required AiProvider provider,
    required AiRequest request,
  }) async {
    final backend = _backends[provider];
    if (backend == null) {
      return 'Proveedor de IA no configurado.';
    }

    return backend.generate(request);
  }

  static String ariSystemPrompt() {
    return '''Eres ARI, un asistente práctico y accionable en español.
Reglas de seguridad:
- No inventes datos personales ni afirmaciones médicas/legales definitivas.
- Si el usuario pide algo riesgoso o ilegal, rechaza con respeto y ofrece alternativa segura.
- Prioriza pasos concretos y medibles.
- Responde de forma breve, clara y empática.''';
  }
}
