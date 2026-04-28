import '../config/environment.dart';

class ChatConfig {
  final String model;
  final double temperature;
  final int maxTokens;
  final bool isProMode;
  final String backend;

  const ChatConfig({
    this.model = 'gpt-4o-mini',
    this.temperature = 0.7,
    this.maxTokens = 1000,
    this.isProMode = true,
    this.backend = 'openai',
  });

  factory ChatConfig.fromEnvironment({String? apiKey, bool? isProUser}) {
    final resolvedKey = apiKey ?? Environment.openAiApiKey;
    final proByKey = resolvedKey.isNotEmpty;
    final proByUser = isProUser ?? false;
    return ChatConfig(
      isProMode: proByKey && proByUser,
      backend: proByKey ? 'openai' : 'basic',
    );
  }

  bool get hasKey => isProMode;
  bool get enableAI => isProMode;
}
