import 'package:flutter/material.dart';

class StudioScreen extends StatelessWidget {
  const StudioScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Creation studio', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 6),
    const Text('A home for building things with JARVIS.'),
    const SizedBox(height: 16),
    _tile(Icons.movie_creation, 'AI video generator', 'Planned: turn text prompts and images into short videos through a compatible video-generation provider.', 'Video generation needs a separate provider/API; your OmniRoute chat endpoint does not automatically create videos.'),
    _tile(Icons.code, 'App & website builder', 'Planned: generate project files, code and build instructions.', 'Project generation and APK builds will be added as a separate workflow.'),
    _tile(Icons.sports_esports, 'Game creator', 'Planned: help design and build simple games.', 'This will need a project workspace and file-generation tools.'),
  ]);
  Widget _tile(IconData icon, String title, String subtitle, String note) => Card(color: const Color(0xFF101B2A), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: Colors.cyanAccent), const SizedBox(width: 10), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))), const Chip(label: Text('Planned'))]), const SizedBox(height: 8), Text(subtitle), const SizedBox(height: 8), Text(note, style: const TextStyle(color: Colors.white60, fontSize: 12))])));
}
