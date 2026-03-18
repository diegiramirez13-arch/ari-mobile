import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_config.dart';
import '../services/ai_service.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

final firestoreChatServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

final aiServiceProvider = Provider<AIService>((ref) => AIService());

final chatConfigProvider = Provider<ChatConfig>((ref) {
  return ChatConfig.fromEnvironment();
});

class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  const Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}

typedef ChatMessage = Message;

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
  static final RegExp _createProjectTagPattern = RegExp(
    r'\[ACTION:CREATE_PROJECT:([^\]]+)\]',
  );

  final AIService _aiService;
  final FirestoreService _firestoreService;
  final ChatConfig _config;
  final String? _userId;

  StreamSubscription<List<Map<String, dynamic>>>? _chatSubscription;

  ChatController(
    this._aiService,
    this._firestoreService,
    this._config,
    this._userId,
  ) : super(
          ChatState(
            config: _config,
            messages: [
              Message(
                id: 'welcome',
                content:
                    '¡Hola! Soy ARI. ¿En qué plan de acción trabajamos hoy?',
                isUser: false,
                timestamp: DateTime.now(),
              ),
            ],
          ),
        ) {
    _initChat();
  }

  void _initChat() {
    if (_userId == null) return;

    _chatSubscription =
        _firestoreService.getChatHistoryStream(_userId).listen((messages) {
      if (messages.isEmpty) {
        state = state.copyWith(messages: [_welcomeMessage()]);
        return;
      }

      state = state.copyWith(
        messages: messages.map(_messageFromMap).toList(),
        isLoading: false,
        error: null,
      );
    });
  }

  Message _welcomeMessage() {
    return Message(
      id: 'welcome',
      content: '¡Hola! Soy ARI. ¿En qué plan de acción trabajamos hoy?',
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  Message _messageFromMap(Map<String, dynamic> raw) {
    final timestamp = raw['timestamp'];
    final resolvedTimestamp = timestamp is Timestamp
        ? timestamp.toDate()
        : DateTime.now();
    final content = (raw['message'] ?? raw['text'] ?? '').toString();

    return Message(
      id: raw['id']?.toString() ??
          '${resolvedTimestamp.microsecondsSinceEpoch}-${raw['isUser']}',
      content: content,
      isUser: raw['isUser'] == true,
      timestamp: resolvedTimestamp,
      isError: raw['isError'] == true,
    );
  }

  Future<String> _executeDetectedActions(String response) async {
    final match = _createProjectTagPattern.firstMatch(response);
    if (match == null) {
      return response;
    }

    final projectName = match.group(1)?.trim() ?? '';
    if (projectName.isEmpty || _userId == null) {
      return response.replaceFirst(_createProjectTagPattern, '').trim();
    }

    await _firestoreService.createProject(projectName, userId: _userId);
    final replacement = '🚀 Proyecto "$projectName" creado en tu lista.';
    return response.replaceFirst(_createProjectTagPattern, replacement).trim();
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...state.messages, userMessage];
    state = state.copyWith(
      messages: updatedMessages,
      isLoading: true,
      error: null,
    );

    if (_userId != null) {
      await _firestoreService.saveMessage(trimmed, true, userId: _userId);
    }

    String response;
    var isError = false;

    if (_config.isProMode) {
      final history = updatedMessages
          .map(
            (message) => {
              'role': message.isUser ? 'user' : 'assistant',
              'content': message.content,
            },
          )
          .toList();

      response = await _aiService.generateResponse(history);
      response = await _executeDetectedActions(response);
      isError = response.startsWith('Error') || response.startsWith('Fallo');
    } else {
      response = 'Modo básico: Recibido. ¿Querés que lo agende como proyecto?';
    }

    final assistantMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response,
      isUser: false,
      timestamp: DateTime.now(),
      isError: isError,
    );

    if (_userId != null) {
      await _firestoreService.saveMessage(
        response,
        false,
        userId: _userId,
        isError: isError,
      );
    }

    if (_userId == null) {
      state = state.copyWith(
        messages: [...updatedMessages, assistantMessage],
        isLoading: false,
        error: isError ? response : null,
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      error: isError ? response : null,
    );
  }

  Future<void> clearChat() async {
    _aiService.clearHistory();

    if (_userId != null) {
      await _firestoreService.clearChatHistory(_userId);
      return;
    }

    state = state.copyWith(
      messages: [_welcomeMessage()],
      isLoading: false,
      error: null,
    );
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
    _chatSubscription?.cancel();
    super.dispose();
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  final firestoreService = ref.watch(firestoreChatServiceProvider);
  final config = ref.watch(chatConfigProvider);
  final userId = ref.watch(currentUserIdProvider);

  return ChatController(aiService, firestoreService, config, userId);
});

final chatMessagesProvider = Provider<List<Message>>(
  (ref) => ref.watch(chatControllerProvider).messages,
);

final chatIsLoadingProvider = Provider<bool>(
  (ref) => ref.watch(chatControllerProvider).isLoading,
);
