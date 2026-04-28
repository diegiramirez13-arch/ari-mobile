import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/repositories/project_repository.dart';
import 'project.dart';

final projectsRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
});

final projectsErrorProvider = StateProvider<String?>((ref) => null);

final projectsControllerProvider =
    AsyncNotifierProvider<ProjectsController, List<Project>>(
  ProjectsController.new,
);

class ProjectsController extends AsyncNotifier<List<Project>> {
  StreamSubscription<List<Project>>? _projectsSub;

  @override
  Future<List<Project>> build() async {
    final uid = ref.watch(authProvider).value?.uid;
    if (uid == null) {
      return const [];
    }

    ref.onDispose(() => _projectsSub?.cancel());
    _subscribe(uid);

    return const [];
  }

  void _subscribe(String uid) {
    _projectsSub?.cancel();
    final repo = ref.read(projectsRepositoryProvider);

    _projectsSub = repo.watchProjects(uid).listen(
      (projects) {
        state = AsyncData(projects);
      },
      onError: (_) {
        ref.read(projectsErrorProvider.notifier).state =
            'No se pudieron sincronizar los proyectos en tiempo real.';
      },
    );
  }

  Future<void> refreshProjects() async {
    final uid = ref.read(authProvider).value?.uid;
    if (uid == null) return;
    _subscribe(uid);
  }

  Future<void> addProject({
    required String title,
    required String description,
  }) async {
    final uid = ref.read(authProvider).value?.uid;
    if (uid == null) return;

    if (title.trim().isEmpty) {
      ref.read(projectsErrorProvider.notifier).state =
          'El título del proyecto es obligatorio.';
      return;
    }

    final repo = ref.read(projectsRepositoryProvider);
    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
    );

    await repo.addProject(uid, project);
  }

  Future<void> toggleProjectCompleted(String projectId) async {
    final uid = ref.read(authProvider).value?.uid;
    if (uid == null) return;

    final current = state.value ?? const <Project>[];
    final index = current.indexWhere((p) => p.id == projectId);
    if (index == -1) return;

    final project = current[index];
    final updated = Project(
      id: project.id,
      title: project.title,
      description: project.description,
      completed: !project.completed,
      createdAt: project.createdAt,
    );

    await ref.read(projectsRepositoryProvider).updateProject(uid, updated);
  }

  Future<void> deleteProject(String projectId) async {
    final uid = ref.read(authProvider).value?.uid;
    if (uid == null) return;

    await ref.read(projectsRepositoryProvider).deleteProject(uid, projectId);
  }
}
