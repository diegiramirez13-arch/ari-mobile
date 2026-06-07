class AIResponse {
  final String text;
  final bool isError;
  final String? errorCode;
  final DateTime timestamp;
  final int? tokensUsed;
  final Map<String, Object?> metadata;

  AIResponse({
    required this.text,
    this.isError = false,
    this.errorCode,
    this.tokensUsed,
    this.metadata = const <String, Object?>{},
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AIResponse.error(
    String message, {
    String? code,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) {
    return AIResponse(
      text: message,
      isError: true,
      errorCode: code ?? 'UNKNOWN_ERROR',
      metadata: metadata,
    );
  }

  factory AIResponse.success(
    String message, {
    int? tokens,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) {
    return AIResponse(
      text: message,
      tokensUsed: tokens,
      metadata: metadata,
    );
  }
}
