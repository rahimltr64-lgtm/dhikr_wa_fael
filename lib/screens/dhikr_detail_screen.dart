import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/dhikr_model.dart';
import 'package:share_plus/share_plus.dart';
import '../services/app_state.dart';

class DhikrDetailScreen extends StatelessWidget {
  final DhikrModel dhikr;

  const DhikrDetailScreen({super.key, required this.dhikr});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final count = state.getDhikrCount(dhikr.id);
    final progress = dhikr.targetCount > 0
        ? (count / dhikr.targetCount).clamp(0.0, 1.0)
        : 0.0;
    final completed = count >= dhikr.targetCount;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? const Color(0xFF1A7A5C) : const Color(0xFF0F503C);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1F1A) : const Color(0xFFF5F9F7),
      appBar: AppBar(
        title: Text(dhikr.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'مشاركة',
            onPressed: () {
              Share.share(
                '${dhikr.title}\n\n${dhikr.text}\n\n— من تطبيق ذكر وفعل',
                subject: dhikr.title,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'إعادة تعيين',
            onPressed: () {
              state.resetDhikr(dhikr.id);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                      ),
                      child: Text(
                        dhikr.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          height: 1.9,
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '$count / ${dhikr.targetCount}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: completed
                            ? const Color(0xFFD4AF37)
                            : primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor:
                              isDark ? Colors.white12 : Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(
                            completed ? const Color(0xFFD4AF37) : primary,
                          ),
                          minHeight: 10,
                        ),
                      ),
                    ),
                    if (completed) ...[
                      const SizedBox(height: 16),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFFD4AF37)),
                          SizedBox(width: 8),
                          Text(
                            'تم الإكمال ✓',
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (state.soundEnabled) {
                      SystemSound.play(SystemSoundType.click);
                    }
                    state.incrementDhikr(dhikr.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'اضغط للعدّ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
