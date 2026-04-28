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
  final TextEditingController _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatControllerProvider.notifier).sendMessage(text);
    _textController.clear();
    _focusNode.requestFocus();
    _scrollToBottom();
  }

  void _clearError() {
    ref.read(chatControllerProvider.notifier).clearError();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);
    final hasAI = ref.watch(hasAIProvider);
    final ctrl = ref.read(chatControllerProvider.notifier);

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
                    ? Colors.amber.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
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
          if (hasAI)
            IconButton(
              icon: Icon(
                state.isProMode ? Icons.bolt : Icons.bolt_outlined,
                color: state.isProMode ? Colors.amber : null,
              ),
              onPressed: ctrl.togglePro,
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => showDialog<void>(
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
                      ctrl.clear();
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProjectsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!hasAI)
            Container(
              width: double.infinity,
              color: Colors.orange.withOpacity(0.2),
              padding: const EdgeInsets.all(12),
              child: const Text(
                '⚠️ Modo IA no disponible. Configura OPENAI_API_KEY',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.messages.length,
              itemBuilder: (_, i) {
                final m = state.messages[i];
                final isUser = m.role == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue.shade700 : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      m.content,
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
                    controller: _textCtrl,
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
                    onSubmitted: (t) {
                      if (t.isNotEmpty) {
                        ctrl.send(t);
                        _textCtrl.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: state.isLoading
                      ? null
                      : () {
                          if (_textCtrl.text.isNotEmpty) {
                            ctrl.send(_textCtrl.text);
                            _textCtrl.clear();
                          }
                        },
                  child: const Icon(Icons.send),
                ),
              ],
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              mini: true,
              onPressed: state.isLoading ? null : _sendMessage,
              child: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Limpiar conversación?'),
        content: const Text('Se borrará todo el historial de mensajes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

    ref.read(chatControllerProvider.notifier).sendMessage(trimmed);
    _controller.clear();
  }
}
