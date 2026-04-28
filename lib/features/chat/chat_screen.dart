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
    final config = ref.watch(chatConfigProvider);
    final controller = ref.read(chatControllerProvider.notifier);

    return Scaffold(
      appBar: _buildAppBar(context, state, config, controller),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(state)),
          if (state.isLoading) const LinearProgressIndicator(),
          _buildInputArea(state, controller),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ChatState state,
    ChatConfig config,
    ChatController controller,
  ) {
    final proMode = config.isProMode || state.isProMode;

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
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.folder_open_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProjectsScreen()),
            );
          },
        ),
        if (proMode)
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(Icons.bolt, color: Colors.amber),
          ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: controller.clearChat,
        ),
      ],
    );
  }

  Widget _buildMessageList(ChatState state) {
    if (state.messages.isEmpty) {
      return const Center(
        child: Text(
          '¡Hola! Soy ARI.\n¿En qué puedo ayudarte?',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages.reversed.toList()[index];
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
          border: message.isError
              ? Border.all(color: Colors.red.shade400)
              : null,
        ),
        child: Text(
          message.content,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInputArea(ChatState state, ChatController controller) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !state.isLoading,
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
            onPressed:
                state.isLoading ? null : () => _submit(_messageController.text),
            icon: state.isLoading
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

  void _navigateTo(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

    ref.read(chatControllerProvider.notifier).sendMessage(trimmed);
    _messageController.clear();
  }
}
