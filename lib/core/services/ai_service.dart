import 'package:openai_dart/openai_dart.dart';

import '../config/environment.dart';
import '../models/chat_config.dart';

class AIService {
  final OpenAIClient? _client;
  final ChatConfig _config;
  final List<Map<String, dynamic>> _history = [];
  static const int _maxHistory = 6;

  AIService(this._config)
      : _client = _config.isProMode
            ? OpenAIClient(apiKey: Environment.openAiApiKey)
            : null;

  bool get isAvailable => _config.isProMode && _client != null;

  Future<String> sendMessage(String message) async {
    if (!_config.isProMode) {
      return _basicResponse(message);
    }

    _addToHistory('user', message);

    try {
      final response = await _client!.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(_config.model),
          messages: [
            const ChatCompletionMessage.system(
              content: 'Sos ARI, un asistente de productividad. '
                  'Respondé en español rioplatense, máximo 3 oraciones, '
                  'de forma directa y útil.',
            ),
            ..._history.map((h) {
              final role = h['role'] as String;
              final content = h['content'] as String;
              if (role == 'assistant') {
                return ChatCompletionMessage.assistant(content: content);
              }
              return ChatCompletionMessage.user(
                content: ChatCompletionUserMessageContent.string(content),
              );
            }),
          ],
          temperature: _config.temperature,
          maxTokens: _config.maxTokens,
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

  String _basicResponse(String userText) {
    final lower = userText.toLowerCase();
    if (lower.contains('hola') || lower.contains('buenas')) {
      return '¡Hola! Estoy en modo básico. Configurá OPENAI_API_KEY para activar Pro.';
    }
    return 'Modo básico activo. Configurá OPENAI_API_KEY para usar IA.';
  }

  void _addToHistory(String role, String content) {
    _history.add({'role': role, 'content': content});
    if (_history.length > _maxHistory) {
      _history.removeAt(0);
    }
  }

  void clearHistory() => _history.clear();

  void dispose() {
    _client?.close();
  }
}
