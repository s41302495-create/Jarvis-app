import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryService {
  static const _historyKey = 'jarvis2_chat_history';
  static const _memoryKey = 'jarvis2_memories';

  Future<List<Map<String, dynamic>>> loadHistory() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_historyKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) { return []; }
  }

  Future<void> saveHistory(List<Map<String, dynamic>> messages) async {
    final p = await SharedPreferences.getInstance();
    final clipped = messages.length > 300 ? messages.sublist(messages.length - 300) : messages;
    await p.setString(_historyKey, jsonEncode(clipped));
  }

  Future<List<String>> loadMemories() async {
    final p = await SharedPreferences.getInstance();
    return p.getStringList(_memoryKey) ?? [];
  }

  Future<void> addMemory(String value) async {
    final clean = value.trim();
    if (clean.isEmpty) return;
    final p = await SharedPreferences.getInstance();
    final items = p.getStringList(_memoryKey) ?? [];
    if (!items.any((x) => x.toLowerCase() == clean.toLowerCase())) {
      items.add(clean);
      await p.setStringList(_memoryKey, items);
    }
  }

  Future<void> deleteMemory(String value) async {
    final p = await SharedPreferences.getInstance();
    final items = p.getStringList(_memoryKey) ?? [];
    items.remove(value);
    await p.setStringList(_memoryKey, items);
  }

  Future<void> clearAll() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_historyKey);
    await p.remove(_memoryKey);
  }

  // Lightweight on-device extraction. Full AI-assisted memory extraction can be added later.
  Future<void> learnFromUserMessage(String message) async {
    final text = message.trim();
    final patterns = [
      RegExp(r"^(?:remember that\s+)?my name is (.+)$", caseSensitive: false),
      RegExp(r"^(?:remember that\s+)?i prefer (.+)$", caseSensitive: false),
      RegExp(r"^(?:remember that\s+)?i like (.+)$", caseSensitive: false),
      RegExp(r"^(?:remember that\s+)?i am working on (.+)$", caseSensitive: false),
      RegExp(r"^(?:remember that\s+)?i'm working on (.+)$", caseSensitive: false),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        await addMemory(text);
        break;
      }
    }
    if (text.toLowerCase().startsWith('remember that ')) await addMemory(text.substring(14));
  }
}
