import 'package:ari_mobile/core/models/chat_config.dart';
import 'package:ari_mobile/core/providers/ai_provider.dart';
import 'package:ari_mobile/core/services/ai_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAIService extends AIService {
  @override
  Future<String> sendMessage(String message) async => 'Respuesta fake: $message';

  @override
  void clearHistory() {}
}

void main() {
  test('chat controller en básico agrega user + bot', () async {
    final container = ProviderContainer(
      overrides: [
        chatConfigProvider.overrideWithValue(const ChatConfig(isProMode: false)),
      ],
    );
    addTearDown(container.dispose);

    await container.read(chatControllerProvider.notifier).sendMessage('Hola ARI');

    final state = container.read(chatControllerProvider);
    expect(state.messages.length, 2);
    expect(state.messages.first.isUser, true);
    expect(state.messages.last.isUser, false);
    expect(state.error, isNull);
  });

  test('chat controller en pro usa AIService', () async {
    final container = ProviderContainer(
      overrides: [
        chatConfigProvider.overrideWithValue(const ChatConfig(isProMode: true)),
        aiServiceProvider.overrideWithValue(_FakeAIService()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(chatControllerProvider.notifier).sendMessage('Hola ARI');

    final state = container.read(chatControllerProvider);
    expect(state.messages.length, 2);
    expect(state.messages.last.content, 'Respuesta fake: Hola ARI');
  });
}
