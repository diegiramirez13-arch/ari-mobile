import 'package:flutter/material.dart';

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
      home: Scaffold(
        body: Center(
          child: Text(
            'ARI está vivo',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
