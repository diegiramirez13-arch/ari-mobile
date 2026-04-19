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

// Configuración del chat
final chatConfigProvider = Provider<ChatConfig>((ref) {
  final profile = ref.watch(profileControllerProvider).value;
  return ChatConfig.fromEnvironment(isProUser: profile?.isProUser ?? false);
});

// Estado del chat
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final ChatConfig config;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    required this.config,
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
    String? error,
    ChatConfig? config,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      config: config ?? this.config,
    );
  }

  bool get isProMode => config.isProMode;
}

// Controller con StateNotifier
class ChatController extends StateNotifier<ChatState> {
  final ChatRepository _repository;
  final String _userId;
  ProviderSubscription<AsyncValue<List<ChatMessage>>>? _historySubscription;

  ChatController(
    this._repository,
    this._userId,
    ChatConfig config,
  ) : super(ChatState.initial(config));

  void bindHistory(Ref ref) {
    if (_userId.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }

    _historySubscription?.close();
    _historySubscription = ref.listenManual<AsyncValue<List<ChatMessage>>>(
      chatHistoryMessagesProvider(_userId),
      (previous, next) {
        final history = next.value;
        if (history == null) return;
        state = state.copyWith(
          messages: history.reversed.toList(),
          isLoading: false,
        );
      },
      fireImmediately: true,
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Agregar mensaje del usuario
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
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
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearChat() {
    state = state.copyWith(messages: []);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void toggleMode() {
    state = state.copyWith(
      error:
          'El modo está definido por OPENAI_API_KEY. Configurá esa variable para activar/desactivar Pro.',
    );
  }

  @override
  void dispose() {
    _historySubscription?.close();
    super.dispose();
  }
}

// Provider del controller
final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  final config = ref.watch(chatConfigProvider);
  final userId = ref.watch(currentUserIdProvider) ?? '';

  final controller = ChatController(repository, userId, config);
  controller.bindHistory(ref);
  return controller;
});

final chatHistoryMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getChatHistory(userId);
});

final chatMessagesProvider = Provider<List<ChatMessage>>(
  (ref) => ref.watch(chatControllerProvider).messages,
);

final chatIsLoadingProvider = Provider<bool>(
  (ref) => ref.watch(chatControllerProvider).isLoading,
);
