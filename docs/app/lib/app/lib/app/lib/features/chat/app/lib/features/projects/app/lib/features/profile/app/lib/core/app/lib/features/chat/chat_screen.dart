import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ARI Chat")),
      body: const Center(
        child: Text(
          "Chat de ARI en construcción",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
