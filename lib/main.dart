import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/environment.dart';
import 'features/chat/chat_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Validación de entorno ANTES de runApp
  Environment.validate();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARI',
      theme: ThemeData.dark(useMaterial3: true),
      home: const ChatScreen(),
    );
  }
}
