import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/ai_provider.dart';
import '../profile/profile_screen.dart';
import '../projects/projects_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text;
    if (text.trim().isEmpty) return;

    ref.read(chatControllerProvider.notifier).sendMessage(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);
    final ctrl = ref.read(chatControllerProvider.notifier);

    ref.listen<String?>(chatErrorProvider, (previous, next) {
      if (next != null && next != previous) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
        ctrl.clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('ARI'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: state.isProMode
                    ? Colors.amber.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.isProMode ? Colors.amber : Colors.grey,
                ),
              ),
              child: Text(
                state.isProMode ? 'PRO' : 'BÁSICO',
                style: TextStyle(
                  fontSize: 10,
                  color: state.isProMode ? Colors.amber : Colors.grey,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              state.isProMode ? Icons.bolt : Icons.bolt_outlined,
              color: state.isProMode ? Colors.amber : null,
            ),
            tooltip: 'Cambiar modo',
            onPressed: ctrl.toggleMode,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Limpiar chat',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('¿Limpiar chat?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      ctrl.clearChat();
                      Navigator.pop(context);
                    },
                    child: const Text('Limpiar'),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Perfil',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Proyectos',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProjectsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!state.canSwitchToPro)
            Container(
              width: double.infinity,
              color: Colors.orange.withValues(alpha: 0.2),
              padding: const EdgeInsets.all(12),
              child: const Text(
                '⚠️ Modo IA no disponible. Configurá OPENAI_API_KEY',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.messages.length,
              itemBuilder: (_, i) {
                final message = state.messages[i];
                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? Colors.blue.shade700
                          : message.isError
                              ? Colors.red.shade700
                              : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message.content,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'ARI está pensando...',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Escribí tu mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: state.isLoading ? null : _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
