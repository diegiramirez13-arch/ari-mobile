import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/providers/firestore_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/services/ai_service.dart';
import 'chat_logic.dart';
import 'chat_memory_repository.dart';
import 'message.dart';

final chatErrorProvider = StateProvider<String?>((ref) => null);

final preferredAiProvider = StateProvider<AiProvider>((ref) => AiProvider.openai);

final chatMemoryRepositoryProvider = Provider<ChatMemoryRepository>((ref) {
  return ChatMemoryRepository();
});

final aiServiceProvider = Provider<AiService>((ref) {
  final dio = Dio();
  return AiService({
    AiProvider.openai: OpenAiBackend(dio),
    AiProvider.mistral: MistralBackend(dio),
  });
});

final chatControllerProvider = NotifierProvider<ChatController, List<Message>>(
  ChatController.new,
);

class ChatController extends Notifier<List<Message>> {
  late final ChatLogic _logic;

  @override
  List<Message> build() {
    _logic = ChatLogic();
    ref.read(chatErrorProvider.notifier).state = null;
    return [
      Message(text: _logic.nextMessage(''), isUser: false),
    ];
  }

  Future<void> sendMessage(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) {
      ref.read(chatErrorProvider.notifier).state =
          'Escribe un mensaje antes de enviar.';
      return;
    }

    ref.read(chatErrorProvider.notifier).state = null;

    final userId = ref.read(currentUserIdProvider);
    final firestore = ref.read(firestoreServiceProvider);
    final memoryRepo = ref.read(chatMemoryRepositoryProvider);
    final profile = ref.read(profileControllerProvider).valueOrNull;
    final isPro = profile?.isPro ?? false;

    String assistantResponse;
    if (isPro) {
      final preferredProvider = ref.read(preferredAiProvider);
      final aiService = ref.read(aiServiceProvider);
      final contextSummary =
          userId == null ? null : await memoryRepo.getSummary(userId);

      assistantResponse = await aiService.generateResponse(
        provider: preferredProvider,
        request: AiRequest(
          systemPrompt: AiService.ariSystemPrompt(),
          userPrompt: text,
          contextSummary: contextSummary,
        ),
      );
    } else {
      assistantResponse = _logic.nextMessage(text);
    }

    state = [
      ...state,
      Message(text: text, isUser: true),
      Message(text: assistantResponse, isUser: false),
    ];

    if (userId != null) {
      try {
        await firestore.saveChatMessage(userId, text, true);
        await firestore.saveChatMessage(userId, assistantResponse, false);
        await memoryRepo.saveRelevantSummary(userId, state);
      } catch (_) {
        ref.read(chatErrorProvider.notifier).state =
            'Mensaje enviado, pero no se pudo sincronizar el historial.';
      }
    }
  }
}
