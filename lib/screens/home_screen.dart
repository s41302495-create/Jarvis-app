import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'memory_screen.dart';
import 'studio_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _pages = const [ChatScreen(), MemoryScreen(), StudioScreen(), SettingsScreen()];
  final _titles = const ['JARVIS 2.0', 'Memory', 'Creation studio', 'Settings'];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF0B1B2D),
      title: Row(children: const [Icon(Icons.auto_awesome, color: Color(0xFF42E8F5)), SizedBox(width: 9), Text('JARVIS 2.0', style: TextStyle(letterSpacing: 1.4, fontWeight: FontWeight.w800))]),
    ),
    body: _pages[_index],
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat), label: 'Chat'),
        NavigationDestination(icon: Icon(Icons.psychology_outlined), selectedIcon: Icon(Icons.psychology), label: 'Memory'),
        NavigationDestination(icon: Icon(Icons.movie_creation_outlined), selectedIcon: Icon(Icons.movie_creation), label: 'Studio'),
        NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
      ],
    ),
  );
}
