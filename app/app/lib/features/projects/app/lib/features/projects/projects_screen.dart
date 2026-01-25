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
              ),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Descripción",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Crear"),
          ),
        ],
      );
    },
  );

  if (created != true) return;

  final title = titleController.text.trim();
  final desc = descController.text.trim();

  if (title.isEmpty) return;

  final id = DateTime.now().millisecondsSinceEpoch.toString();
  await repo.add(Project(
    id: id,
    title: title,
    description: desc.isEmpty ? "Sin descripción" : desc,
  ));

  setState(() {});
}
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
  onTap: () async {
    await repo.toggleCompleted(p.id);
    setState(() {});
  },
);
