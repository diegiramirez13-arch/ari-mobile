
import 'project.dart';
import 'projects_storage.dart';

class ProjectsRepository {
  final ProjectsStorage storage;
  final List<Project> _projects = [];

  ProjectsRepository({ProjectsStorage? storage})
      : storage = storage ?? ProjectsStorage();

  List<Project> getAll() {
    return List<Project>.from(_projects);
  }

  Future<void> load() async {
    final loaded = await storage.loadProjects();
    _projects
      ..clear()
      ..addAll(loaded);
  }

  Future<void> add(Project project) async {
    _projects.add(project);
    await storage.saveProjects(_projects);
  }
}
