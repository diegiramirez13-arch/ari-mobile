import 'package:ari_mobile/features/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renderiza estructura base', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ChatScreen())),
    );

    expect(find.text('ARI'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    expect(find.textContaining('Hola'), findsOneWidget);
  });
}
