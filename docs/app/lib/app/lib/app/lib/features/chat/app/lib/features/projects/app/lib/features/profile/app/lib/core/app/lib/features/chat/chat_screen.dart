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
      tooltip: "Proyectos",
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProjectsScreen()),
        );
      },
    ),
  ],
),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: messages.map((m) {
                return Align(
                  alignment:
                      m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: m.isUser ? Colors.blue : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m.text),
                  ),
                );
              }).toList(),
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Escribí acá...",
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
