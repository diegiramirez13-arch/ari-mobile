import 'package:ari_mobile/core/models/chat_config.dart';
import 'package:ari_mobile/core/providers/ai_provider.dart';
import 'package:ari_mobile/core/services/ai_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAIService extends AIService {
  bool cleared = false;

  @override
  Future<String> sendMessage(String message) async => 'ok';

  @override
  void clearHistory() {
    cleared = true;
  }
}

void main() {
  group('ChatController', () {
    test('inicializa con config provista por chatConfigProvider', () {
      final container = ProviderContainer(
        overrides: [
          chatConfigProvider.overrideWithValue(const ChatConfig(isProMode: false)),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(chatControllerProvider);
      expect(state.config.isProMode, false);
      expect(state.messages, isEmpty);
      expect(state.isLoading, false);
    });

    test('ignora mensajes vacíos', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(chatControllerProvider.notifier);

      await controller.sendMessage('');
      await controller.sendMessage('   ');

      final state = container.read(chatControllerProvider);
      expect(state.messages, isEmpty);
    });

    test('clearChat limpia mensajes y llama clearHistory', () async {
      final fake = _FakeAIService();
      final container = ProviderContainer(
        overrides: [
          chatConfigProvider.overrideWithValue(const ChatConfig(isProMode: true)),
          aiServiceProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(chatControllerProvider.notifier);

      await controller.sendMessage('hola');
      controller.clearChat();

      final state = container.read(chatControllerProvider);
      expect(state.messages, isEmpty);
      expect(fake.cleared, true);
    });
  });
}
