import 'package:openai_dart/openai_dart.dart';

import '../config/environment.dart';
import '../models/chat_config.dart';

class AIService {
  final ChatConfig _config;
  OpenAIClient? _client;
  final List<Map<String, String>> _history = [];
  static const int _maxHistory = 6;

  AIService(this._config) {
    if (_config.isProMode) {
      _client = OpenAIClient(apiKey: Environment.openAiApiKey);
    }
  }

  bool get isAvailable => _client != null;

  Future<String> sendMessage(String message) async {
    if (!isAvailable) {
      return _basicResponse(message);
    }

    _addToHistory('user', message);

    try {
      final response = await _client!.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(_config.model),
          messages: [
            const ChatCompletionMessage.system(
              content: 'Sos ARI, asistente de productividad. '
                  'Respondé en español rioplatense, máximo 3 oraciones.',
            ),
            ..._history.map(
              (h) => ChatCompletionMessage.user(
                content: ChatCompletionUserMessageContent.string(h['content']!),
              ),
            ),
          ],
          temperature: _config.temperature,
          maxTokens: _config.maxTokens,
        ),
      );

      final content = response.choices.first.message.content;
      final reply = content ?? 'No entendí, ¿podés repetir?';

      _addToHistory('assistant', reply);
      return reply;
    } catch (e) {
      return 'Error: $e';
    }
  }

  String _basicResponse(String message) {
    return 'Modo básico activo. Recibí: "$message"\n'
        'Configurá OPENAI_API_KEY para respuestas con IA.';
  }

  void _addToHistory(String role, String content) {
    _history.add({'role': role, 'content': content});
    if (_history.length > _maxHistory) {
      _history.removeAt(0);
    }
  }

  void clearHistory() => _history.clear();

  void dispose() => _client?.close();
}
