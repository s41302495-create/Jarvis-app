import 'package:flutter/material.dart';
import '../services/omni_route_service.dart';
import '../services/memory_service.dart';

class ChatItem {
  final String text;
  final bool isUser;
  const ChatItem(this.text, this.isUser);
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _service = OmniRouteService();
  final _memory = MemoryService();
  final List<ChatItem> _messages = [];
  bool _busy = false, _loaded = false;

  @override
  void initState() { super.initState(); _restore(); }
  Future<void> _restore() async {
    final saved = await _memory.loadHistory();
    if (!mounted) return;
    setState(() {
      _messages.addAll(saved.map((m) => ChatItem(m['content']?.toString() ?? '', m['role'] == 'user')));
      if (_messages.isEmpty) _messages.add(const ChatItem('JARVIS 2.0 online. I can save conversation history locally. Tell me “Remember that…” to save a fact.', false));
      _loaded = true;
    });
    _scrollToBottom();
  }
  @override
  void dispose() { _controller.dispose(); _scrollController.dispose(); super.dispose(); }

  Future<void> _persist() => _memory.saveHistory(_messages.map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text}).toList());

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _busy || !_loaded) return;
    _controller.clear();
    setState(() { _messages.add(ChatItem(text, true)); _busy = true; });
    await _memory.learnFromUserMessage(text);
    await _persist();
    _scrollToBottom();
    try {
      final memories = await _memory.loadMemories();
      final systemPrompt = '''You are JARVIS 2.0, a capable, friendly personal AI assistant. Always reply in English unless the user explicitly requests another language. Never switch languages unexpectedly. Be clear, useful and honest about limitations. Use the saved memories below when relevant, but do not claim to remember anything that is not listed.\n\nSaved memories:\n${memories.isEmpty ? 'No saved memories.' : memories.map((m) => '- $m').join('\n')}''';
      final conversation = <Map<String, String>>[
        {'role': 'system', 'content': systemPrompt},
        ..._messages.where((m) => !(m.text.startsWith('JARVIS 2.0 online.'))).map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text}),
      ];
      final reply = await _service.chat(conversation);
      if (!mounted) return;
      setState(() => _messages.add(ChatItem(reply, false)));
      await _persist();
    } catch (e) {
      if (!mounted) return;
      setState(() => _messages.add(ChatItem('Connection error: $e\n\nCheck that OmniRoute is running and verify the URL, model and API key in Settings.', false)));
      await _persist();
    } finally {
      if (mounted) { setState(() => _busy = false); _scrollToBottom(); }
    }
  }
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }
  @override
  Widget build(BuildContext context) => Column(children: [
    Expanded(child: !_loaded ? const Center(child: CircularProgressIndicator()) : ListView.builder(
      controller: _scrollController, padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      itemCount: _messages.length + (_busy ? 1 : 0),
      itemBuilder: (context, index) {
        if (_busy && index == _messages.length) return const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.all(12), child: Row(mainAxisSize: MainAxisSize.min, children: [SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 10), Text('JARVIS 2.0 is thinking...', style: TextStyle(color: Colors.cyanAccent))])));
        final item = _messages[index];
        return Align(alignment: item.isUser ? Alignment.centerRight : Alignment.centerLeft, child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .84), margin: const EdgeInsets.symmetric(vertical: 6), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(color: item.isUser ? const Color(0xFF123C58) : const Color(0xFF111F30), border: Border.all(color: item.isUser ? const Color(0xFF247DA5) : const Color(0xFF1C536B)), borderRadius: BorderRadius.circular(16)),
          child: SelectableText(item.text, style: const TextStyle(fontSize: 15, height: 1.4)),
        ));
      },
    )),
    SafeArea(top: false, child: Container(padding: const EdgeInsets.fromLTRB(12, 8, 8, 8), decoration: const BoxDecoration(color: Color(0xFF0B1726), border: Border(top: BorderSide(color: Color(0xFF18384D)))), child: Row(children: [
      Expanded(child: TextField(controller: _controller, minLines: 1, maxLines: 5, textInputAction: TextInputAction.send, onSubmitted: (_) => _send(), decoration: InputDecoration(hintText: 'Ask JARVIS 2.0...', filled: true, fillColor: const Color(0xFF101F30), border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)))),
      const SizedBox(width: 8), IconButton.filled(onPressed: _busy || !_loaded ? null : _send, icon: const Icon(Icons.arrow_upward), style: IconButton.styleFrom(backgroundColor: const Color(0xFF087F9B), foregroundColor: Colors.white)),
    ]))),
  ]);
}
