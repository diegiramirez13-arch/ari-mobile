import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_logic.dart';

final chatLogicProvider = StateProvider<ChatLogic>((ref) {
  return ChatLogic();
});
