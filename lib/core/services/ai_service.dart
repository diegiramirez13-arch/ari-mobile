import 'package:openai_dart/openai_dart.dart';

import '../config/environment.dart';

class AIService {
  late final OpenAIClient _client;
  final List<Map<String, String>> _history = [];
  static const int _maxHistory = 6;

  AIService() {
    if (Environment.isProMode) {
      _client = OpenAIClient(apiKey: Environment.openAiApiKey);
    }
  }

  bool get isAvailable => Environment.isProMode;

  Future<String> sendMessage(String message) async {
    if (!isAvailable) {
      throw Exception('Modo Pro no disponible - falta API Key');
    }

    _addToHistory('user', message);

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
            ..._history.map((h) {
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
      final result = content ?? 'No entendí, ¿podés repetir?';
      _addToHistory('assistant', result);
      return result;
    } catch (e) {
      return 'Error: $e';
    }
  }

  void _addToHistory(String role, String content) {
    _history.add({'role': role, 'content': content});
    if (_history.length > _maxHistory) {
      _history.removeAt(0);
    }
  }

  void clearHistory() => _history.clear();

  void dispose() {}
}
