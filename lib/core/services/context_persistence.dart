import 'dart:convert';

import '../models/ai_response.dart';
import '../models/chat_message.dart';

abstract class ContextPersistence {
  Future<void> saveMessages(String sessionId, List<ChatMessage> messages);
  Future<List<ChatMessage>> loadMessages(String sessionId);
  Future<void> clearSession(String sessionId);
  Future<List<String>> getSessionIds();
}

class MemoryPersistence implements ContextPersistence {
  final Map<String, List<Map<String, dynamic>>> _storage = {};

  @override
  Future<void> saveMessages(String sessionId, List<ChatMessage> messages) async {
    _storage[sessionId] = messages
        .map((m) => {
              'id': m.id,
              'content': m.content,
              'isUser': m.isUser,
              'timestamp': m.timestamp.toIso8601String(),
              'responseText': m.aiResponse?.text,
              'responseError': m.aiResponse?.isError,
            })
        .toList();
  }

  @override
  Future<List<ChatMessage>> loadMessages(String sessionId) async {
    final data = _storage[sessionId];
    if (data == null) return [];

    final normalized = jsonDecode(jsonEncode(data)) as List<dynamic>;

    return normalized
        .map((raw) {
          final m = raw as Map<String, dynamic>;
          return ChatMessage(
            id: m['id'],
            content: m['content'],
            isUser: m['isUser'],
            timestamp: DateTime.parse(m['timestamp']),
            aiResponse: m['responseText'] != null
                ? AIResponse(
                    text: m['responseText'],
                    isError: m['responseError'] ?? false,
                  )
                : null,
          );
        })
        .toList();
  }

  @override
  Future<void> clearSession(String sessionId) async {
    _storage.remove(sessionId);
  }

  @override
  Future<List<String>> getSessionIds() async {
    return _storage.keys.toList();
  }
}

class LocalStoragePersistence implements ContextPersistence {
  // Para web: usar localStorage via JS interop
  // Para móvil: usar SharedPreferences
  // Implementación placeholder - se completa según plataforma

  @override
  Future<void> saveMessages(String sessionId, List<ChatMessage> messages) async {
    // TODO: Implementar con localStorage o SharedPreferences
    throw UnimplementedError('LocalStoragePersistence.saveMessages');
  }

  @override
  Future<List<ChatMessage>> loadMessages(String sessionId) async {
    // TODO: Implementar
    throw UnimplementedError('LocalStoragePersistence.loadMessages');
  }

  @override
  Future<void> clearSession(String sessionId) async {
    // TODO: Implementar
  }

  @override
  Future<List<String>> getSessionIds() async {
    // TODO: Implementar
    return [];
  }
}
