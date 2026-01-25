import 'package:flutter/material.dart';
import 'project.dart';
import 'projects_repository.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final ProjectsRepository repo = ProjectsRepository();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await repo.load();

    // Si está vacío, cargamos 2 proyectos iniciales una sola vez.
    if (repo.getAll().isEmpty) {
      await repo.add(Project(
        id: "1",
        title: "ARI MVP",
        description: "Construir la primera versión funcional de ARI.",
      ));
      await repo.add(Project(
        id: "2",
        title: "Argentina IA Pro",
        description: "Convertir el GPT en servicio monetizable.",
      ));
    }

    setState(() => loading = false);
  }

  Future<void> _addProject() async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await repo.add(Project(
      id: id,
      title: "Nuevo proyecto",
      description: "Descripción pendiente…",
    ));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final projects = repo.getAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Proyectos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Agregar",
            onPressed: _addProject,
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, i) {
                final p = projects[i];
                return ListTile(
                  title: Text(p.title),
                  subtitle: Text(p.description),
                  trailing: Icon(
                    p.completed ? Icons.check_circle : Icons.circle_outlined,
                  ),
                );
              },
            ),
    );
  }
}
