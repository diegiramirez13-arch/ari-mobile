
mport 'package:flutter/material.dart';
import 'project.dart';
import 'projects_repository.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final ProjectsRepository repo = ProjectsRepository();

  @override
  void initState() {
    super.initState();

    // Cargamos algunos proyectos iniciales (solo una vez, en memoria)
    repo.add(Project(
      id: "1",
      title: "ARI MVP",
      description: "Construir la primera versión funcional de ARI.",
    ));
    repo.add(Project(
      id: "2",
      title: "Argentina IA Pro",
      description: "Convertir el GPT en servicio monetizable.",
    ));
  }

  void addProject() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    repo.add(Project(
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
            onPressed: addProject,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, i) {
          final p = projects[i];
          return ListTile(
            title: Text(p.title),
            subtitle: Text(p.description),
            trailing: Icon(p.completed ? Icons.check_circle : Icons.circle_outlined),
          );
        },
      ),
    );
  }
}
