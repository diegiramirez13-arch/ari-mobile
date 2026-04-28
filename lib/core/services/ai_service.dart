import 'package:flutter/foundation.dart';
import 'package:openai_dart/openai_dart.dart';

enum AIProvider { openAI, mistral }

class AIServiceConfig {
  final String apiKey;
  final AIProvider provider;
  final String model;
  final double temperature;
  final int maxTokens;

  const AIServiceConfig({
    required this.apiKey,
    this.provider = AIProvider.openAI,
    this.model = 'gpt-4o-mini',
    this.temperature = 0.7,
    this.maxTokens = 1000,
  });
}

class AIMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  AIMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };
}

class AIResponse {
  final String text;
  final bool isError;
  final String? errorMessage;
  final int? tokensUsed;

  AIResponse({
    required this.text,
    this.isError = false,
    this.errorMessage,
    this.tokensUsed,
  });

  factory AIResponse.error(String message) => AIResponse(
        text: 'Lo siento, hubo un error. ¿Podés intentar de nuevo?',
        isError: true,
        errorMessage: message,
      );
}

class AIService {
  static const String _systemPrompt =
      'Sos ARI, Asistente de Inteligencia Aplicada. '
      'PRINCIPIO: Acción > Charla. '
      'Si el usuario quiere iniciar un proyecto, incluí al final: '
      '[ACTION:CREATE_PROJECT:Nombre]. '
      'Respondé en español rioplatense, breve y al punto.';

  late final OpenAIClient _client;

  AIService() {
    if (Environment.openAiApiKey.isNotEmpty) {
      _client = OpenAIClient(apiKey: Environment.openAiApiKey);
    }
  }

  Future<String> generateResponse(List<Map<String, String>> history) async {
    if (Environment.openAiApiKey.isEmpty) {
      return 'Error: No se detectó la llave de ARI Pro. Verificá tu configuración.';
    }
  }

  String get _systemPrompt => '''
Eres ARI, Asistente de Inteligencia Aplicada. Estrategia: dividí todo en pasos chicos y accionables. Respondé en español rioplatense, directo y sin vueltas. Máximo 3 oraciones. Si detectás que el usuario quiere crear un proyecto, terminá tu respuesta con: [PROYECTO:Nombre del proyecto].
''';

    try {
      final response = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId('gpt-4o-mini'),
          messages: [
            const ChatCompletionMessage.system(content: _systemPrompt),
            ...history.map((msg) {
              final role = msg['role'] ?? 'user';
              final content = msg['content'] ?? '';
              if (role == 'assistant') {
                return ChatCompletionMessage.assistant(content: content);
              }
              return ChatCompletionMessage.user(
                content: ChatCompletionUserMessageContent.string(content),
              );
            }),
          ],
          temperature: 0.7,
          maxTokens: 1000,
        ),
      );

      return response.choices.first.message.content ??
          'ARI no pudo procesar la idea.';
    } on OpenAIClientException catch (e) {
      return 'Fallo en la conexión Pro: ${e.message}';
    } catch (e) {
      return 'Error inesperado en el motor: $e';
    }
  }

  Future<String> sendMessage(String message) {
    return generateResponse([
      {'role': 'user', 'content': message},
    ]);
  }

  void clearHistory() {}

  void dispose() {
    if (Environment.openAiApiKey.isNotEmpty) {
      _client.close();
    }
  }
}
