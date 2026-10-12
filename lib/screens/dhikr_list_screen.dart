import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/dhikr_model.dart';
import 'dhikr_detail_screen.dart';

class DhikrListScreen extends StatefulWidget {
  const DhikrListScreen({super.key});

  @override
  State<DhikrListScreen> createState() => _DhikrListScreenState();
}

class _DhikrListScreenState extends State<DhikrListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? const Color(0xFF1A7A5C) : const Color(0xFF0F503C);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1F1A) : const Color(0xFFF5F9F7),
      appBar: AppBar(
        title: const Text(
          'الأذكار',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD4AF37),
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'الصباح'),
            Tab(text: 'المساء'),
            Tab(text: 'بعد الصلاة'),
            Tab(text: 'النوم'),
          ],
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(state.morningDhikrs, state, primary, isDark),
              _buildList(state.eveningDhikrs, state, primary, isDark),
              _buildList(state.afterPrayerDhikrs, state, primary, isDark),
              _buildList(state.sleepDhikrs, state, primary, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(
    List<DhikrModel> list,
    AppState state,
    Color primary,
    bool isDark,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final dhikr = list[index];
        final count = state.getDhikrCount(dhikr.id);
        final progress = dhikr.targetCount > 0
            ? (count / dhikr.targetCount).clamp(0.0, 1.0)
            : 0.0;
        final completed = count >= dhikr.targetCount;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isDark ? 0 : 2,
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: completed
                ? const BorderSide(color: Color(0xFFD4AF37), width: 1.5)
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DhikrDetailScreen(dhikr: dhikr),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dhikr.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      if (completed)
                        const Icon(Icons.check_circle, color: Color(0xFFD4AF37)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dhikr.text.length > 80
                        ? '${dhikr.text.substring(0, 80)}...'
                        : dhikr.text,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: isDark
                                ? Colors.white12
                                : Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(
                              completed
                                  ? const Color(0xFFD4AF37)
                                  : primary,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$count / ${dhikr.targetCount}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: completed
                              ? const Color(0xFFD4AF37)
                              : (isDark ? Colors.white70 : primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
