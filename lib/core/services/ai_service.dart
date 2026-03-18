import 'package:openai_dart/openai_dart.dart';

import '../config/environment.dart';

class AIService {
  static const String _systemPrompt =
      'Sos ARI, Asistente de Inteligencia Aplicada. '
      'PRINCIPIO: Acción > Charla. '
      'Si el usuario expresa que quiere crear o empezar un proyecto, plan o tarea importante, '
      'debés incluir al final de tu respuesta el tag: [ACTION:CREATE_PROJECT:Nombre del Proyecto]. '
      'Ejemplo: "¡Excelente idea! Te ayudo a organizarlo. [ACTION:CREATE_PROJECT:Aprender Flutter]" '
      'Respondé siempre en español rioplatense, breve y al punto.';

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
            const ChatCompletionMessage.system(content: _systemPrompt),
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
          'No pude procesar la acción.';
    } catch (e) {
      return 'Error en el motor de ARI Pro: $e';
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
