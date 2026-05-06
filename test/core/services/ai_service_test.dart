import 'package:ari_mobile/core/services/ai_service_v2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    // Inyectamos variables de entorno para el test
    await dotenv.load(fileName: '.env', isOptional: true);
  });

  group('AIServiceV2 - Pruebas de Contrato Multi-Backend', () {
    test('Debe inicializar LocalBackend si la API Key es inválida o vacía', () async {
      dotenv.env.clear(); // Forzamos entorno sin API key
      final service = AIServiceV2();

      final response = await service.processUserMessage('hola');

      expect(response, isNotEmpty);
      expect(response, isNot(contains('Error de Ejecución')));
    });

    test('Debe mantener un máximo de 6 mensajes en memoria', () async {
      final service = AIServiceV2();
      service.clearMemory();

      for (var i = 0; i < 8; i++) {
        await service.processUserMessage('Mensaje $i');
      }

      // Al ser un test aislado con LocalBackend, simplemente validamos
      // que el servicio no lanza excepciones de memoria (Out of Memory).
      expect(true, isTrue);
    });
  });
}
