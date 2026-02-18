import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ari_mobile/core/providers/ai_provider.dart';

void main() {
  test('chat controller starts with one welcome message', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(chatControllerProvider);
    expect(state.messages.length, 1);
    expect(state.messages.first.isUser, false);
  });

  test('chat controller appends user and assistant messages in basic mode', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(chatControllerProvider.notifier).sendMessage('Hola ARI');

    final state = container.read(chatControllerProvider);
    expect(state.messages.length, 3);
    expect(state.messages[1].isUser, true);
    expect(state.messages[1].content, 'Hola ARI');
    expect(state.messages[2].isUser, false);
    expect(state.error, isNull);
  });

  test('toggle mode sets error when no API key is configured', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(chatControllerProvider.notifier);
    notifier.toggleMode();

    final state = container.read(chatControllerProvider);
    expect(state.mode, ChatMode.basic);
    expect(state.error, isNotNull);
  });
}
