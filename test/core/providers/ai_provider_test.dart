import 'package:ari_mobile/core/models/chat_config.dart';
import 'package:ari_mobile/core/models/chat_error.dart';
import 'package:ari_mobile/core/providers/ai_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatController - Estado inicial', () {
    test('modo básico cuando no hay API key', () {
      final container = ProviderContainer(
        overrides: [
          chatConfigProvider.overrideWithValue(
            const ChatConfig(
              isProMode: false,
              model: 'gpt-4o-mini',
              temperature: 0.7,
              maxTokens: 1000,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(chatControllerProvider);

      expect(state.config.isProMode, false);
      expect(state.messages, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('modo pro cuando hay API key', () {
      final container = ProviderContainer(
        overrides: [
          chatConfigProvider.overrideWithValue(
            const ChatConfig(
              isProMode: true,
              model: 'gpt-4o',
              temperature: 0.5,
              maxTokens: 2000,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(chatControllerProvider);
      expect(state.config.isProMode, true);
      expect(state.config.model, 'gpt-4o');
    });
  });

  group('ChatController - Mensajería modo básico', () {
    test('envía mensaje y recibe respuesta de fallback', () async {
      final container = ProviderContainer(
        overrides: [
          chatConfigProvider.overrideWithValue(
            const ChatConfig(isProMode: false),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(chatControllerProvider.notifier);

      await controller.sendMessage('Hola ARI');

      final state = container.read(chatControllerProvider);
      expect(state.messages.length, 2);
      expect(state.messages.first.isUser, true);
      expect(state.messages.last.isUser, false);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('modeExplanation refleja estado correcto', () {
      final container = ProviderContainer(
        overrides: [
          chatConfigProvider.overrideWithValue(
            const ChatConfig(isProMode: true, model: 'gpt-4o-mini'),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(chatControllerProvider.notifier);
      expect(
        controller.modeExplanation,
        contains('gpt-4o-mini'),
      );
    });
  });

  group('ChatController - Manejo de errores', () {
    test('clearError limpia estado de error', () {
      final container = ProviderContainer(
        overrides: [
          chatConfigProvider.overrideWithValue(
            const ChatConfig(isProMode: false),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(chatControllerProvider.notifier);

      controller.clearError();
      final state = container.read(chatControllerProvider);
      expect(state.error, isNull);
    });

    test('modelo ChatError mantiene mensaje esperado', () {
      const error = ApiError('timeout');
      expect(error.message, contains('timeout'));
      expect(error, isA<ChatError>());
    });
  });
}
