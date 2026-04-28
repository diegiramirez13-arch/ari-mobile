import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_config.dart';
import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';
import '../services/ai_service.dart';
import 'auth_provider.dart';
import 'firestore_provider.dart';
import 'profile_provider.dart';

typedef Message = ChatMessage;

// Provider del servicio
final aiServiceProvider = Provider<AIService>((ref) => AIService());
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    ref.watch(aiServiceProvider),
    ref.watch(firestoreServiceProvider),
  );
});

final chatConfigProvider = Provider<ChatConfig>((ref) {
  return ChatConfig(hasKey: AppEnvironment.hasOpenAiKey);
});

// Estado del chat
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isProMode;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isProMode = false,
    this.error,
  });

  factory ChatState.initial(ChatConfig config) => ChatState(
        messages: const [],
        isLoading: true,
        error: null,
        config: config,
      );

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isProMode,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isProMode: isProMode ?? this.isProMode,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  final ChatRepository _repository;
  final String _userId;
  StreamSubscription<List<ChatMessage>>? _historySubscription;

  ChatController(
    this._repository,
    this._userId,
    ChatConfig config,
  ) : super(ChatState.initial(config)) {
    _init();
  }

  void _init() {
    if (_userId.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }

    _historySubscription?.cancel();
    _historySubscription = _repository.getMessages(_userId).listen(
      (messages) {
        state = state.copyWith(
          messages: messages.reversed.toList(),
          isLoading: false,
        );
      },
      onError: (_) {
        state = state.copyWith(
          isLoading: false,
          error: 'No se pudo sincronizar el historial.',
        );
      },
    );
  }

  Future<void> sendMessage(String text) async {
    final cleanedText = text.trim();
    if (cleanedText.isEmpty || state.isLoading) {
      return;
    }

    // Agregar mensaje del usuario
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...state.messages, userMessage];
    state = state.copyWith(
      messages: updatedMessages,
      isLoading: true,
      clearError: true,
    );

    if (_userId.isNotEmpty) {
      await _repository.saveMessage(_userId, userMessage);
    }

    // Modo Básico (sin IA)
    if (!state.config.isProMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      final botMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Modo básico activo. Configurá OPENAI_API_KEY para usar IA.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      if (_userId.isNotEmpty) {
        await _repository.saveMessage(_userId, botMessage);
      }
      state = state.copyWith(
        messages: [...state.messages, botMessage],
        isLoading: false,
      );
      return;
    }

    // Modo Pro (con OpenAI)
    try {
      final botMessage = await _repository.getAIResponse(
        text,
        state.messages,
      );
      if (_userId.isNotEmpty) {
        await _repository.saveMessage(_userId, botMessage);
      }
      state = state.copyWith(
        messages: [...state.messages, botMessage],
        isLoading: false,
      );

      if (response.isError) {
        _appendAssistantMessage(
          response.text,
          isError: true,
          error: response.errorMessage ?? 'No se pudo obtener respuesta de IA.',
        );
        return;
      }

      _appendAssistantMessage(response.text);
    } catch (e) {
      _appendAssistantMessage(
        'Lo siento, hubo un problema procesando tu mensaje.',
        isError: true,
        error: e.toString(),
      );
    }
  }

  void clearChat() {
    state = state.copyWith(messages: []);
  }

  void _appendAssistantMessage(
    String text, {
    bool isError = false,
    String? error,
  }) {
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          content: text,
          isUser: false,
          isError: isError,
          timestamp: DateTime.now(),
        ),
      ],
      isLoading: false,
      error: error,
      clearError: !isError,
    );
  }

  void toggleMode() {
    final hasKey = ref.read(chatConfigProvider).hasKey;
    if (!hasKey) {
      state = state.copyWith(
        error: 'No hay OPENAI_API_KEY configurada para activar modo Pro.',
      );
      return;
    }

    state = state.copyWith(isProMode: !state.isProMode, clearError: true);
  }

  void clearChat() {
    final wasPro = state.isProMode;
    state = ChatState(isProMode: wasPro);
    _initializeChat();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    _historySubscription?.cancel();
    super.dispose();
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  final config = ref.watch(chatConfigProvider);
  final userId = ref.watch(currentUserIdProvider) ?? '';

  return ChatController(repository, userId, config);
});

final chatMessagesProvider = Provider<List<ChatMessage>>(
  (ref) => ref.watch(chatControllerProvider).messages,
);

final chatIsLoadingProvider = Provider<bool>(
  (ref) => ref.watch(chatControllerProvider).isLoading,
);
