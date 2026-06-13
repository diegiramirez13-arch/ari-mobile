import 'package:ari_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SplashScreen renders ARI loading state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAriDarkTheme(),
        home: const SplashScreen(),
      ),
    );

    expect(find.text('ARI'), findsOneWidget);
    expect(find.text('Inicializando...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  test('buildAriDarkTheme exposes official dark visual baseline', () {
    final theme = buildAriDarkTheme();

    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, const Color(0xFF050A14));
    expect(theme.progressIndicatorTheme.color, const Color(0xFF00E5FF));
  });
}
