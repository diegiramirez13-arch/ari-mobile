import 'package:ari_mobile/core/models/chat_config.dart';
import 'package:ari_mobile/core/services/ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AIService - Inicialización', () {
    test('modo básico: cliente no disponible', () {
      final config = const ChatConfig(isProMode: false);
      final service = AIService(config);

      expect(service.isAvailable, false);
    });

    test('modo pro: cliente disponible con config inyectada', () {
      final config = const ChatConfig(
        isProMode: true,
        model: 'gpt-4o',
        temperature: 0.5,
        maxTokens: 500,
      );
      final service = AIService(config);

      expect(service.isAvailable, true);
      expect(config.model, 'gpt-4o');
      expect(config.temperature, 0.5);
      expect(config.maxTokens, 500);
    });
  });

  group('AIService - utilidades', () {
    test('clearHistory no lanza excepción', () {
      final service = AIService(const ChatConfig(isProMode: false));
      expect(() => service.clearHistory(), returnsNormally);
    });
  });
}
