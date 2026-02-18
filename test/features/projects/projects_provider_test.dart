import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ari_mobile/features/projects/project.dart';
import 'package:ari_mobile/features/projects/projects_provider.dart';
import 'package:ari_mobile/features/projects/projects_repository.dart';
import 'package:ari_mobile/features/projects/projects_storage.dart';

class FakeProjectsStorage extends ProjectsStorage {
  List<Project> db = [];

  @override
  Future<void> saveProjects(List<Project> projects) async {
    db = List<Project>.from(projects);
  }

  @override
  Future<List<Project>> loadProjects() async {
    return List<Project>.from(db);
  }
}

void main() {
  test('projects controller seeds initial projects when storage is empty', () async {
    final storage = FakeProjectsStorage();
    final repo = ProjectsRepository(storage: storage);

    final container = ProviderContainer(
      overrides: [
        projectsRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final projects = await container.read(projectsControllerProvider.future);

    expect(projects.length, 2);
    expect(projects.first.title, 'ARI MVP');
  });

  test('projects controller adds project', () async {
    final storage = FakeProjectsStorage();
    final repo = ProjectsRepository(storage: storage);

    final container = ProviderContainer(
      overrides: [
        projectsRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    await container.read(projectsControllerProvider.future);
    await container.read(projectsControllerProvider.notifier).addProject(
          title: 'Nuevo',
          description: 'Desc',
        );

    final projects = container.read(projectsControllerProvider).value ?? [];
    expect(projects.any((p) => p.title == 'Nuevo'), true);
  });
}
