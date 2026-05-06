import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ai_backend.dart';
import '../repositories/chat_repository.dart';
import 'logger_service.dart';
import 'local_backend.dart';
import 'openai_backend.dart';

class AIServiceV2 {
  late AIBackend _activeBackend;

  // Manejo de memoria y contexto (últimos 6 mensajes)
  final List<Map<String, String>> _contextHistory = [];
  final ChatRepository _chatRepo = ChatRepository();

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

  Future<String> processUserMessage(String prompt, String userId) async {
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

      await _chatRepo.saveChatSummary(userId, prompt, response);

      return response;
    } catch (e, stack) {
      LoggerService.error('Fallo en IA', e, stackTrace: stack);
      return 'ARI Error de Ejecución: Modo Seguro Activado.';
    }
  }

  void clearMemory() {
    _contextHistory.clear();
  }
}
