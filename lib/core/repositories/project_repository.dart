import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/projects/project.dart';

class ProjectRepository {
  ProjectRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _projectsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('projects');
  }

  Stream<List<Project>> watchProjects(String uid) {
    return _projectsRef(uid)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Project.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addProject(String uid, Project project) async {
    await _projectsRef(uid).doc(project.id).set(project.toMap());
  }

  Future<void> updateProject(String uid, Project project) async {
    await _projectsRef(uid).doc(project.id).set(project.toMap());
  }

  Future<void> deleteProject(String uid, String projectId) async {
    await _projectsRef(uid).doc(projectId).delete();
  }
}
