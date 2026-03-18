import 'package:openai_dart/openai_dart.dart';

import '../config/environment.dart';

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
