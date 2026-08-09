import 'ai_metadata.dart';

/// Response from the hybrid orchestrator with full tracing
class HybridResponse {
  final String text;
  final AIMetadata metadata;
  final bool isError;
  final String? errorMessage;
  final Map<String, dynamic>? cascadeLog; // All attempted providers

  HybridResponse({
    required this.text,
    required this.metadata,
    this.isError = false,
    this.errorMessage,
    this.cascadeLog,
  });

  factory HybridResponse.success(
    String text, {
    required String provider,
    String? model,
    required int latencyMs,
    Map<String, dynamic>? cascadeLog,
  }) {
    return HybridResponse(
      text: text,
      metadata: AIMetadata(
        provider: provider,
        model: model,
        latencyMs: latencyMs,
      ),
      cascadeLog: cascadeLog,
    );
  }

  factory HybridResponse.error(
    String message, {
    required String provider,
    required String errorCode,
    Map<String, dynamic>? cascadeLog,
  }) {
    return HybridResponse(
      text: message,
      metadata: AIMetadata(
        provider: provider,
        latencyMs: 0,
        errorCode: errorCode,
      ),
      isError: true,
      errorMessage: message,
      cascadeLog: cascadeLog,
    );
  }

  Map<String, dynamic> toMap() => {
    'text': text,
    'metadata': metadata.toMap(),
    'isError': isError,
    'errorMessage': errorMessage,
    'cascadeLog': cascadeLog,
  };

  @override
  String toString() => '${metadata.provider}: $text';
}
