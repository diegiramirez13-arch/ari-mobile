import '../config/environment.dart';

class ChatConfig {
  final String model;
  final double temperature;
  final int maxTokens;
  final bool isProMode;

  const ChatConfig({
    this.model = 'gpt-4o-mini',
    this.temperature = 0.7,
    this.maxTokens = 1000,
    this.isProMode = true,
  });

  factory ChatConfig.fromEnvironment({String? apiKey}) {
    final resolvedKey = apiKey ?? Environment.openAiApiKey;
    return ChatConfig(isProMode: resolvedKey.isNotEmpty);
  }

  bool get hasKey => isProMode;
  bool get enableAI => isProMode;
}
