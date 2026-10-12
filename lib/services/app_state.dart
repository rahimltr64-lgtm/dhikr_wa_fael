import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/dhikr_model.dart';
import 'storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService storage;

  bool isDarkMode = false;
  bool notificationsEnabled = true;
  int tasbihCount = 0;
  int totalTasbih = 0;
  List<TaskModel> tasks = [];
  Map<String, int> dhikrProgress = {};

  // Fixed dhikr lists
  final List<DhikrModel> morningDhikrs = [
    DhikrModel(
      id: 'm1',
      title: 'آية الكرسي',
      text: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      targetCount: 1,
    ),
    DhikrModel(
      id: 'm2',
      title: 'سبحان الله وبحمده',
      text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      targetCount: 100,
    ),
    DhikrModel(
      id: 'm3',
      title: 'لا إله إلا الله',
      text: 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
      targetCount: 10,
    ),
    DhikrModel(
      id: 'm4',
      title: 'أستغفر الله',
      text: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      targetCount: 100,
    ),
    DhikrModel(
      id: 'm5',
      title: 'اللهم بك أصبحنا',
      text: 'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
      targetCount: 1,
    ),
  ];

  final List<DhikrModel> eveningDhikrs = [
    DhikrModel(
      id: 'e1',
      title: 'آية الكرسي',
      text: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      targetCount: 1,
    ),
    DhikrModel(
      id: 'e2',
      title: 'سبحان الله وبحمده',
      text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      targetCount: 100,
    ),
    DhikrModel(
      id: 'e3',
      title: 'أعوذ بكلمات الله',
      text: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      targetCount: 3,
    ),
    DhikrModel(
      id: 'e4',
      title: 'اللهم بك أمسينا',
      text: 'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
      targetCount: 1,
    ),
  ];

  final List<DhikrModel> afterPrayerDhikrs = [
    DhikrModel(
      id: 'p1',
      title: 'أستغفر الله',
      text: 'أَسْتَغْفِرُ اللَّهَ',
      targetCount: 3,
    ),
    DhikrModel(
      id: 'p2',
      title: 'اللهم أنت السلام',
      text: 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
      targetCount: 1,
    ),
    DhikrModel(
      id: 'p3',
      title: 'سبحان الله',
      text: 'سُبْحَانَ اللَّهِ',
      targetCount: 33,
    ),
    DhikrModel(
      id: 'p4',
      title: 'الحمد لله',
      text: 'الْحَمْدُ لِلَّهِ',
      targetCount: 33,
    ),
    DhikrModel(
      id: 'p5',
      title: 'الله أكبر',
      text: 'اللَّهُ أَكْبَرُ',
      targetCount: 33,
    ),
    DhikrModel(
      id: 'p6',
      title: 'لا إله إلا الله',
      text: 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
      targetCount: 1,
    ),
  ];

  final List<DhikrModel> sleepDhikrs = [
    DhikrModel(
      id: 's1',
      title: 'آية الكرسي',
      text: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      targetCount: 1,
    ),
    DhikrModel(
      id: 's2',
      title: 'باسمك ربي',
      text: 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي وَبِكَ أَرْفَعُهُ، إِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ',
      targetCount: 1,
    ),
    DhikrModel(
      id: 's3',
      title: 'اللهم قني عذابك',
      text: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
      targetCount: 3,
    ),
  ];

  AppState(this.storage);

  Future<void> loadData() async {
    isDarkMode = storage.isDarkMode;
    notificationsEnabled = storage.notificationsEnabled;
    tasbihCount = storage.tasbihCount;
    totalTasbih = storage.totalTasbih;
    tasks = storage.getTasks();
    dhikrProgress = storage.getDhikrProgress();
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    storage.setDarkMode(isDarkMode);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    notificationsEnabled = !notificationsEnabled;
    await storage.setNotificationsEnabled(notificationsEnabled);
    notifyListeners();
  }

  void incrementTasbih() {
    tasbihCount++;
    totalTasbih++;
    storage.setTasbihCount(tasbihCount);
    storage.setTotalTasbih(totalTasbih);
    notifyListeners();
  }

  void resetTasbih() {
    tasbihCount = 0;
    storage.setTasbihCount(0);
    notifyListeners();
  }

  void incrementDhikr(String id) {
    dhikrProgress[id] = (dhikrProgress[id] ?? 0) + 1;
    storage.saveDhikrProgress(dhikrProgress);
    notifyListeners();
  }

  void resetDhikr(String id) {
    dhikrProgress[id] = 0;
    storage.saveDhikrProgress(dhikrProgress);
    notifyListeners();
  }

  int getDhikrCount(String id) => dhikrProgress[id] ?? 0;

  void addTask(String title, {String? linkedDhikr}) {
    final task = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      linkedDhikr: linkedDhikr,
    );
    tasks.insert(0, task);
    storage.saveTasks(tasks);
    notifyListeners();
  }

  void toggleTask(String id) {
    final index = tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      tasks[index].isCompleted = !tasks[index].isCompleted;
      storage.saveTasks(tasks);
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    tasks.removeWhere((t) => t.id == id);
    storage.saveTasks(tasks);
    notifyListeners();
  }

  void clearCompletedTasks() {
    tasks.removeWhere((t) => t.isCompleted);
    storage.saveTasks(tasks);
    notifyListeners();
  }
}
