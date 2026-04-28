import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../services/firestore_service.dart';

class ChatRepository {
  final AIService _aiService;
  final FirestoreService _firestoreService;

  ChatRepository(this._aiService, this._firestoreService);

  Stream<List<ChatMessage>> getMessages(String userId) {
    return _firestoreService.getChatHistory(userId);
  }

  Future<void> saveMessage(String userId, ChatMessage message) {
    return _firestoreService.saveMessage(userId, message);
  }

  Future<ChatMessage> getAIResponse(
    String text,
    List<ChatMessage> history,
  ) async {
    final aiHistory = history
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.text,
            })
        .toList();

    final response = await _aiService.generateResponse(text, history: aiHistory);

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
}
