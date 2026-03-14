import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/chat_config.dart';
import '../../core/providers/ai_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);
    final controller = ref.read(chatControllerProvider.notifier);

    return Scaffold(
      appBar: _buildAppBar(state.config, controller),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(state)),
          if (state.isLoading) const LinearProgressIndicator(),
          _buildInputField(controller),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ChatConfig config,
    ChatController controller,
  ) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ARI', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            config.isProMode ? 'Modo Pro (GPT-4)' : 'Modo Básico',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      actions: [
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
        ),
        child: Text(
          message.content,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInputField(ChatController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
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
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () => _submit(_textController.text),
          ),
        ],
      ),
    );
  }

  void _submit(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    ref.read(chatControllerProvider.notifier).sendMessage(trimmed);
    _textController.clear();
  }
}
