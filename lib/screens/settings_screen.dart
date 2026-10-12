import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? const Color(0xFF1A7A5C) : const Color(0xFF0F503C);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1F1A) : const Color(0xFFF5F9F7),
      appBar: AppBar(
        title: const Text(
          'الإعدادات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance
          _SectionHeader(title: 'المظهر', primary: primary),
          Card(
            elevation: isDark ? 0 : 1,
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              title: const Text('الوضع الليلي'),
              subtitle: Text(
                state.isDarkMode ? 'مفعّل' : 'معطّل',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              secondary: Icon(
                state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: primary,
              ),
              value: state.isDarkMode,
              activeColor: const Color(0xFFD4AF37),
              onChanged: (_) => state.toggleTheme(),
            ),
          ),
          const SizedBox(height: 24),

          // Stats
          _SectionHeader(title: 'إحصائيات', primary: primary),
          Card(
            elevation: isDark ? 0 : 1,
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _StatRow(
                    label: 'إجمالي التسبيحات',
                    value: '${state.totalTasbih}',
                    icon: Icons.all_inclusive,
                    color: primary,
                  ),
                  const Divider(height: 24),
                  _StatRow(
                    label: 'المهام الحالية',
                    value: '${state.tasks.length}',
                    icon: Icons.checklist,
                    color: const Color(0xFFD4AF37),
                  ),
                  const Divider(height: 24),
                  _StatRow(
                    label: 'المهام المكتملة',
                    value: '${state.tasks.where((t) => t.isCompleted).length}',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // About
          _SectionHeader(title: 'عن التطبيق', primary: primary),
          Card(
            elevation: isDark ? 0 : 1,
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'ذكر وفعل',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'الإصدار 1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'تطبيق بسيط وجميل يجمع بين الأذكار والتسبيح والمهام اليومية.\nصمم ليعمل بسلاسة على الهاتف.',
                    textAlign: TextAlign.center,
                    style: TextStyle(height: 1.6),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'جُعل ليكون رفيقك اليومي في الذكر والعمل',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color primary;

  const _SectionHeader({required this.title, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: primary,
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
