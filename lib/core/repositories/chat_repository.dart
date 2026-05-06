import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_message.dart';
import '../services/logger_service.dart';

class ChatRepository {
  ChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _messagesRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('messages');
  }

  Future<List<ChatMessage>> loadMessages(String uid) async {
    final snapshot =
        await _messagesRef(uid).orderBy('timestamp', descending: false).get();

    return snapshot.docs
        .map((doc) => ChatMessage.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<ChatMessage>> watchMessages(String uid) {
    return _messagesRef(uid)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> saveMessage(String uid, ChatMessage message) async {
    await _messagesRef(uid).doc(message.id).set(message.toMap());
  }

  Future<void> clearMessages(String uid) async {
    final snapshot = await _messagesRef(uid).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> saveChatSummary(
    String userId,
    String userPrompt,
    String ariResponse,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).collection('chats').add({
        'prompt_summary': userPrompt.length > 50
            ? '${userPrompt.substring(0, 50)}...'
            : userPrompt,
        'action_taken':
            ariResponse.contains('Proyecto') ? 'Project Created' : 'Task Assigned',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e, stack) {
      LoggerService.error('Error guardando resumen de chat', e, stackTrace: stack);
    }
  }
}
