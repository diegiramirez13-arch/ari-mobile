import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_config.dart';
import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';
import '../services/ai_service.dart';
import 'auth_provider.dart';
import 'profile_provider.dart';

final aiServiceProvider = Provider<AIService>((ref) => AIService());

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final chatConfigProvider = Provider<ChatConfig>((ref) {
  final profile = ref.watch(profileControllerProvider).value;
  return ChatConfig.fromEnvironment(isProUser: profile?.isProUser ?? false);
});

typedef Message = ChatMessage;

class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final String? error;
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

class ChatController extends StateNotifier<ChatState> {
  ChatController(this.ref, this._aiService, this._chatRepository, this._config)
      : super(ChatState(config: _config)) {
    _bootstrap();
  }

  final Ref ref;
  final AIService _aiService;
  final ChatRepository _chatRepository;
  final ChatConfig _config;
  StreamSubscription<List<ChatMessage>>? _messagesSub;

  String? get _uid => ref.read(authProvider).value?.uid;

  Future<void> _bootstrap() async {
    final uid = _uid;
    if (uid == null) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final history = await _chatRepository.loadMessages(uid);
      state = state.copyWith(messages: history, isLoading: false);

      _messagesSub?.cancel();
      _messagesSub = _chatRepository.watchMessages(uid).listen((messages) {
        state = state.copyWith(messages: messages);
      });
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'No se pudo cargar historial: $e',
      );
    }
  }

  Future<void> sendMessage(String text) async {
    final uid = _uid;
    if (uid == null || text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    await _chatRepository.saveMessage(uid, userMessage);

    if (!state.config.isProMode) {
      final botMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Modo básico activo. Configurá OPENAI_API_KEY para usar IA.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      await _chatRepository.saveMessage(uid, botMessage);
      state = state.copyWith(
        messages: [...state.messages, botMessage],
        isLoading: false,
      );
      return;
    }

    try {
      final response = await _aiService.sendMessage(text);
      final botMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      await _chatRepository.saveMessage(uid, botMessage);
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

  Future<void> clearChat() async {
    final uid = _uid;
    if (uid == null) return;

    _aiService.clearHistory();
    await _chatRepository.clearMessages(uid);
    state = state.copyWith(messages: []);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    super.dispose();
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  ref.watch(authProvider);
  final aiService = ref.watch(aiServiceProvider);
  final repo = ref.watch(chatRepositoryProvider);
  final config = ref.watch(chatConfigProvider);
  return ChatController(ref, aiService, repo, config);
});

final chatMessagesProvider = Provider<List<Message>>(
  (ref) => ref.watch(chatControllerProvider).messages,
);

final chatIsLoadingProvider = Provider<bool>(
  (ref) => ref.watch(chatControllerProvider).isLoading,
);
