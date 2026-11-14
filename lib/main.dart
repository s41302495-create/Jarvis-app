import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JarvisApp());
}

class JarvisApp extends StatelessWidget {
  const JarvisApp({super.key});
  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF42E8F5);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JARVIS 2.0',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070D16),
        colorScheme: const ColorScheme.dark(primary: cyan, secondary: Color(0xFF168DCC), surface: Color(0xFF101B2A)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
