import 'package:ari_mobile/core/services/ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AIService', () {
    test('debe inicializarse con API key válida', () {
      const config = AIServiceConfig(apiKey: 'test-key');
      final service = AIService(config: config);

      expect(service.isAvailable, true);
      service.dispose();
    });

    test('debe fallar sin API key', () {
      const config = AIServiceConfig(apiKey: '');
      final service = AIService(config: config);

      expect(service.isAvailable, false);
    });
  });

  group('AIResponse', () {
    test('debe crear respuesta de error', () {
      final response = AIResponse.error('Test error');

      expect(response.isError, true);
      expect(response.errorMessage, 'Test error');
      expect(response.text, contains('Lo siento'));
    });
  });
}
