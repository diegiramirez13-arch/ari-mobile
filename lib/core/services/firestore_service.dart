import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Colecciones
  static const String usersCollection = 'users';
  static const String projectsCollection = 'projects';
  static const String chatsCollection = 'chats';

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
      print('Error guardando proyecto: $e');
      rethrow;
    }
  }

  Stream<List<ProjectModel>> getProjectsStream(String userId) {
    return _db
        .collection(usersCollection)
        .doc(userId)
        .collection(projectsCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromJson(doc.data()))
            .toList());
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
      print('Error eliminando proyecto: $e');
      rethrow;
    }
  }

  // ============ CHAT HISTORY ============
  
  Future<void> saveChatMessage(
    String userId,
    String message,
    bool isUser,
  ) async {
    try {
      await _db
          .collection(usersCollection)
          .doc(userId)
          .collection(chatsCollection)
          .add({
        'message': message,
        'isUser': isUser,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error guardando mensaje: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getChatHistoryStream(String userId) {
    return _db
        .collection(usersCollection)
        .doc(userId)
        .collection(chatsCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }
}
