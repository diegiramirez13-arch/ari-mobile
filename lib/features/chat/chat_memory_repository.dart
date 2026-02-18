import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'message.dart';

class ChatMemoryRepository {
  static const _summaryPrefix = 'chat_summary_';

  Future<String?> getSummary(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_summaryPrefix$userId');
  }

  Future<void> saveRelevantSummary(String userId, List<Message> messages) async {
    final userMessages = messages
        .where((m) => m.isUser)
        .map((m) => _sanitize(m.text))
        .where((m) => m.isNotEmpty)
        .toList();

    final recent = userMessages.length <= 5
        ? userMessages
        : userMessages.sublist(userMessages.length - 5);

    final summary = jsonEncode({
      'updatedAt': DateTime.now().toIso8601String(),
      'topics': recent,
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_summaryPrefix$userId', summary);
  }

  String _sanitize(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final withoutEmails = trimmed.replaceAll(RegExp(r'\S+@\S+'), '[email]');
    final withoutPhones = withoutEmails.replaceAll(RegExp(r'\+?\d[\d\s-]{6,}\d'), '[telefono]');

    return withoutPhones.length > 200
        ? withoutPhones.substring(0, 200)
        : withoutPhones;
  }
}
