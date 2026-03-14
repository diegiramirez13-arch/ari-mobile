import 'package:ari_mobile/core/models/chat_config.dart';
import 'package:ari_mobile/core/services/ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AIService (sanity)', () {
    test('isAvailable es false en modo básico inyectado', () {
      final service = AIService(const ChatConfig(isProMode: false));
      expect(service.isAvailable, false);
    });

    test('clearHistory no lanza excepción', () {
      final service = AIService(const ChatConfig(isProMode: false));
      expect(() => service.clearHistory(), returnsNormally);
    });
  });
}
