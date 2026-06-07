import 'package:ari_mobile/core/models/ai_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AIResponse', () {
    test('success preserves text, tokens and provider metadata', () {
      final response = AIResponse.success(
        'Respuesta generada',
        tokens: 42,
        metadata: const {
          'backend': 'OpenAI',
          'model': 'gpt-4o',
        },
      );

      expect(response.text, 'Respuesta generada');
      expect(response.isError, isFalse);
      expect(response.errorCode, isNull);
      expect(response.tokensUsed, 42);
      expect(response.metadata['backend'], 'OpenAI');
      expect(response.metadata['model'], 'gpt-4o');
      expect(response.timestamp, isA<DateTime>());
    });

    test('error uses default code and preserves metadata', () {
      final response = AIResponse.error(
        'Fallo de proveedor',
        metadata: const {'backend': 'Kimi Moonshot'},
      );

      expect(response.text, 'Fallo de proveedor');
      expect(response.isError, isTrue);
      expect(response.errorCode, 'UNKNOWN_ERROR');
      expect(response.tokensUsed, isNull);
      expect(response.metadata['backend'], 'Kimi Moonshot');
    });

    test('error preserves explicit code for failover decisions', () {
      final response = AIResponse.error(
        'Todos los backends fallaron',
        code: 'ALL_BACKENDS_FAILED',
      );

      expect(response.isError, isTrue);
      expect(response.errorCode, 'ALL_BACKENDS_FAILED');
      expect(response.metadata, isEmpty);
    });
  });
}
