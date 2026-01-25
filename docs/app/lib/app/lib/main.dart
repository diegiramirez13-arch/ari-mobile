import 'package:flutter/material.dart';
import 'features/chat/chat_screen.dart';

void main() {
  runApp(const AriApp());
}

class AriApp extends StatelessWidget {
  const AriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ChatScreen(),
    );
  }
}
