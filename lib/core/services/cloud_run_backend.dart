import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../config/cloud_secrets.dart';
import '../models/ai_response.dart';
import 'logger_service.dart';

/// Secure client for the ARI Cloud Run backend.
///
/// The mobile app never talks to model providers directly in production. It
/// sends Firebase-authenticated requests to Cloud Run, where secrets are kept in
/// Google Secret Manager and the backend orchestrates OpenAI, Kimi, and Gemini.
class CloudRunBackend {
  CloudRunBackend({
    String? backendUrl,
    FirebaseAuth? auth,
    http.Client? client,
  })  : _backendUrl = _normalizeBackendUrl(backendUrl ?? CloudSecrets.backendUrl),
        _auth = auth ?? FirebaseAuth.instance,
        _client = client ?? http.Client();

  final String _backendUrl;
  final FirebaseAuth _auth;
  final http.Client _client;

  static const Duration _chatTimeout = Duration(seconds: 30);
  static const Duration _healthTimeout = Duration(seconds: 5);

  static String _normalizeBackendUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  /// Gets the Firebase ID token used by Cloud Run to authorize requests.
  Future<String?> _getIdToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }
      return user.getIdToken();
    } catch (error, stackTrace) {
      LoggerService.error(
        'Error obteniendo ID token de Firebase',
        error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Sends a prompt to the production hybrid orchestrator endpoint.
  Future<AIResponse> sendMessageToOrchestrator(String prompt) async {
    try {
      final token = await _getIdToken();
      if (token == null) {
        return AIResponse.error(
          'No autenticado. Inicia sesión primero.',
          code: 'NOT_AUTHENTICATED',
        );
      }

      final response = await _client
          .post(
            Uri.parse('$_backendUrl/api/chat/hybrid'),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'prompt': prompt,
              'userId': _auth.currentUser?.uid,
              'timestamp': DateTime.now().toUtc().toIso8601String(),
            }),
          )
          .timeout(_chatTimeout);

      return _parseChatResponse(response);
    } catch (error, stackTrace) {
      LoggerService.error(
        'Error en Cloud Run Backend',
        error,
        stackTrace: stackTrace,
      );
      return AIResponse.error(
        'Error de conexión con Cloud Run: $error',
        code: 'NETWORK_ERROR',
      );
    }
  }

  AIResponse _parseChatResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final text = data['response'] as String? ?? 'Sin respuesta';
        final backend = data['backend'] as String? ?? 'unknown';
        final tokens = data['tokensUsed'] as int?;

        LoggerService.info('Respuesta recibida desde $backend');
        return AIResponse.success(
          text,
          tokens: tokens,
          metadata: {'backend': backend},
        );
      case 401:
        return AIResponse.error(
          'Token inválido o expirado',
          code: 'INVALID_TOKEN',
        );
      case 503:
        return AIResponse.error(
          'Backend temporalmente no disponible',
          code: 'SERVICE_UNAVAILABLE',
        );
      default:
        return AIResponse.error(
          'Error ${response.statusCode}: ${response.body}',
          code: 'BACKEND_ERROR',
        );
    }
  }

  /// Activates a paid plan after PayPal validation by the backend.
  Future<bool> activatePlan({
    required String planId,
    required String transactionId,
  }) async {
    try {
      final token = await _getIdToken();
      if (token == null) {
        return false;
      }

      final response = await _client.post(
        Uri.parse('$_backendUrl/api/paypal/activate-plan'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'planId': planId,
          'transactionId': transactionId,
          'userId': _auth.currentUser?.uid,
        }),
      );

      if (response.statusCode == 200) {
        LoggerService.info('Plan $planId activado correctamente');
        return true;
      }

      LoggerService.error(
        'Error activando plan',
        'Status: ${response.statusCode}; Body: ${response.body}',
      );
      return false;
    } catch (error, stackTrace) {
      LoggerService.error(
        'Error en activatePlan',
        error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Returns whether the Cloud Run service is healthy and reachable.
  Future<bool> healthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$_backendUrl/api/system-status'))
          .timeout(_healthTimeout);

      return response.statusCode == 200;
    } catch (error, stackTrace) {
      LoggerService.error(
        'Health check de Cloud Run fallido',
        error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}
