import '../models/ai_response.dart';
import '../models/ai_service_config.dart';
import '../models/chat_mode.dart';
import 'ai_backend.dart';
import 'gemini_backend.dart';
import 'local_backend.dart';
import 'openai_backend.dart';

class AIServiceV2 {
  final List<AIBackend> _backends;
  final AIServiceConfig _config;
  AIBackend? _activeBackend;

  AIServiceV2({AIServiceConfig? config})
      : _config = config ?? const AIServiceConfig(),
        _backends = [OpenAIBackend(), GeminiBackend(), LocalBackend()] {
    _selectBackend();
  }

  void _selectBackend() {
    if (_config.mode == ChatMode.basic) {
      _activeBackend = _backends.firstWhere((b) => b is LocalBackend);
      return;
    }

    for (final backend in _backends) {
      if (backend is! LocalBackend && backend.isAvailable && _config.hasApiKey) {
        _activeBackend = backend;
        return;
      }
    }

    _activeBackend = _backends.firstWhere((b) => b is LocalBackend);
  }

  String get activeBackendName => _activeBackend?.name ?? 'Ninguno';

  Future<AIResponse> sendMessage(String prompt) async {
    if (_activeBackend == null) {
      return AIResponse.error('No hay backend disponible', code: 'NO_BACKEND');
    }
    return _activeBackend!.sendMessage(prompt, _config);
  }

  void switchMode(ChatMode mode) {
    if (mode == ChatMode.basic) {
      _activeBackend = _backends.firstWhere((b) => b is LocalBackend);
      return;
    }

    for (final backend in _backends) {
      if (backend is! LocalBackend && backend.isAvailable && _config.hasApiKey) {
        _activeBackend = backend;
        return;
      }
    }

    _activeBackend = _backends.firstWhere((b) => b is LocalBackend);
  }

  void dispose() {
    for (final backend in _backends) {
      backend.dispose();
    }
  }
}
