import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../models/project_model.dart';
import '../models/user_profile_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Colecciones
  static const String usersCollection = 'users';
  static const String projectsCollection = 'projects';
  static const String chatsCollection = 'chats';
  static const String profileCollection = 'profile';
  static const String profileDocId = 'data';

  CollectionReference<Map<String, dynamic>> _chatCollection(String userId) {
    return _db
        .collection(usersCollection)
        .doc(userId)
        .collection(chatsCollection);
  }

  String? get currentUserId => _auth.currentUser?.uid;

  // ============ PROJECTS ============
  Future<void> saveProject(String userId, ProjectModel project) async {
    try {
      await _db
          .collection(usersCollection)
          .doc(userId)
          .collection(projectsCollection)
          .doc(project.id)
          .set(project.toJson());
    } catch (e) {
      debugPrint('Error guardando proyecto: $e');
      rethrow;
    }
  }

  Stream<List<ProjectModel>> getProjectsStream(String userId) {
    return _db
        .collection(usersCollection)
        .doc(userId)
        .collection(projectsCollection)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ProjectModel.fromJson(doc.data())).toList());
  }

  Future<void> deleteProject(String userId, String projectId) async {
    try {
      await _db
          .collection(usersCollection)
          .doc(userId)
          .collection(projectsCollection)
          .doc(projectId)
          .delete();
    } catch (e) {
      debugPrint('Error eliminando proyecto: $e');
      rethrow;
    }
  }

  Future<void> createProject(String name, {String? userId}) async {
    final resolvedUserId = userId ?? currentUserId;
    if (resolvedUserId == null) return;

    final now = DateTime.now();
    final projectId = now.microsecondsSinceEpoch.toString();
    final project = ProjectModel(
      id: projectId,
      title: name,
      description: 'Proyecto creado automáticamente por ARI Pro.',
      createdAt: now,
      updatedAt: now,
    );

    await saveProject(resolvedUserId, project);
  }

  // ============ CHAT HISTORY ============
  Future<void> saveChatMessage(
    String userId,
    String message,
    bool isUser, {
    bool isError = false,
  }) async {
    try {
      await _chatCollection(userId).add({
        'message': message,
        'isUser': isUser,
        'isError': isError,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error guardando mensaje: $e');
      rethrow;
    }
  }

  Future<List<ChatMessage>> loadChatHistory(String userId) async {
    try {
      final snapshot = await _chatCollection(userId)
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final timestamp = data['timestamp'];
        final parsedTimestamp = timestamp is Timestamp
            ? timestamp.toDate()
            : DateTime.tryParse((timestamp ?? '').toString()) ?? DateTime.now();

        return ChatMessage(
          id: data['id'] as String? ?? doc.id,
          content: data['content'] as String? ?? data['message'] as String? ?? '',
          isUser: data['isUser'] as bool? ?? false,
          timestamp: parsedTimestamp,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error cargando historial de Firestore: $e');
      return []; // Si falla, devuelve una lista vacía para no romper la UI.
    }
  }

  Future<void> saveMessage(
    String text,
    bool isUser, {
    String? userId,
    bool isError = false,
  }) async {
    final resolvedUserId = userId ?? currentUserId;
    if (resolvedUserId == null) return;

    await saveChatMessage(
      resolvedUserId,
      text,
      isUser,
      isError: isError,
    );
  }

  Stream<List<Map<String, dynamic>>> getChatHistoryStream(String userId) {
    return _chatCollection(userId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Map<String, dynamic>>> getChatStream({String? userId}) {
    final resolvedUserId = userId ?? currentUserId;
    if (resolvedUserId == null) {
      return Stream.value([]);
    }

    return getChatHistoryStream(resolvedUserId);
  }

  Future<void> clearChatHistory(String userId) async {
    final batch = _db.batch();
    final snapshots = await _chatCollection(userId).get();
    for (final doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> clearChat({String? userId}) async {
    final resolvedUserId = userId ?? currentUserId;
    if (resolvedUserId == null) return;

    await clearChatHistory(resolvedUserId);
  }

  // ============ PROFILE ============
  Future<UserProfileModel?> getProfile(String userId) async {
    final doc = await _db.collection(usersCollection).doc(userId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final data = doc.data()!;
    if (data['name'] == null) {
      return null;
    }

    return UserProfileModel.fromMap(data);
  }

  Future<void> saveProfile(String userId, UserProfileModel profile) async {
    try {
      await _db.collection(usersCollection).doc(userId).set(
            profile.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      debugPrint('Error guardando perfil: $e');
      rethrow;
    }
  }
}
