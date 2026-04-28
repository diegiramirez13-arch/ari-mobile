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
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);
    final config = ref.watch(chatConfigProvider);
    final controller = ref.read(chatControllerProvider.notifier);
    final proMode = config.isProMode || state.isProMode;

    return Scaffold(
      appBar: _buildAppBar(context, controller, proMode),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(state)),
          if (state.isLoading) const LinearProgressIndicator(),
          _buildInputArea(state.isLoading),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ChatController controller,
    bool proMode,
  ) {
    return AppBar(
      title: Row(
        children: [
          const Text('ARI', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: proMode ? Colors.amber : Colors.grey.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              proMode ? 'PRO' : 'BÁSICO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: proMode ? Colors.black : Colors.white,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Proyectos',
          icon: const Icon(Icons.folder_outlined),
          onPressed: () => _navigateTo(const ProjectsScreen()),
        ),
        IconButton(
          tooltip: 'Perfil',
          icon: const Icon(Icons.person_outline),
          onPressed: () => _navigateTo(const ProfileScreen()),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: controller.clearChat,
        ),
      ],
    );
  }

  Widget _buildMessageList(ChatState state) {
    final messages = state.messages.reversed.toList();
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: messages.isEmpty ? 1 : messages.length,
      itemBuilder: (context, index) {
        if (messages.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 48),
            child: Text(
              '¡Hola! Soy ARI.\n¿En qué puedo ayudarte?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final message = messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue.shade700 : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
          border: message.isError ? Border.all(color: Colors.red.shade400) : null,
        ),
        child: Text(
          message.content,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !isLoading,
              decoration: InputDecoration(
                hintText: 'Escribí tu mensaje...',
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _submit,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: isLoading ? null : () => _submit(_messageController.text),
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  void _submit(String rawText) {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) return;

    ref.read(chatControllerProvider.notifier).sendMessage(trimmed);
    _messageController.clear();
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}
