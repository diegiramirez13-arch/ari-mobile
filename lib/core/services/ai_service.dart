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
  final OpenAIClient? _client;

  // Única definición del system prompt.
  static const String _systemPrompt =
      'Sos ARI (Asistente de Inteligencia Aplicada). Filosofía: Acción > Charla. '
      'Respuestas cortas, técnicas y orientadas a la ejecución. '
      'Creado en Villa María, Córdoba, Argentina.';

  AIService({String? apiKey})
      : _client = (apiKey != null && apiKey.isNotEmpty)
            ? OpenAIClient(apiKey: apiKey)
            : null;

  bool get isAvailable => _client != null;

  Future<String> generateResponse(String message) async {
    if (!isAvailable) {
      if (message.toLowerCase().contains('proyecto')) {
        return 'Smart Roadmap generado: Iniciando estructura local...';
      }
      return 'Entendido. Procesando en modo Core (Local).';
    }

    try {
      final res = await _client!.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId('gpt-4o-mini'),
          messages: [
            const ChatCompletionMessage.system(content: _systemPrompt),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(message),
            ),
          ],
          temperature: 0.7,
        ),
      );

      return res.choices.first.message.content ?? 'Sin respuesta de ARI Pro.';
    } catch (_) {
      return 'Error de red: No se pudo conectar con la Inteligencia Híbrida.';
    }
  }

  Future<String> sendMessage(String message) => generateResponse(message);

  void clearHistory() {}

  void dispose() {
    _client?.close();
  }
}
