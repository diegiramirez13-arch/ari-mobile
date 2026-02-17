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
    final titleController = TextEditingController();
    final descController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nuevo proyecto"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Título",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: "Descripción",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Crear"),
            ),
          ],
        );
      },
    );

    if (created == true && titleController.text.isNotEmpty) {
      await repo.add(Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text,
        description: descController.text,
      ));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Proyectos")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: repo.getAll().map((p) {
                return ListTile(
                  title: Text(p.title),
                  subtitle: Text(p.description),
                  trailing: Checkbox(
                    value: p.completed,
                    onChanged: (_) => repo.toggleCompleted(p.id).then((_) {
                      setState(() {});
                    }),
                  ),
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProject,
        child: const Icon(Icons.add),
      ),
    );
  }
}
