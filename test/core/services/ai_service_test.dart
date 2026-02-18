import 'package:flutter_test/flutter_test.dart';

import 'package:ari_mobile/core/services/ai_service.dart';

class FakeBackend implements AiBackend {
  final String response;

  FakeBackend(this.response);

  @override
  Future<String> generate(AiRequest request) async => response;
}

void main() {
  test('ai service routes request to selected provider', () async {
    final service = AiService({
      AiProvider.openai: FakeBackend('openai ok'),
      AiProvider.mistral: FakeBackend('mistral ok'),
    });

    final response = await service.generateResponse(
      provider: AiProvider.mistral,
      request: const AiRequest(
        systemPrompt: 'sys',
        userPrompt: 'hola',
      ),
    );

    expect(response, 'mistral ok');
  });

  test('ari system prompt includes safety rules', () {
    final prompt = AiService.ariSystemPrompt();
    expect(prompt.contains('Reglas de seguridad'), true);
  });
}
