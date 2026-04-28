import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'project.dart';
import 'projects_repository.dart';

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  return ProjectsRepository();
});

final projectsErrorProvider = StateProvider<String?>((ref) => null);

final projectsControllerProvider =
    AsyncNotifierProvider<ProjectsController, List<Project>>(
  ProjectsController.new,
);

class ProjectsController extends AsyncNotifier<List<Project>> {
  @override
  Future<List<Project>> build() async {
    return _loadProjects();
  }

  Future<List<Project>> _loadProjects() async {
    ref.read(projectsErrorProvider.notifier).state = null;
    final repo = ref.read(projectsRepositoryProvider);

    try {
      await repo.load();

      if (repo.getAll().isEmpty) {
        await repo.add(Project(
          id: '1',
          title: 'ARI MVP',
          description: 'Construir la primera versión funcional de ARI.',
        ));
        await repo.add(Project(
          id: '2',
          title: 'Argentina IA Pro',
          description: 'Convertir el GPT en servicio monetizable.',
        ));
      }

      return repo.getAll();
    } catch (_) {
      ref.read(projectsErrorProvider.notifier).state =
          'No se pudieron cargar los proyectos.';
      return const [];
    }
  }

  Future<void> refreshProjects() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadProjects);
  }

  Future<void> addProject({
    required String title,
    required String description,
  }) async {
    if (title.trim().isEmpty) {
      ref.read(projectsErrorProvider.notifier).state =
          'El título del proyecto es obligatorio.';
      return;
    }

    final previous = state.value ?? const <Project>[];
    final repo = ref.read(projectsRepositoryProvider);

    state = const AsyncLoading();
    ref.read(projectsErrorProvider.notifier).state = null;

    state = await AsyncValue.guard(() async {
      await repo.add(Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.trim(),
        description: description.trim(),
      ));
      return repo.getAll();
    });

    if (state.hasError) {
      ref.read(projectsErrorProvider.notifier).state =
          'No se pudo crear el proyecto.';
      state = AsyncData(previous);
    }
  }

  Future<void> toggleProjectCompleted(String projectId) async {
    final previous = state.value ?? const <Project>[];
    final repo = ref.read(projectsRepositoryProvider);

    state = const AsyncLoading();
    ref.read(projectsErrorProvider.notifier).state = null;

    state = await AsyncValue.guard(() async {
      await repo.toggleCompleted(projectId);
      return repo.getAll();
    });

    if (state.hasError) {
      ref.read(projectsErrorProvider.notifier).state =
          'No se pudo actualizar el proyecto.';
      state = AsyncData(previous);
    }
  }
}
