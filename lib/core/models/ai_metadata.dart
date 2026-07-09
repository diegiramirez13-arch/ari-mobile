/// Metadata about an AI response from the orchestrator
class AIMetadata {
  final String provider;        // 'backend', 'openai', 'gemini'
  final String? model;          // 'gpt-4o-mini', 'gemini-1.5-flash', etc.
  final int latencyMs;          // Response time in milliseconds
  final String? errorCode;      // Error code if failed
  final DateTime timestamp;

  AIMetadata({
    required this.provider,
    this.model,
    required this.latencyMs,
    this.errorCode,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'provider': provider,
    'model': model,
    'latencyMs': latencyMs,
    'errorCode': errorCode,
    'timestamp': timestamp.toIso8601String(),
  };

  factory AIMetadata.fromMap(Map<String, dynamic> map) => AIMetadata(
    provider: map['provider'] as String? ?? 'unknown',
    model: map['model'] as String?,
    latencyMs: map['latencyMs'] as int? ?? 0,
    errorCode: map['errorCode'] as String?,
    timestamp: DateTime.tryParse(map['timestamp'] as String? ?? ''),
  );

  @override
  String toString() => '[$provider${model != null ? ':$model' : ''}] ${latencyMs}ms';
}
