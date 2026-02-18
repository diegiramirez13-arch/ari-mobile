import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat_logic.dart';
import 'message.dart';

final chatErrorProvider = StateProvider<String?>((ref) => null);

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

  void sendMessage(String rawText) {
    final text = rawText.trim();
    if (text.isEmpty) {
      ref.read(chatErrorProvider.notifier).state =
          'Escribe un mensaje antes de enviar.';
      return;
    }

    ref.read(chatErrorProvider.notifier).state = null;
    state = [
      ...state,
      Message(text: text, isUser: true),
      Message(text: _logic.nextMessage(text), isUser: false),
    ];
  }
}
