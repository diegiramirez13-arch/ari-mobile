import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_config.dart';
import '../models/chat_message.dart';
import '../models/chat_mode.dart';
import '../services/ai_service.dart';
import 'profile_provider.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  const apiKey = String.fromEnvironment('OPENAI_API_KEY');
  return AIService(apiKey: apiKey.isEmpty ? null : apiKey);
});

final chatConfigProvider = Provider<ChatConfig>((ref) {
  final profile = ref.watch(profileControllerProvider).value;
  const apiKey = String.fromEnvironment('OPENAI_API_KEY');
  return ChatConfig.fromEnvironment(
    apiKey: apiKey,
    isProUser: profile?.isProUser ?? false,
  );
});

typedef Message = ChatMessage;

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final ChatMode mode;
  final String? error;

  const ChatState({
    required this.messages,
    this.isLoading = false,
    this.mode = ChatMode.basic,
    this.error,
  });

  factory ChatState.initial({required bool isProMode}) {
    final initialMode = isProMode ? ChatMode.pro : ChatMode.basic;
    final now = DateTime.now();

    return ChatState(
      messages: [
        ChatMessage(
          id: now.microsecondsSinceEpoch.toString(),
          content: '¡Hola Diego! Soy ARI. ¿Qué vamos a construir hoy?',
          isUser: false,
          timestamp: now,
        ),
      ],
      mode: initialMode,
    );
  }

  bool get isProMode => mode == ChatMode.pro || mode == ChatMode.enterprise;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    ChatMode? mode,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      mode: mode ?? this.mode,
      error: error,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  ChatController(this._aiService, {required bool isProMode})
      : super(ChatState.initial(isProMode: isProMode));

  final AIService _aiService;

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      content: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    try {
      final responseText = await _aiService.generateResponse(trimmed);
      final aiMsg = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        content: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isLoading: false,
        error: null,
      );
    } catch (_) {
      final errorMsg = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        content: 'Error procesando solicitud en el orquestador.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );

      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isLoading: false,
        error: 'Error procesando solicitud en el orquestador.',
      );
    }
  }

  void toggleMode() {
    final nextMode = state.mode == ChatMode.pro ? ChatMode.basic : ChatMode.pro;
    final feedback = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      content: 'Modo cambiado a ${nextMode == ChatMode.pro ? 'PRO' : 'BÁSICO'}',
      isUser: false,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      mode: nextMode,
      messages: [...state.messages, feedback],
    );
  }

  void clearChat() {
    final now = DateTime.now();
    state = ChatState(
      messages: [
        ChatMessage(
          id: now.microsecondsSinceEpoch.toString(),
          content: '¡Hola Diego! Soy ARI. ¿Qué vamos a construir hoy?',
          isUser: false,
          timestamp: now,
        ),
      ],
      mode: state.mode,
      isLoading: false,
      error: null,
    );
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  final config = ref.watch(chatConfigProvider);
  final aiService = ref.watch(aiServiceProvider);
  return ChatController(aiService, isProMode: config.isProMode);
});

final aiProvider = chatControllerProvider;

final hasAIProvider = Provider<bool>((ref) {
  return ref.watch(aiServiceProvider).isAvailable;
});
