import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/task_model.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? const Color(0xFF1A7A5C) : const Color(0xFF0F503C);

    final pending = state.tasks.where((t) => !t.isCompleted).toList();
    final completed = state.tasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1F1A) : const Color(0xFFF5F9F7),
      appBar: AppBar(
        title: const Text(
          'المهام اليومية',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (completed.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'حذف المكتملة',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('حذف المهام المكتملة؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('إلغاء'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          state.clearCompletedTasks();
                          Navigator.pop(ctx);
                        },
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, state),
        icon: const Icon(Icons.add),
        label: const Text('مهمة جديدة'),
      ),
      body: state.tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checklist,
                    size: 80,
                    color: primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد مهام بعد',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اضغط + لإضافة مهمة',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                if (pending.isNotEmpty) ...[
                  _sectionTitle('قيد التنفيذ', pending.length, primary, isDark),
                  ...pending.map((t) => _TaskTile(task: t, primary: primary)),
                  const SizedBox(height: 16),
                ],
                if (completed.isNotEmpty) ...[
                  _sectionTitle('مكتملة', completed.length, primary, isDark),
                  ...completed.map((t) => _TaskTile(task: t, primary: primary)),
                ],
              ],
            ),
    );
  }

  Widget _sectionTitle(String title, int count, Color primary, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, AppState state) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مهمة جديدة'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'اكتب المهمة هنا...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              state.addTask(value.trim());
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                state.addTask(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final TaskModel task;
  final Color primary;

  const _TaskTile({required this.task, required this.primary});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => state.deleteTask(task.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: isDark ? 0 : 1,
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            activeColor: const Color(0xFFD4AF37),
            onChanged: (_) => state.toggleTask(task.id),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration:
                  task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted
                  ? (isDark ? Colors.white38 : Colors.black38)
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            onPressed: () => state.deleteTask(task.id),
          ),
        ),
      ),
    );
  }
}
