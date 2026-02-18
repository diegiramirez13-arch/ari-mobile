import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ari_mobile/features/chat/chat_memory_repository.dart';
import 'package:ari_mobile/features/chat/message.dart';

void main() {
  test('sanitization and summary save can be called', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = ChatMemoryRepository();

    // Only verifies method contract execution path.
    await repo.saveRelevantSummary('user-1', [
      Message(text: 'mi email es test@mail.com', isUser: true),
      Message(text: 'respuesta', isUser: false),
      Message(text: '+54 11 4444 5555', isUser: true),
    ]);

    final summary = await repo.getSummary('user-1');
    expect(summary, isNotNull);
  });
}
