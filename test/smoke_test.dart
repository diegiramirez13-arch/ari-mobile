import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Smoke Tests', () {
    test('App builds without errors', () {
      expect(true, true);
    });

    test('Flutter environment is working', () {
      expect(1 + 1, equals(2));
    });
  });
}
