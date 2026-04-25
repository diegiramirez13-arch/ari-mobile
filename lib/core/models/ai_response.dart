class AIResponse {
  final String text;
  final bool isError;
  final String? errorCode;
  final DateTime timestamp;
  final int? tokensUsed;

  const AIResponse({
    required this.text,
    this.isError = false,
    this.errorCode,
    this.tokensUsed,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AIResponse.error(String message, {String? code}) {
    return AIResponse(
      text: message,
      isError: true,
      errorCode: code ?? 'UNKNOWN_ERROR',
    );
  }

  factory AIResponse.success(String message, {int? tokens}) {
    return AIResponse(
      text: message,
      tokensUsed: tokens,
    );
  }
}
