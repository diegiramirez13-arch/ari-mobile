import 'package:ari_mobile/core/models/chat_config.dart';
import 'package:ari_mobile/core/models/chat_error.dart';
import 'package:ari_mobile/core/providers/ai_provider.dart';
import 'package:ari_mobile/core/services/ai_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAIService extends AIService {
  _FakeAIService() : super(const ChatConfig(isProMode: false));
  bool cleared = false;

  @override
  Future<String> sendMessage(String message) async => 'fake:$message';

  @override
  void clearHistory() {
    cleared = true;
  }
}

void main() {
  group('ChatController - Estado inicial', () {
    test('inicializa sin mensajes y sin error', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(chatControllerProvider);

      expect(state.messages, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('modeExplanation devuelve texto informativo', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(chatControllerProvider.notifier);
      expect(controller.modeExplanation, isNotEmpty);
    });
  });

  group('ChatController - Mensajería', () {
    test('envía mensaje y agrega respuesta', () async {
      final fake = _FakeAIService();
      final container = ProviderContainer(
        overrides: [aiServiceProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      final controller = container.read(chatControllerProvider.notifier);
      await controller.sendMessage('Hola ARI');

      final state = container.read(chatControllerProvider);
      expect(state.messages.length, 2);
      expect(state.messages.first.isUser, true);
      expect(state.messages.last.isUser, false);
      expect(state.messages.last.content, 'fake:Hola ARI');
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });
  });

  group('ChatController - Manejo de errores', () {
    test('clearError limpia estado de error', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(chatControllerProvider.notifier);
      controller.clearError();

      final state = container.read(chatControllerProvider);
      expect(state.error, isNull);
    });

    test('clearChat limpia mensajes', () async {
      final fake = _FakeAIService();
      final container = ProviderContainer(
        overrides: [aiServiceProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      final controller = container.read(chatControllerProvider.notifier);
      await controller.sendMessage('hola');
      controller.clearChat();

      final state = container.read(chatControllerProvider);
      expect(state.messages, isEmpty);
      expect(fake.cleared, true);
    });

    test('modelo ChatError mantiene mensaje esperado', () {
      const error = ApiError('timeout');
      expect(error.message, contains('timeout'));
      expect(error, isA<ChatError>());
    });
  });
}
