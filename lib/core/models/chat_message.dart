import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'isUser': isUser,
      'timestamp': Timestamp.fromDate(timestamp),
      'isError': isError,
    };
  }

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    final ts = map['timestamp'];
    DateTime parsed = DateTime.now();
    if (ts is Timestamp) {
      parsed = ts.toDate();
    } else if (ts is String) {
      parsed = DateTime.tryParse(ts) ?? DateTime.now();
    }

    return ChatMessage(
      id: id,
      content: map['content'] as String? ?? '',
      isUser: map['isUser'] as bool? ?? false,
      timestamp: parsed,
      isError: map['isError'] as bool? ?? false,
    );
  }
}
