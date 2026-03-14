import 'package:ari_mobile/core/models/chat_config.dart';
import 'package:ari_mobile/core/providers/ai_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatController - Modo Básico', () {
    test('envía mensaje en modo básico sin crash', () async {
      final container = ProviderContainer(
        overrides: [
          chatConfigProvider.overrideWithValue(
            const ChatConfig(isProMode: false),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(chatControllerProvider.notifier);

      await controller.sendMessage('Hola test');

      final state = container.read(chatControllerProvider);
      expect(state.messages.length, 2);
      expect(state.messages.first.isUser, true);
      expect(state.messages.last.isUser, false);
      expect(state.error, isNull);
    });
  });
}
