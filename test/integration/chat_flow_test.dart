import 'package:ari_mobile/features/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flujo E2E Chat', () {
    testWidgets('flujo básico: mensaje -> respuesta -> clear', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ChatScreen())),
      );

      expect(find.textContaining('Hola'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Quiero aprender Flutter');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Quiero aprender Flutter'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.textContaining('Hola'), findsOneWidget);
    });
  });
}
