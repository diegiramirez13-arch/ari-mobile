import 'package:flutter/foundation.dart';

class AppEnvironment {
  static String get openAiApiKey => const String.fromEnvironment('OPENAI_API_KEY');

  static bool get hasOpenAiKey => openAiApiKey.trim().isNotEmpty;
}

void configureEnvironment() {
  if (kDebugMode) {
    debugPrint(
      'Environment configured. OPENAI_API_KEY: '
      '${AppEnvironment.hasOpenAiKey ? 'present' : 'missing'}',
    );
  }
}
