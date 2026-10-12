import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import '../models/dhikr_model.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Dark mode
  bool get isDarkMode => _prefs.getBool('isDarkMode') ?? false;
  Future<void> setDarkMode(bool value) => _prefs.setBool('isDarkMode', value);

  // Notifications
  bool get notificationsEnabled => _prefs.getBool('notificationsEnabled') ?? true;
  Future<void> setNotificationsEnabled(bool value) =>
      _prefs.setBool('notificationsEnabled', value);

  // Tasbih counter
  int get tasbihCount => _prefs.getInt('tasbihCount') ?? 0;
  Future<void> setTasbihCount(int value) => _prefs.setInt('tasbihCount', value);

  // Total tasbih ever
  int get totalTasbih => _prefs.getInt('totalTasbih') ?? 0;
  Future<void> setTotalTasbih(int value) => _prefs.setInt('totalTasbih', value);

  // Tasks
  List<TaskModel> getTasks() {
    final String? data = _prefs.getString('tasks');
    if (data == null || data.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(data);
      return list
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    final data = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await _prefs.setString('tasks', data);
  }

  // Custom dhikrs progress
  Map<String, int> getDhikrProgress() {
    final String? data = _prefs.getString('dhikrProgress');
    if (data == null || data.isEmpty) return {};
    try {
      final Map<String, dynamic> map = jsonDecode(data);
      return map.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveDhikrProgress(Map<String, int> progress) async {
    await _prefs.setString('dhikrProgress', jsonEncode(progress));
  }
}
