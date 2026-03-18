import 'package:openai_dart/openai_dart.dart';

import '../config/environment.dart';

class AIService {
  late final OpenAIClient _client;

  AIService() {
    if (isAvailable) {
      _client = OpenAIClient(apiKey: Environment.openAiApiKey);
    }
  }

  bool get isAvailable => Environment.isProMode;

  Future<String> generateResponse(List<Map<String, String>> history) async {
    if (!isAvailable) {
      return 'Modo Pro no disponible. Configurá OPENAI_API_KEY para activar ARI Pro.';
    }

    try {
      final response = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId('gpt-4o-mini'),
          messages: [
            const ChatCompletionMessage.system(
              content: 'Sos ARI, un Asistente de Inteligencia Aplicada experto '
                  'en productividad. Tu objetivo es ayudar a planificar y '
                  'ejecutar acciones concretas. Respondé en español '
                  'rioplatense, de forma breve y siempre orientada a la acción.',
            ),
            ...history.map((message) {
              final role = message['role'] ?? 'user';
              final content = message['content'] ?? '';
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
          'No pude generar una respuesta.';
    } catch (e) {
      return 'Error de conexión con el motor de ARI Pro: $e';
    }
  }

  Future<String> sendMessage(String message) {
    return generateResponse([
      {'role': 'user', 'content': message},
    ]);
  }

  void clearHistory() {}

  void dispose() {
    if (isAvailable) {
      _client.close();
    }
  }
}
