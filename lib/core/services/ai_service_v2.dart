import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ai_backend.dart';
import 'local_backend.dart';
import 'openai_backend.dart';

class AIServiceV2 {
  late AIBackend _activeBackend;

  // Manejo de memoria y contexto (últimos 6 mensajes)
  final List<Map<String, String>> _contextHistory = [];

  AIServiceV2() {
    _initializeBackend();
  }

  void _initializeBackend() {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty && apiKey != 'sk-dummy-key') {
      _activeBackend = OpenAIBackend();
    } else {
      _activeBackend = LocalBackend();
    }
  }

  Future<String> processUserMessage(String prompt) async {
    try {
      _contextHistory.add({'role': 'user', 'content': prompt});

      if (_contextHistory.length > 6) {
        _contextHistory.removeAt(0);
      }

      final response = await _activeBackend.generateResponse(prompt);

      _contextHistory.add({'role': 'assistant', 'content': response});

      if (_contextHistory.length > 6) {
        _contextHistory.removeAt(0);
      }

      return response;
    } catch (e) {
      return 'ARI Error de Ejecución: Ocurrió un problema de conexión ($e). Pasando a modo seguro.';
    }
  }

  void clearMemory() {
    _contextHistory.clear();
  }
}
