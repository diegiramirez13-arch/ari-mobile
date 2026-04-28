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
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
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

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: _buildAppBar(state, state.config, controller),
      body: Column(
        children: [
          if (!config.hasKey) _buildApiKeyWarning(),
          if (state.error != null) _buildErrorBanner(state.error!),
          Expanded(child: _buildMessageList(state)),
          if (state.isLoading) const LinearProgressIndicator(),
          _buildInputField(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ChatState state,
    ChatConfig config,
    ChatController controller,
  ) {
    return AppBar(
      title: Row(
        children: [
          const Text('ARI'),
          const SizedBox(width: 8),
          _buildModeBadge(state),
        ],
      ),
      actions: [
        if (config.hasKey)
          IconButton(
            icon: Icon(
              state.isProMode ? Icons.bolt : Icons.bolt_outlined,
              color: state.isProMode ? Colors.amber : null,
            ),
            tooltip:
                state.isProMode ? 'Cambiar a modo básico' : 'Activar modo Pro',
            onPressed: () =>
                ref.read(chatControllerProvider.notifier).toggleMode(),
          ),
        IconButton(
          icon: const Icon(Icons.folder),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProjectsScreen()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: state.messages.isEmpty ? null : controller.clearChat,
        ),
      ],
    );
  }

  Widget _buildModeBadge(ChatState state) {
    return Container(
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
          fontWeight: FontWeight.bold,
          color: state.isProMode ? Colors.amber : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildApiKeyWarning() {
    return Container(
      width: double.infinity,
      color: Colors.orange.withOpacity(0.2),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Modo IA no disponible. Configurá OPENAI_API_KEY para activar Pro.',
              style: TextStyle(color: Colors.orange.shade300, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.red),
            onPressed: _clearError,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        return _MessageBubble(message: message);
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
        ),
        child: Text(
          message.text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Escribí tu mensaje...',
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                onSubmitted: (_) => _sendMessage(),
                textInputAction: TextInputAction.send,
              ),
              onSubmitted: _submit,
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
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () => _submit(_controller.text),
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
