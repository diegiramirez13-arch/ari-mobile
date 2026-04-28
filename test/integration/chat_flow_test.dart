import 'package:ari_mobile/features/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flujo E2E Chat', () {
    testWidgets('flujo completo: mensaje -> respuesta -> toggle -> clear', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ChatScreen())),
      );

      // 1. Verificar estado inicial
      expect(find.textContaining('Hola'), findsOneWidget);

      // 2. Enviar mensaje
      await tester.enterText(
        find.byType(TextField),
        'Quiero aprender Flutter',
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(const Duration(milliseconds: 500));

      // Verificar que aparece mensaje usuario
      expect(find.text('Quiero aprender Flutter'), findsOneWidget);

      // 3. Esperar respuesta (básica o pro según ENV)
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);

      // 4. Toggle modo (si hay API key)
      final hasAI = tester.widgetList(find.byIcon(Icons.bolt)).isNotEmpty;

      if (hasAI) {
        await tester.tap(find.byIcon(Icons.bolt).first);
        await tester.pump();
        expect(find.textContaining('Modo cambiado'), findsOneWidget);
      }

      // 5. Clear chat
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Limpiar'));
      await tester.pumpAndSettle();

      // Verificar reset
      expect(find.textContaining('Hola'), findsOneWidget);
    });
  });
}
