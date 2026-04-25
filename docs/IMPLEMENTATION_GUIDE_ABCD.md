# Guía de Implementación ARI Mobile - Fase ABCD
**Fecha:** 2026-04-25
**Autor:** Diego Ramírez + Kimi (Asistente IA)
**Estado:** En progreso

---

## ESTRUCTURA DE ARCHIVOS NUEVOS

```plain
lib/
├── core/
│   ├── models/
│   │   ├── chat_mode.dart              ✅ (A)
│   │   ├── ai_service_config.dart      ✅ (A)
│   │   ├── ai_response.dart            ✅ (A)
│   │   └── chat_message.dart           ✅ (A)
│   ├── services/
│   │   ├── ai_backend.dart             ✅ (B)
│   │   ├── openai_backend.dart         ✅ (B)
│   │   ├── gemini_backend.dart         ✅ (B)
│   │   ├── local_backend.dart          ✅ (B)
│   │   ├── ai_service_v2.dart          ✅ (B)
│   │   └── context_persistence.dart    ✅ (C)
│   └── providers/
│       └── ai_provider.dart            ⚠️ (Actualizar)
├── main.dart                           ⚠️ (Actualizar a v2)
└── ui/
    └── chat/
        └── chat_screen.dart            🆕 (Crear)
```

---

## INTEGRACIÓN EN main.dart

Reemplazar `AiService` por `AIServiceV2`:

```dart
import 'package:flutter/material.dart';
import 'core/models/ai_service_config.dart';
import 'core/models/chat_mode.dart';
import 'core/services/ai_service_v2.dart';
import 'core/models/chat_message.dart';

void main() {
  runApp(const AriApp());
}

class AriApp extends StatelessWidget {
  const AriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARI Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AIServiceV2 _aiService = AIServiceV2(
    config: const AIServiceConfig(mode: ChatMode.basic),
  );
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _aiService.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _enviarMensaje() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: texto,
        isUser: true,
      ));
      _cargando = true;
      _controller.clear();
    });

    final respuesta = await _aiService.sendMessage(texto);

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: respuesta.text,
        isUser: false,
        aiResponse: respuesta,
      ));
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ARI Mobile'),
        subtitle: Text('Backend: ${_aiService.activeBackendName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.blue[800] : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg.content),
                  ),
                );
              },
            ),
          ),
          if (_cargando) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribí un mensaje...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _enviarMensaje(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _enviarMensaje,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## PRIORIDADES DE IMPLEMENTACIÓN

| Prioridad | Tarea | Archivo |
|---|---|---|
| P0 | Crear modelos (A) | `core/models/*.dart` |
| P1 | Implementar backends (B) | `core/services/*_backend.dart` |
| P2 | Integrar en UI | `main.dart` |
| P3 | Persistencia (C) | `context_persistence.dart` |
| P4 | Tests | `test/` |

## COMANDOS

```bash
# Ejecutar en modo demo (sin API key)
flutter run -d web-server --web-port=8080

# Ejecutar con OpenAI
flutter run -d web-server --web-port=8080 --dart-define=OPENAI_API_KEY=sk-xxx

# Ejecutar con Gemini
flutter run -d web-server --web-port=8080 --dart-define=GEMINI_API_KEY=xxx
```
