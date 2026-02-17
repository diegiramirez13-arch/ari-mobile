import '../projects/projects_screen.dart';

import 'package:flutter/material.dart';
import 'message.dart';
import 'chat_logic.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatLogic logic = ChatLogic();
  final TextEditingController controller = TextEditingController();
  final List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    // Primer mensaje de ARI
    messages.add(Message(
      text: logic.nextMessage(""),
      isUser: false,
    ));
  }

  void sendMessage() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(Message(text: text, isUser: true));
      messages.add(Message(
        text: logic.nextMessage(text),
        isUser: false,
      ));
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text("ARI"),
  actions: [
    IconButton(
      icon: const Icon(Icons.folder_open),
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProjectsScreen()),
      ),
    ),
  ],
      ),
      body: Column(
  children: [
    Expanded(
      child: ListView(
        key: ValueKey(messages.length),
        children: messages
            .map(
              (m) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                child: Align(
                  alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 16),
                    decoration: BoxDecoration(
                      color: m.isUser
                          ? Colors.blue.shade700
                          : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      m.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Escribe tu mensaje...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: sendMessage,
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
