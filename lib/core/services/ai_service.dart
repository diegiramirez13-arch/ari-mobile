import 'package:openai_dart/openai_dart.dart';

import '../config/environment.dart';

class AIService {
  late final OpenAIClient _client;

  AIService() {
    if (Environment.isProMode) {
      _client = OpenAIClient(apiKey: Environment.openAiApiKey);
    }
  }

  bool get isAvailable => Environment.isProMode;

  Future<String> generateResponse(
    String message, {
    List<Map<String, String>> history = const [],
  }) async {
    if (!isAvailable) {
      throw Exception('Modo Pro no disponible - falta API Key');
    }

    try {
      final response = await _client.createChatCompletion(
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

  void dispose() {}
}
