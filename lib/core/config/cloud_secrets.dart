import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized cloud configuration and secret lookup.
///
/// Client builds should only contain public configuration. Provider API secrets
/// are read here for local development compatibility, but production requests
/// must use Cloud Run so private keys stay server-side in Secret Manager.
class CloudSecrets {
  CloudSecrets._();

  static const String _productionBackendUrl =
      'https://ari-backend-prod.a.run.app';
  static const List<String> _backendUrlKeys = <String>[
    'BACKEND_URL',
    'CLOUD_RUN_BACKEND_URL',
  ];

  static String get openaiKey => _read('OPENAI_API_KEY');

  static String get kimiKey => _read('KIMI_API_KEY');

  static String get geminiKey => _read('GEMINI_API_KEY');

  static String get paypalClientId => _read('PAYPAL_CLIENT_ID');

  /// PayPal secret must never be shipped in production client builds.
  static String get paypalSecret {
    if (kReleaseMode) {
      return '';
    }
    return _read('PAYPAL_SECRET');
  }

  static bool get hasConfiguredBackendUrl {
    return _readAny(_backendUrlKeys).isNotEmpty;
  }

  static String get backendUrl {
    final configured = _readAny(_backendUrlKeys);
    if (configured.isNotEmpty) {
      return configured;
    }

    return kDebugMode ? 'http://localhost:3000' : _productionBackendUrl;
  }

  static String get firebaseProject =>
      _read('FIREBASE_PROJECT', defaultValue: 'ari-ai-prod');

  static String _read(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ??
        String.fromEnvironment(key, defaultValue: defaultValue);
  }

  static String _readAny(List<String> keys, {String defaultValue = ''}) {
    for (final key in keys) {
      final value = _read(key);
      if (value.isNotEmpty) {
        return value;
      }
    }
    return defaultValue;
  }

  /// Emits safe configuration warnings without printing any secret values.
  static void validate() {
    final errors = <String>[];

    if (openaiKey.isEmpty && kimiKey.isEmpty && geminiKey.isEmpty) {
      errors.add(
        'Al menos una API de IA debe estar configurada para fallback local '
        '(OPENAI_API_KEY, KIMI_API_KEY o GEMINI_API_KEY).',
      );
    }

    if (backendUrl.isEmpty) {
      errors.add('BACKEND_URL o CLOUD_RUN_BACKEND_URL no configurada.');
    }

    if (errors.isNotEmpty) {
      debugPrint('⚠️ Advertencias de configuración Cloud:');
      for (final error in errors) {
        debugPrint('  - $error');
      }
    }
  }

  /// Returns secret availability only; never returns raw secret values.
  static Map<String, bool> getSecretsStatus() {
    return <String, bool>{
      'OpenAI': openaiKey.isNotEmpty,
      'Kimi': kimiKey.isNotEmpty,
      'Gemini': geminiKey.isNotEmpty,
      'PayPal Client ID': paypalClientId.isNotEmpty,
      'Backend URL': backendUrl.isNotEmpty,
      'Firebase Project': firebaseProject.isNotEmpty,
    };
  }

  static String redactKey(String? key) {
    if (key == null || key.isEmpty) {
      return '[EMPTY]';
    }
    if (key.length < 10) {
      return '[INVALID]';
    }
    return '${key.substring(0, 6)}...${key.substring(key.length - 4)}';
  }
}
