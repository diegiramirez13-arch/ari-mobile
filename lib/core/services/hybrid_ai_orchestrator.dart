import '../config/cloud_secrets.dart';
import '../models/ai_response.dart';
import '../models/ai_service_config.dart';
import 'ai_backend.dart';
import 'cloud_run_backend.dart';
import 'gemini_backend.dart';
import 'kimi_backend.dart';
import 'local_backend.dart';
import 'logger_service.dart';
import 'openai_backend.dart';

/// Hybrid AI orchestrator with automatic fallback.
///
/// Production path: Cloud Run performs provider orchestration with protected
/// secrets. Development/offline fallback path: local app backends are attempted
/// in priority order: OpenAI GPT-4o → Kimi Moonshot → Gemini → Local.
class HybridAIOrchestrator {
  HybridAIOrchestrator({CloudRunBackend? cloudRun})
      : _cloudRun = cloudRun ?? CloudRunBackend();

  final CloudRunBackend _cloudRun;
  final List<_BackendCandidate> _backends = <_BackendCandidate>[];
  final Map<String, int> _backendHits = <String, int>{};

  /// Initializes fallback backends in priority order.
  ///
  /// API keys are read from explicit arguments first and then from
  /// [CloudSecrets]. Production builds should still prefer Cloud Run so provider
  /// credentials stay server-side.
  void initialize({
    String? openaiKey,
    String? kimiKey,
    String? geminiKey,
  }) {
    _backends
      ..forEach((candidate) => candidate.backend.dispose())
      ..clear();
    _backendHits.clear();

    final resolvedOpenAIKey = openaiKey ?? CloudSecrets.openaiKey;
    final resolvedKimiKey = kimiKey ?? CloudSecrets.kimiKey;
    final resolvedGeminiKey = geminiKey ?? CloudSecrets.geminiKey;

    if (resolvedOpenAIKey.isNotEmpty) {
      _backends.add(
        _BackendCandidate(
          backend: OpenAIBackend(),
          config: AIServiceConfig(
            apiKey: resolvedOpenAIKey,
            modelName: 'gpt-4o',
            maxTokens: 300,
          ),
        ),
      );
    }

    if (resolvedKimiKey.isNotEmpty) {
      _backends.add(
        _BackendCandidate(
          backend: KimiBackend(),
          config: AIServiceConfig(
            apiKey: resolvedKimiKey,
            modelName: 'moonshot-v1-8k',
            maxTokens: 300,
          ),
        ),
      );
    }

    if (resolvedGeminiKey.isNotEmpty) {
      _backends.add(
        _BackendCandidate(
          backend: GeminiBackend(),
          config: AIServiceConfig(
            apiKey: resolvedGeminiKey,
            modelName: 'gemini-1.5-flash',
            maxTokens: 300,
          ),
        ),
      );
    }

    _backends.add(
      _BackendCandidate(
        backend: LocalBackend(),
        config: const AIServiceConfig(),
      ),
    );

    for (final candidate in _backends) {
      _backendHits[candidate.backend.name] = 0;
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
      final candidate = _backends[i];
      final backend = candidate.backend;
      if (!backend.isAvailable) {
        continue;
      }

      try {
        LoggerService.info('Intentando backend local ${backend.name}...');
        final timeoutSeconds = 30 - (i * 5);
        final response = await backend.sendMessage(prompt, candidate.config).timeout(
              Duration(seconds: timeoutSeconds.clamp(8, 30).toInt()),
            );

        if (response.isError) {
          LoggerService.error(
            '${backend.name} devolvió error; continuando failover',
            response.errorCode,
          );
          continue;
        }

        _recordHit(backend.name);
        LoggerService.info('Respuesta desde ${backend.name}');
        return AIResponse.success(
          response.text,
          tokens: response.tokensUsed,
          metadata: {
            ...response.metadata,
            'backend': response.metadata['backend'] ?? backend.name,
          },
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
    for (final candidate in _backends) {
      candidate.backend.dispose();
    }
    _cloudRun.dispose();
  }
}

class _BackendCandidate {
  const _BackendCandidate({
    required this.backend,
    required this.config,
  });

  final AIBackend backend;
  final AIServiceConfig config;
}
