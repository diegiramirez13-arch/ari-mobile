import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/cloud_secrets.dart';
import '../models/hybrid_response.dart';
import '../models/ai_metadata.dart';
import 'logger_service.dart';

/// Service to communicate with the hybrid backend on Cloud Run
/// Handles authentication, retry logic, and offline fallback
class BackendAIService {
  final String? _authToken;
  final String _backendUrl;
  static const int _requestTimeoutSeconds = 30;
  static const int _maxRetries = 3;

  BackendAIService({
    String? authToken,
    String? backendUrl,
  })
      : _authToken = authToken,
        _backendUrl = backendUrl ?? CloudSecrets.backendUrl;

  /// POST /api/chat/hybrid - Send prompt to backend orchestrator
  Future<HybridResponse> sendChatMessage(
    String prompt, {
    String? userId,
  }) async {
    final stopwatch = Stopwatch()..start();

    if (_backendUrl.isEmpty) {
      LoggerService.warn('⚠️ Backend URL not configured, using local fallback');
      return HybridResponse.error(
        'Backend no configurado',
        provider: 'backend',
        errorCode: 'BACKEND_URL_MISSING',
      );
    }

    try {
      final url = Uri.parse('$_backendUrl/api/chat/hybrid');
      final headers = _buildHeaders();
      final body = jsonEncode({
        'prompt': prompt,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
      });

      LoggerService.info('📤 Backend request to: $url');

      for (int attempt = 0; attempt < _maxRetries; attempt++) {
        try {
          final response = await http
              .post(
                url,
                headers: headers,
                body: body,
              )
              .timeout(Duration(seconds: _requestTimeoutSeconds));

          stopwatch.stop();

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            LoggerService.info(
                '✅ Backend response (${stopwatch.elapsedMilliseconds}ms): ${data['response']?.toString().substring(0, 50)}...');

            return HybridResponse.success(
              data['response'] as String? ?? 'Sin respuesta del backend',
              provider: data['provider'] as String? ?? 'backend',
              model: data['model'] as String?,
              latencyMs: stopwatch.elapsedMilliseconds,
              cascadeLog: data['cascade_log'] as Map<String, dynamic>?,
            );
          } else if (response.statusCode == 503 && attempt < _maxRetries - 1) {
            // Service temporarily unavailable, retry
            LoggerService.warn(
                '⏳ Backend unavailable (503), retrying... (attempt ${attempt + 1}/$_maxRetries)');
            await Future.delayed(Duration(seconds: (attempt + 1) * 2));
            continue;
          } else {
            LoggerService.error(
              'Backend HTTP error',
              Exception('Status ${response.statusCode}'),
            );
            return HybridResponse.error(
              'Error del backend: ${response.statusCode}',
              provider: 'backend',
              errorCode: 'HTTP_${response.statusCode}',
            );
          }
        } on TimeoutException {
          if (attempt < _maxRetries - 1) {
            LoggerService.warn(
                '⏱️ Backend timeout, retrying... (attempt ${attempt + 1}/$_maxRetries)');
            await Future.delayed(Duration(seconds: (attempt + 1) * 2));
            continue;
          }
          LoggerService.error('Backend timeout', TimeoutException('30s exceeded'));
          return HybridResponse.error(
            'Tiempo de espera agotado al conectar con el backend',
            provider: 'backend',
            errorCode: 'TIMEOUT',
          );
        }
      }

      return HybridResponse.error(
        'Backend no disponible después de múltiples intentos',
        provider: 'backend',
        errorCode: 'MAX_RETRIES_EXCEEDED',
      );
    } catch (e, st) {
      stopwatch.stop();
      LoggerService.error('Backend communication error', e, stackTrace: st);
      return HybridResponse.error(
        'Error conectando con backend: $e',
        provider: 'backend',
        errorCode: 'CONNECTION_ERROR',
      );
    }
  }

  /// GET /api/system-status - Health check
  Future<Map<String, dynamic>> getSystemStatus() async {
    if (_backendUrl.isEmpty) {
      return {
        'status': 'offline',
        'backend_url': 'not_configured',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }

    try {
      final url = Uri.parse('$_backendUrl/api/system-status');
      final response = await http
          .get(
            url,
            headers: _buildHeaders(),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {
        'status': 'error',
        'statusCode': response.statusCode,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      LoggerService.warn('System status check failed: $e');
      return {
        'status': 'unreachable',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Build request headers with auth token
  Map<String, String> _buildHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }
}
