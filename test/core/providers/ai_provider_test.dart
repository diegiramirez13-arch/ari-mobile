import 'package:ari_mobile/core/providers/ai_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatController', () {
    late ProviderContainer container;
    late ChatController controller;

    setUp(() {
      container = ProviderContainer();
      controller = container.read(chatControllerProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('debe inicializar con mensaje de bienvenida', () {
      final state = container.read(chatControllerProvider);

      expect(state.messages.length, 1);
      expect(state.messages.first.isUser, false);
      expect(state.isLoading, false);
    });

    test('debe agregar mensaje de usuario al enviar', () async {
      await controller.sendMessage('Hola test');

      final state = container.read(chatControllerProvider);
      expect(state.messages.length, 3);
      expect(state.messages[1].isUser, true);
      expect(state.messages[1].content, 'Hola test');
    });

    test('debe ignorar mensajes vacíos', () async {
      final initialLength = container.read(chatControllerProvider).messages.length;

      await controller.sendMessage('');
      await controller.sendMessage('   ');

      final state = container.read(chatControllerProvider);
      expect(state.messages.length, initialLength);
    });

    test('debe cambiar modo correctamente con API key', () {
      final withKeyContainer = ProviderContainer(
        overrides: [
          openAIApiKeyProvider.overrideWithValue('test-key'),
        ],
      );
      addTearDown(withKeyContainer.dispose);
      final withKeyController = withKeyContainer.read(chatControllerProvider.notifier);
      final initialMode = withKeyContainer.read(chatControllerProvider).mode;

      withKeyController.toggleMode();

      final newState = withKeyContainer.read(chatControllerProvider);
      expect(newState.mode, isNot(initialMode));
      expect(newState.messages.last.content, contains('Modo cambiado'));
    });

    test('debe limpiar chat correctamente', () async {
      await controller.sendMessage('Test message');
      controller.clearChat();

      final state = container.read(chatControllerProvider);
      expect(state.messages.length, 1);
      expect(state.error, null);
      expect(state.isLoading, false);
    });
  });

  group('ChatState', () {
    test('debe identificar modo Pro correctamente', () {
      const proState = ChatState(mode: ChatMode.pro);
      const basicState = ChatState(mode: ChatMode.basic);

      expect(proState.isProMode, true);
      expect(basicState.isProMode, false);
    });

    test('debe copiar correctamente', () {
      const original = ChatState(
        messages: [],
        isLoading: false,
        mode: ChatMode.basic,
        error: null,
      );

      final copy = original.copyWith(isLoading: true, error: 'test');

      expect(copy.isLoading, true);
      expect(copy.error, 'test');
      expect(copy.mode, original.mode);
    });
  });
}
