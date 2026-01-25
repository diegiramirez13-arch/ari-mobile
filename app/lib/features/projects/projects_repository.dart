import 'project.dart';

class ProjectsRepository {
  final List<Project> _projects = [];

  List<Project> getAll() {
    return List<Project>.from(_projects);
  }

  void add(Project project) {
    _projects.add(project);
  }
}
