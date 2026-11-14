import 'package:flutter/material.dart';
import '../services/memory_service.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});
  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}
class _MemoryScreenState extends State<MemoryScreen> {
  final _memory = MemoryService();
  final _controller = TextEditingController();
  List<String> _items = [];
  List<Map<String, dynamic>> _history = [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final m = await _memory.loadMemories();
    final h = await _memory.loadHistory();
    if (mounted) setState(() { _items = m; _history = h; });
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  Future<void> _add() async { await _memory.addMemory(_controller.text); _controller.clear(); await _load(); }
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('JARVIS remembers', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 6),
    const Text('Conversation history and saved memories stay on this phone. You can add or delete memories here.'),
    const SizedBox(height: 16),
    TextField(controller: _controller, decoration: InputDecoration(hintText: 'Add something for JARVIS to remember', suffixIcon: IconButton(onPressed: _add, icon: const Icon(Icons.add)), border: const OutlineInputBorder()), onSubmitted: (_) => _add()),
    const SizedBox(height: 18),
    Row(children: [const Expanded(child: Text('Saved memories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), Text('${_items.length}')]),
    if (_items.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: Text('No saved memories yet. Try: “Remember that I prefer short answers.”')),
    ..._items.map((item) => Card(color: const Color(0xFF101B2A), child: ListTile(leading: const Icon(Icons.bookmark, color: Colors.cyanAccent), title: Text(item), trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async { await _memory.deleteMemory(item); await _load(); })))),
    const SizedBox(height: 16),
    Text('Conversation history', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    Text('${_history.length} messages stored locally'),
    const SizedBox(height: 12),
    OutlinedButton.icon(onPressed: () async { await _memory.clearAll(); await _load(); }, icon: const Icon(Icons.delete_sweep), label: const Text('Clear all memory and history')),
    const SizedBox(height: 8),
    const Text('Privacy: local history and saved memories are stored on this device. The current starter uses simple on-device phrase detection; advanced AI-based memory extraction is a later upgrade.', style: TextStyle(color: Colors.white60, fontSize: 12)),
  ]);
}
