import '../config/cloud_secrets.dart';
import '../models/ai_response.dart';
import 'ai_backend.dart';
import 'cloud_run_backend.dart';
import 'gemini_backend.dart';
import 'local_backend.dart';
import 'logger_service.dart';
import 'openai_backend.dart';

/// Hybrid AI orchestrator with automatic fallback.
///
/// Production path: Cloud Run performs provider orchestration with protected
/// secrets. Development/offline fallback path: local app backends are attempted
/// in priority order, ending with the deterministic local backend.
class HybridAIOrchestrator {
  HybridAIOrchestrator({CloudRunBackend? cloudRun})
      : _cloudRun = cloudRun ?? CloudRunBackend();

  final CloudRunBackend _cloudRun;
  final List<AIBackend> _backends = <AIBackend>[];
  final Map<String, int> _backendHits = <String, int>{};

  /// Initializes fallback backends in priority order: OpenAI → Gemini → Local.
  ///
  /// Kimi is intentionally routed through Cloud Run until a first-class mobile
  /// backend exists, preventing accidental exposure of Kimi credentials.
  void initialize({
    String? openaiKey,
    String? kimiKey,
    String? geminiKey,
  }) {
    _backends
      ..forEach((backend) => backend.dispose())
      ..clear();
    _backendHits.clear();

    if ((openaiKey ?? CloudSecrets.openaiKey).isNotEmpty) {
      _backends.add(OpenAIBackend());
    }

    if ((kimiKey ?? CloudSecrets.kimiKey).isNotEmpty) {
      LoggerService.info(
        'Kimi configurado para uso seguro desde Cloud Run; fallback móvil omitido',
      );
    }

    if ((geminiKey ?? CloudSecrets.geminiKey).isNotEmpty) {
      _backends.add(GeminiBackend());
    }

    _backends.add(LocalBackend());

    for (final backend in _backends) {
      _backendHits[backend.name] = 0;
    }

    LoggerService.info(
      'Orquestador inicializado con ${_backends.length} backends locales',
    );
  }

  /// Gets an AI response from Cloud Run first, then local fallbacks if needed.
  Future<AIResponse> getResponse(String prompt) async {
    try {
      final healthOk = await _cloudRun.healthCheck();
      if (healthOk) {
        final response = await _cloudRun.sendMessageToOrchestrator(prompt);
        if (!response.isError) {
          _recordHit(response.metadata['backend'] as String? ?? 'Cloud Run');
          LoggerService.info('Respuesta desde Cloud Run (producción)');
          return response;
        }

        LoggerService.error(
          'Cloud Run respondió con error; probando fallbacks locales',
          response.errorCode,
        );
      }
    } catch (error, stackTrace) {
      LoggerService.error(
        'Cloud Run no disponible; probando backends locales',
        error,
        stackTrace: stackTrace,
      );
    }

    return _tryLocalBackends(prompt);
  }

  Future<AIResponse> _tryLocalBackends(String prompt) async {
    if (_backends.isEmpty) {
      initialize();
    }

    for (var i = 0; i < _backends.length; i++) {
      final backend = _backends[i];
      if (!backend.isAvailable) {
        continue;
      }

      try {
        LoggerService.info('Intentando backend local ${backend.name}...');
        final timeoutSeconds = 20 - (i * 5);
        final responseText = await backend.generateResponse(prompt).timeout(
              Duration(seconds: timeoutSeconds.clamp(5, 20).toInt()),
            );

        _recordHit(backend.name);
        LoggerService.info('Respuesta desde ${backend.name}');
        return AIResponse.success(
          responseText,
          metadata: {'backend': backend.name},
        );
      } catch (error, stackTrace) {
        LoggerService.error(
          'Fallo en ${backend.name}',
          error,
          stackTrace: stackTrace,
        );
      }
    }

    return AIResponse.error(
      'Todos los backends están temporalmente no disponibles. Intenta de nuevo.',
      code: 'ALL_BACKENDS_FAILED',
    );
  }

  Map<String, int> getBackendStats() => Map.unmodifiable(_backendHits);

  void _recordHit(String backendName) {
    _backendHits[backendName] = (_backendHits[backendName] ?? 0) + 1;
  }

  void dispose() {
    for (final backend in _backends) {
      backend.dispose();
    }
    _cloudRun.dispose();
  }
}
