import 'package:flutter/material.dart';
import '../services/omni_route_service.dart';
import 'settings_screen.dart';

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
  final List<ChatItem> _messages = [
    const ChatItem('Systems online. Configure your OmniRoute connection in Settings, then ask me something.', false),
  ];
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _busy) return;
    _controller.clear();
    setState(() {
      _messages.add(ChatItem(text, true));
      _busy = true;
    });
    _scrollToBottom();
    try {
      final reply = await _service.chat(_messages
          .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
          .toList());
      if (!mounted) return;
      setState(() => _messages.add(ChatItem(reply, false)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _messages.add(ChatItem('Connection error: $e\n\nOpen Settings and check your OmniRoute URL, model, and API key.', false)));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
    await _service.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1B2D),
        title: const Row(children: [
          Icon(Icons.bubble_chart, color: Color(0xFF42E8F5)),
          SizedBox(width: 9),
          Text('J.A.R.V.I.S.', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w700)),
        ]),
        actions: [
          IconButton(tooltip: 'Connection settings', onPressed: _openSettings, icon: const Icon(Icons.tune)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
              itemCount: _messages.length + (_busy ? 1 : 0),
              itemBuilder: (context, index) {
                if (_busy && index == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 10),
                        Text('JARVIS is thinking...', style: TextStyle(color: Colors.cyanAccent)),
                      ]),
                    ),
                  );
                }
                final item = _messages[index];
                return Align(
                  alignment: item.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .84),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: item.isUser ? const Color(0xFF123C58) : const Color(0xFF111F30),
                      border: Border.all(color: item.isUser ? const Color(0xFF247DA5) : const Color(0xFF1C536B)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SelectableText(item.text, style: const TextStyle(fontSize: 15, height: 1.4)),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              decoration: const BoxDecoration(
                color: Color(0xFF0B1726),
                border: Border(top: BorderSide(color: Color(0xFF18384D))),
              ),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Ask JARVIS...',
                      filled: true,
                      fillColor: const Color(0xFF101F30),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _busy ? null : _send,
                  icon: const Icon(Icons.arrow_upward),
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFF087F9B), foregroundColor: Colors.white),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
