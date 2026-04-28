import 'ai_response.dart';

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final AIResponse? aiResponse;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    DateTime? timestamp,
    this.aiResponse,
  }) : timestamp = timestamp ?? DateTime.now();
}
