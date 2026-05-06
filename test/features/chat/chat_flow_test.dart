import 'package:ari_mobile/core/services/ai_service_v2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    // Carga segura para CI/CD
    await dotenv.load(fileName: '.env', isOptional: true);
  });

  group('Flujo Crítico End-to-End: Chat', () {
    test('El orquestador debe usar LocalBackend si no hay API Key y no crashear', () async {
      dotenv.env.clear(); // Forzamos entorno sin key
      final aiService = AIServiceV2();

      final response = await aiService.processUserMessage('Crear tarea de prueba');

      // Validación: El sistema debe responder determinísticamente sin romper el flujo
      expect(response, isNotNull);
      expect(response, isNotEmpty);
      expect(response.toLowerCase(), isNot(contains('error')));
    });
  });
}
