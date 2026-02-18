import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'project.dart';
import 'projects_provider.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  late final ProviderSubscription<String?> _errorSubscription;

  @override
  void initState() {
    super.initState();
    _errorSubscription = ref.listenManual<String?>(
      projectsErrorProvider,
      (previous, next) {
        if (next != null && next != previous && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next)),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _errorSubscription.close();
    super.dispose();
  }

  Future<void> _addProject(BuildContext context) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo proyecto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );

    if (created == true) {
      await ref.read(projectsControllerProvider.notifier).addProject(
            title: titleController.text,
            description: descController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Proyectos')),
      body: projectsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _ProjectsListView(
          projects: projectsState.value ?? const [],
          onToggle: (projectId) {
            ref
                .read(projectsControllerProvider.notifier)
                .toggleProjectCompleted(projectId);
          },
        ),
        data: (projects) => _ProjectsListView(
          projects: projects,
          onToggle: (projectId) {
            ref
                .read(projectsControllerProvider.notifier)
                .toggleProjectCompleted(projectId);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addProject(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ProjectsListView extends StatelessWidget {
  final List<Project> projects;
  final ValueChanged<String> onToggle;

  const _ProjectsListView({
    required this.projects,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: projects.map((p) {
        return ListTile(
          title: Text(p.title),
          subtitle: Text(p.description),
          trailing: Checkbox(
            value: p.completed,
            onChanged: (_) => onToggle(p.id),
          ),
        );
      }).toList(),
    );
  }
}
