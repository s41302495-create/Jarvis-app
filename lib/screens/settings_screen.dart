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
  bool _saving = false;
  bool _hideKey = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _service.reload();
    _url.text = _service.baseUrl;
    _key.text = _service.apiKey;
    _model.text = _service.model;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _url.dispose();
    _key.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _service.save(baseUrl: _url.text.trim(), apiKey: _key.text.trim(), model: _model.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved securely.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OmniRoute settings')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        const Text('Connection', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Enter the base URL of your OmniRoute server. Example: http://127.0.0.1:YOUR_PORT/v1. Use your actual server port. If OmniRoute runs on another device, use that device’s reachable LAN address.'),
        const SizedBox(height: 18),
        TextField(controller: _url, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'API base URL', hintText: 'http://127.0.0.1:YOUR_PORT/v1', border: OutlineInputBorder())),
        const SizedBox(height: 14),
        TextField(
          controller: _key,
          obscureText: _hideKey,
          decoration: InputDecoration(
            labelText: 'API key',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(icon: Icon(_hideKey ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _hideKey = !_hideKey)),
          ),
        ),
        const SizedBox(height: 14),
        TextField(controller: _model, decoration: const InputDecoration(labelText: 'Model / combo name', hintText: 'Ai', border: OutlineInputBorder())),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.save),
          label: Text(_saving ? 'Saving...' : 'Save settings'),
        ),
        const SizedBox(height: 18),
        const Text('Security note: the API key is stored using Android secure storage. Do not share screenshots containing your key.'),
      ]),
    );
  }
}
