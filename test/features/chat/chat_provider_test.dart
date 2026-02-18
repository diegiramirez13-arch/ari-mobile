import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ari_mobile/features/chat/chat_provider.dart';

void main() {
  test('chat controller starts with welcome message and appends responses',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initial = container.read(chatControllerProvider);
    expect(initial.length, 1);
    expect(initial.first.isUser, false);

    await container
        .read(chatControllerProvider.notifier)
        .sendMessage('Hola ARI');

    final updated = container.read(chatControllerProvider);
    expect(updated.length, 3);
    expect(updated[1].isUser, true);
    expect(updated[1].text, 'Hola ARI');
    expect(updated[2].isUser, false);
  });

  test('chat controller sets error when sending empty message', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(chatControllerProvider.notifier).sendMessage('   ');

    final error = container.read(chatErrorProvider);
    expect(error, isNotNull);
  });
}
