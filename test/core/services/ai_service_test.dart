import 'package:ari_mobile/core/services/ai_service.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AIService', () {
    test('debe inicializarse con API key válida', () {
      const config = AIServiceConfig(apiKey: 'test-key');
      final service = AIService(config: config);

      expect(service.isAvailable, true);
      service.dispose();
    });

    test('debe fallar sin API key', () {
      const config = AIServiceConfig(apiKey: '');
      final service = AIService(config: config);

      expect(service.isAvailable, false);
    });

    test('no duplica el último mensaje de usuario cuando ya está en history', () {
      final messages = AIService.buildMessagesForRequest(
        history: [
          AIMessage(role: 'assistant', content: 'Hola, ¿en qué te ayudo?'),
          AIMessage(role: 'user', content: 'Necesito organizar tareas'),
        ],
        userMessage: 'Necesito organizar tareas',
        systemPrompt: 'system prompt',
      );

      final userMessages =
          messages.whereType<ChatCompletionUserMessage>().toList();
      expect(userMessages.length, 1);
    });

    test('no duplica cuando solo difiere whitespace del último user message', () {
      final messages = AIService.buildMessagesForRequest(
        history: [
          AIMessage(role: 'assistant', content: 'Dale, contame más'),
          AIMessage(role: 'user', content: 'Necesito organizar tareas'),
        ],
        userMessage: '  Necesito organizar tareas  ',
        systemPrompt: 'system prompt',
      );

      final userMessages =
          messages.whereType<ChatCompletionUserMessage>().toList();
      expect(userMessages.length, 1);
    });

    test('agrega userMessage cuando el último history no coincide', () {
      final messages = AIService.buildMessagesForRequest(
        history: [
          AIMessage(role: 'assistant', content: 'Hola, ¿en qué te ayudo?'),
          AIMessage(role: 'user', content: 'Necesito organizar tareas'),
        ],
        userMessage: 'Quiero priorizar pendientes',
        systemPrompt: 'system prompt',
      );

      final userMessages =
          messages.whereType<ChatCompletionUserMessage>().toList();
      expect(userMessages.length, 2);
    });
  });

  group('AIResponse', () {
    test('debe crear respuesta de error', () {
      final response = AIResponse.error('Test error');

      expect(response.isError, true);
      expect(response.errorMessage, 'Test error');
      expect(response.text, contains('Lo siento'));
    });
  });
}
