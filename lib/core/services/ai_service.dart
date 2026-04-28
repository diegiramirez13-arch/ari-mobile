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
  OpenAIClient? _client;
  final List<Map<String, String>> _history = [];
  static const int _maxHistory = 6;

  AIService() {
    if (AppEnvironment.isProMode) {
      _client = OpenAIClient(apiKey: AppEnvironment.openAIApiKey);
    }
  }

  bool get isAvailable => AppEnvironment.isProMode;

  Future<String> generateResponse(
    String message, {
    List<Map<String, String>> history = const [],
  }) async {
    if (!isAvailable) {
      return 'El modo Pro no está configurado. Por favor, verificá tu API Key.';
    }
  }

  String get _systemPrompt => '''
Eres ARI, Asistente de Inteligencia Aplicada. Estrategia: dividí todo en pasos chicos y accionables. Respondé en español rioplatense, directo y sin vueltas. Máximo 3 oraciones. Si detectás que el usuario quiere crear un proyecto, terminá tu respuesta con: [PROYECTO:Nombre del proyecto].
''';

    try {
      final response = await _client!.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId('gpt-4o-mini'),
          messages: [
            const ChatCompletionMessage.system(
              content: 'Sos ARI, un asistente de productividad. '
                  'Respondé en español rioplatense, máximo 3 oraciones, '
                  'de forma directa y útil.',
            ),
            ...history.map((h) {
              final role = h['role']!;
              final content = h['content']!;
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

      final content = response.choices.first.message.content;
      return content ?? 'No entendí, ¿podés repetir?';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> sendMessage(String message) => generateResponse(message);

  void clearHistory() {}

  void dispose() {
    _client?.close();
  }
}
