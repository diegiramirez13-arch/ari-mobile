import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_config.dart';
import '../models/chat_error.dart';
import '../services/ai_service.dart';

// Providers
final chatConfigProvider = Provider<ChatConfig>((ref) {
  return ChatConfig.fromEnvironment();
});

final aiServiceProvider = Provider<AIService>((ref) {
  final config = ref.watch(chatConfigProvider);
  return AIService(config);
});

// Estado
class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final ChatError? error;
  final ChatConfig config;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    required this.config,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    ChatError? error,
    bool clearError = false,
    ChatConfig? config,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      config: config ?? this.config,
    );
  }
}

class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

// Controller
class ChatController extends StateNotifier<ChatState> {
  final AIService _aiService;

  ChatController(this._aiService)
      : super(ChatState(config: ChatConfig.fromEnvironment()));

  String get modeExplanation => state.config.isProMode
      ? 'Modo Pro (${state.config.model})'
      : 'Modo Básico - agregá OPENAI_API_KEY';

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      clearError: true,
    );

    final reply = await _aiService.sendMessage(text);

    final botMsg = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: reply,
      isUser: false,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, botMsg],
      isLoading: false,
    );
  }

  void clearChat() {
    _aiService.clearHistory();
    state = state.copyWith(messages: [], clearError: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  final service = ref.watch(aiServiceProvider);
  return ChatController(service);
});

final chatMessagesProvider = Provider<List<Message>>(
  (ref) => ref.watch(chatControllerProvider).messages,
);

final chatIsLoadingProvider = Provider<bool>(
  (ref) => ref.watch(chatControllerProvider).isLoading,
);
