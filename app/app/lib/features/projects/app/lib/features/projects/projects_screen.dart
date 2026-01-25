import 'package:flutter/material.dart';
import 'project.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  List<Project> demoProjects() {
    return [
      Project(
        id: "1",
        title: "ARI MVP",
        description: "Construir la primera versión funcional de ARI.",
      ),
      Project(
        id: "2",
        title: "Argentina IA Pro",
        description: "Convertir el GPT en servicio monetizable.",
      ),
      Project(
        id: "3",
        title: "Rutina semanal",
        description: "Planificar hábitos y objetivos personales.",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final projects = demoProjects();

    return Scaffold(
      appBar: AppBar(title: const Text("Proyectos")),
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
