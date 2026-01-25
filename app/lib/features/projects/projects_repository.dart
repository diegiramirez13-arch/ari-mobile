
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
 Future<void> toggleCompleted(String id) async {
  final index = _projects.indexWhere((p) => p.id == id);
  if (index == -1) return;

  final old = _projects[index];
  _projects[index] = Project(
    id: old.id,
    title: old.title,
    description: old.description,
    completed: !old.completed,
  );

  await storage.saveProjects(_projects);
} }

  Future<void> add(Project project) async {
    _projects.add(project);
    await storage.saveProjects(_projects);
  }
}
