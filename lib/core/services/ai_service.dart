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
  final AIServiceConfig config;
  OpenAIClient? _client;

  AIService({required this.config}) {
    _initializeClient();
  }

  void _initializeClient() {
    try {
      _client = OpenAIClient(apiKey: config.apiKey);
    } catch (e) {
      debugPrint('Error inicializando OpenAI: $e');
    }
  }

  String get _systemPrompt => '''
Eres ARI, Asistente de Inteligencia Aplicada. Estrategia: dividí todo en pasos chicos y accionables. Respondé en español rioplatense, directo y sin vueltas. Máximo 3 oraciones. Si detectás que el usuario quiere crear un proyecto, terminá tu respuesta con: [PROYECTO:Nombre del proyecto].
''';

  Future<AIResponse> generateResponse({
    required String userMessage,
    required List<AIMessage> history,
  }) async {
    if (_client == null) return AIResponse.error('IA no inicializada');

    try {
      final messages = <ChatCompletionMessage>[
        ChatCompletionMessage.system(content: _systemPrompt),
      ];

      final recent =
          history.length > 6 ? history.sublist(history.length - 6) : history;
      for (final msg in recent) {
        if (msg.role == 'user') {
          messages.add(
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(msg.content),
            ),
          );
        } else {
          messages.add(ChatCompletionMessage.assistant(content: msg.content));
        }
      }

      messages.add(
        ChatCompletionMessage.user(
          content: ChatCompletionUserMessageContent.string(userMessage),
        ),
      );

      final response = await _client!.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(config.model),
          messages: messages,
          temperature: config.temperature,
          maxTokens: config.maxTokens,
        ),
      );

      final text = response.choices.first.message.content ?? '';
      return AIResponse(
        text: text.replaceAll(RegExp(r'\[PROYECTO:.*?\]'), '').trim(),
        tokensUsed: response.usage?.totalTokens,
      );
    } catch (e) {
      return AIResponse.error(e.toString());
    }
  }

  bool get isAvailable => _client != null;

  void dispose() => _client?.close();
}
