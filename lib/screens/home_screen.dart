import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'tasbih_screen.dart';
import 'dhikr_list_screen.dart';
import 'tasks_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TasbihScreen(),
    DhikrListScreen(),
    TasksScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: isDark ? const Color(0xFF0A3D2E) : const Color(0xFF0F503C),
        indicatorColor: const Color(0xFFD4AF37).withOpacity(0.3),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fingerprint, color: Colors.white70),
            selectedIcon: Icon(Icons.fingerprint, color: Color(0xFFD4AF37)),
            label: 'تسبيح',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.menu_book, color: Color(0xFFD4AF37)),
            label: 'أذكار',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.checklist, color: Color(0xFFD4AF37)),
            label: 'مهام',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.settings, color: Color(0xFFD4AF37)),
            label: 'إعدادات',
          ),
        ],
      ),
    );
  }
}
