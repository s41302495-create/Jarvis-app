import 'package:flutter/material.dart';
import '../services/omni_route_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  final _service = OmniRouteService();
  final _url = TextEditingController();
  final _key = TextEditingController();
  final _model = TextEditingController();
  bool _saving = false, _hideKey = true, _wakeWord = false;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { await _service.reload(); _url.text = _service.baseUrl; _key.text = _service.apiKey; _model.text = _service.model; if (mounted) setState(() {}); }
  @override
  void dispose() { _url.dispose(); _key.dispose(); _model.dispose(); super.dispose(); }
  Future<void> _save() async {
    setState(() => _saving = true);
    try { await _service.save(baseUrl: _url.text.trim(), apiKey: _key.text.trim(), model: _model.text.trim()); if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OmniRoute settings saved securely.'))); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save: $e'))); }
    finally { if (mounted) setState(() => _saving = false); }
  }
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
    const Text('Assistant & background', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    SwitchListTile(contentPadding: EdgeInsets.zero, value: _wakeWord, onChanged: (v) { setState(() => _wakeWord = v); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(v ? 'Wake-word service is not implemented in this build yet.' : 'Wake-word mode is off.'))); }, title: const Text('Hey JARVIS wake word'), subtitle: const Text('Planned: opt-in foreground microphone service with a persistent notification.'), secondary: const Icon(Icons.mic_none, color: Colors.cyanAccent)),
    const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.notifications_active_outlined), title: Text('Background tasks'), subtitle: Text('Background task scheduling and Android notification controls are planned for the next implementation stage.')),
    const Divider(height: 28),
    const Text('OmniRoute connection', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const Text('Use your local OmniRoute endpoint. Keep the Termux OmniRoute server running while using this local connection.'),
    const SizedBox(height: 16),
    TextField(controller: _url, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'API base URL', hintText: 'http://127.0.0.1:20128/v1', border: OutlineInputBorder())),
    const SizedBox(height: 14),
    TextField(controller: _key, obscureText: _hideKey, decoration: InputDecoration(labelText: 'API key', border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(_hideKey ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _hideKey = !_hideKey)))),
    const SizedBox(height: 14),
    TextField(controller: _model, decoration: const InputDecoration(labelText: 'Model / combo name', hintText: 'Ai', border: OutlineInputBorder())),
    const SizedBox(height: 20),
    FilledButton.icon(onPressed: _saving ? null : _save, icon: const Icon(Icons.save), label: Text(_saving ? 'Saving...' : 'Save settings')),
    const SizedBox(height: 18),
    const Text('API keys are stored using Android secure storage. Never share screenshots containing your key.', style: TextStyle(color: Colors.white60, fontSize: 12)),
  ]);
}
