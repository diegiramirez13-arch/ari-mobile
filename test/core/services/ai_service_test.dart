import 'package:ari_mobile/core/config/environment.dart';
import 'package:ari_mobile/core/services/ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AIService (sanity)', () {
    test('isAvailable refleja Environment.isProMode', () {
      final service = AIService();
      expect(service.isAvailable, Environment.isProMode);
    });

    test('clearHistory no lanza excepción', () {
      final service = AIService();
      expect(() => service.clearHistory(), returnsNormally);
    });
  });
}
