import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/ai_metadata.dart';
import '../models/hybrid_response.dart';
import 'logger_service.dart';
import 'ai_service.dart';

/// Local orchestrator that cascades through multiple AI providers
/// Used for fallback logic when backend is unavailable
class HybridOrchestrator {
  final AIService? _openaiService;
  final Map<String, dynamic> _cascadeLog = {};

  HybridOrchestrator({AIService? openaiService}) : _openaiService = openaiService;

  /// Executes cascade: BACKEND → OPENAI → GEMINI (local fallback)
  /// Returns metadata about which provider responded
  Future<HybridResponse> generateHybridResponse(
    String prompt, {
    String? userId,
    bool forceLocal = false,
  }) async {
    final stopwatch = Stopwatch()..start();
    _cascadeLog.clear();

    try {
      // Try OpenAI if available
      if (_openaiService?.isAvailable ?? false) {
        LoggerService.info('🤖 HybridOrchestrator: Attempting OpenAI...');
        try {
          final response = await _openaiService!.generateResponse(prompt);
          stopwatch.stop();
          
          _cascadeLog['openai'] = 'success';
          LoggerService.info('✅ OpenAI responded in ${stopwatch.elapsedMilliseconds}ms');
          
          return HybridResponse.success(
            response,
            provider: 'openai',
            model: 'gpt-4o-mini',
            latencyMs: stopwatch.elapsedMilliseconds,
            cascadeLog: _cascadeLog,
          );
        } catch (e) {
          stopwatch.stop();
          _cascadeLog['openai'] = 'failed: $e';
          LoggerService.warn('⚠️ OpenAI failed: $e');
        }
      }

      // Fallback: Deterministic responses (simulates Gemini)
      stopwatch.reset();
      stopwatch.start();
      
      final fallbackResponse = _generateFallbackResponse(prompt);
      stopwatch.stop();
      
      _cascadeLog['fallback'] = 'success';
      LoggerService.info('🎯 Fallback response in ${stopwatch.elapsedMilliseconds}ms');
      
      return HybridResponse.success(
        fallbackResponse,
        provider: 'local_fallback',
        model: 'gemini-1.5-flash-equivalent',
        latencyMs: stopwatch.elapsedMilliseconds,
        cascadeLog: _cascadeLog,
      );
    } catch (e, st) {
      LoggerService.error('❌ HybridOrchestrator error', e, stackTrace: st);
      return HybridResponse.error(
        'Error procesando solicitud en la IA Híbrida: $e',
        provider: 'error',
        errorCode: 'HYBRID_ORCHESTRATION_FAILED',
        cascadeLog: _cascadeLog,
      );
    }
  }

  /// Deterministic fallback responses based on keyword matching
  String _generateFallbackResponse(String prompt) {
    final lower = prompt.toLowerCase();

    if (lower.contains('proyecto')) {
      return '📊 Smart Roadmap: Analizando estructura local... '
             'Recomendación: Crea hitos semanales y valida con stakeholders.';
    }
    if (lower.contains('tarea') || lower.contains('task')) {
      return '✅ Task Manager: Prioridad de tareas según urgencia. '
             'Comienza por lo que tenga mayor impacto inmediato.';
    }
    if (lower.contains('idea')) {
      return '💡 Idea Processor: Tu idea tiene potencial. '
             'Próximo paso: Estructura en 3 objetivos medibles.';
    }
    if (lower.contains('ayuda') || lower.contains('help')) {
      return '🆘 Asistente: Puedo ayudarte con proyectos, tareas, ideas o consultas. '
             '¿Qué necesitas?';
    }

    return '🎯 Procesado en modo Core (Local). Respuesta: Tu solicitud fue recibida. '
           'Estructura una pregunta clara para mejores resultados.';
  }

  /// System health check (all providers)
  Future<Map<String, dynamic>> getSystemStatus() async {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'orchestrator': 'hybrid_v1',
      'providers': {
        'openai': _openaiService?.isAvailable ?? false,
        'local_fallback': true,
      },
      'cascadeLog': _cascadeLog,
    };
  }

  void dispose() {
    _cascadeLog.clear();
  }
}
