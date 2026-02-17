import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/project_model.dart';
import 'auth_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Get projects stream
final projectsStreamProvider = StreamProvider<List<ProjectModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  return firestoreService.getProjectsStream(userId);
});

// Save project
final saveProjectProvider =
    FutureProvider.family<void, ProjectModel>((ref, project) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) throw Exception('User not authenticated');

  await firestoreService.saveProject(userId, project);
});

// Delete project
final deleteProjectProvider =
    FutureProvider.family<void, String>((ref, projectId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) throw Exception('User not authenticated');

  await firestoreService.deleteProject(userId, projectId);
});

// Get chat history
final chatHistoryProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  return firestoreService.getChatHistoryStream(userId);
});
