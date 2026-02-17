import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'projects_repository.dart';

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  return ProjectsRepository();
});

final projectsProvider = FutureProvider<dynamic>(
  (ref) async {
    final repo = ref.watch(projectsRepositoryProvider);
    await repo.load();
    return repo.getAll();
  },
);
