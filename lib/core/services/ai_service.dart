import 'package:openai_dart/openai_dart.dart';

class AIService {
  final OpenAIClient? _client;

  // ÚNICA definición del system prompt (Fix para compilación)
  static const String _systemPrompt =
      "Sos ARI (Asistente de Inteligencia Aplicada). Filosofía: Acción > Charla. "
      "Respuestas cortas, técnicas y orientadas a la ejecución. "
      "Creado en Villa María, Córdoba, Argentina.";

  AIService({String? apiKey})
      : _client = (apiKey != null && apiKey.isNotEmpty)
            ? OpenAIClient(apiKey: apiKey)
            : null;

  // Valida si la API Key fue inyectada correctamente
  bool get isAvailable => _client != null;

  // Flujo lineal y cerrado para generar respuesta
  Future<String> generateResponse(String message) async {
    if (!isAvailable) {
      // Fallback determinista (Modo Básico)
      if (message.toLowerCase().contains('proyecto')) {
        return 'Smart Roadmap generado: Iniciando estructura local...';
      }
      return 'Entendido. Procesando en modo Core (Local).';
    }

    try {
      final res = await _client!.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: const ChatCompletionModel.model(ChatCompletionModels.gpt4oMini),
          messages: [
            const ChatCompletionMessage.system(content: _systemPrompt),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(message),
            ),
          ],
          temperature: 0.7,
        ),
      );
      return res.choices.first.message.content ?? "Sin respuesta de ARI Pro.";
    } catch (e) {
      return "Error de red: No se pudo conectar con la Inteligencia Híbrida.";
    }
  }
}
