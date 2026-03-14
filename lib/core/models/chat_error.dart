sealed class ChatError {
  final String message;
  const ChatError(this.message);
}

class NetworkError extends ChatError {
  const NetworkError() : super('Sin conexión. Modo offline disponible.');
}

class ApiError extends ChatError {
  const ApiError(String details) : super('Error IA: $details');
}
