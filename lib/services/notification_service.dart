import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int morningId = 1;
  static const int eveningId = 2;
  static const int sleepId = 3;

  static bool _initialized = false;
  static String? lastError;

  static Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.UTC);
      for (final name in ['Asia/Riyadh', 'Asia/Dubai', 'Africa/Cairo']) {
        try {
          tz.setLocalLocation(tz.getLocation(name));
          break;
        } catch (_) {}
      }

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);

      await _notifications.initialize(initSettings);

      final android = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (android != null) {
        await android.createNotificationChannel(
          const AndroidNotificationChannel(
            'dhikr_channel',
            'تذكير الأذكار',
            description: 'إشعارات تذكير الأذكار',
            importance: Importance.high,
          ),
        );
        await android.createNotificationChannel(
          const AndroidNotificationChannel(
            'tasks_channel',
            'تذكير المهام',
            description: 'إشعارات تذكير المهام',
            importance: Importance.max,
          ),
        );

        try {
          await android.requestNotificationsPermission();
        } catch (_) {}
        try {
          await android.requestExactAlarmsPermission();
        } catch (_) {}
      }

      _initialized = true;
      lastError = null;
    } catch (e) {
      lastError = e.toString();
      print('Notification init error: $e');
    }
  }

  static Future<void> _ensureInit() async {
    if (!_initialized) await init();
  }

  static Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      await _ensureInit();
      final now = tz.TZDateTime.now(tz.local);
      var scheduled =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (!scheduled.isAfter(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'dhikr_channel',
            'تذكير الأذكار',
            channelDescription: 'إشعارات تذكير الأذكار',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print('Schedule daily error: $e');
    }
  }

  static Future<void> scheduleDefaultReminders({
    int morningHour = 6,
    int morningMinute = 30,
    int eveningHour = 18,
    int eveningMinute = 0,
    int sleepHour = 22,
    int sleepMinute = 0,
  }) async {
    await cancel(morningId);
    await cancel(eveningId);
    await cancel(sleepId);
    await scheduleDaily(
      id: morningId,
      title: 'أذكار الصباح 🌿',
      body: 'حان وقت أذكار الصباح، لا تنسَ ذكر الله',
      hour: morningHour,
      minute: morningMinute,
    );
    await scheduleDaily(
      id: eveningId,
      title: 'أذكار المساء 🌙',
      body: 'حان وقت أذكار المساء',
      hour: eveningHour,
      minute: eveningMinute,
    );
    await scheduleDaily(
      id: sleepId,
      title: 'أذكار النوم 😴',
      body: 'قبل النوم، اقرأ أذكار النوم',
      hour: sleepHour,
      minute: sleepMinute,
    );
  }

  /// جدولة إشعار مهمة — يعتمد على المدة المتبقية من الآن (أكثر موثوقية)
  static Future<bool> scheduleOneTime({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    lastError = null;
    try {
      await _ensureInit();
      if (!_initialized) {
        lastError = 'فشل تهيئة الإشعارات';
        return false;
      }

      final now = DateTime.now();
      final delay = when.difference(now);

      if (delay.inSeconds < 30) {
        lastError = 'اختر وقتاً بعد دقيقة على الأقل';
        return false;
      }

      // الأهم: نجدول بالنسبة للوقت الحالي وليس كوقت مطلق
      // هذا يتجنب مشاكل اختلاف المنطقة الزمنية
      final scheduled = tz.TZDateTime.now(tz.local).add(delay);

      try {
        final android = _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        await android?.requestExactAlarmsPermission();
      } catch (_) {}

      // محاولة دقيقة
      try {
        await _notifications.zonedSchedule(
          id,
          title,
          body,
          scheduled,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'tasks_channel',
              'تذكير المهام',
              channelDescription: 'إشعارات تذكير المهام',
              importance: Importance.max,
              priority: Priority.max,
              playSound: true,
              enableVibration: true,
              category: AndroidNotificationCategory.reminder,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        return true;
      } catch (e1) {
        print('Exact failed: $e1');
        // محاولة غير دقيقة
        try {
          await _notifications.zonedSchedule(
            id,
            title,
            body,
            scheduled,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'tasks_channel',
                'تذكير المهام',
                channelDescription: 'إشعارات تذكير المهام',
                importance: Importance.max,
                priority: Priority.max,
                playSound: true,
                enableVibration: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          return true;
        } catch (e2) {
          lastError = e2.toString();
          print('Inexact failed: $e2');
          return false;
        }
      }
    } catch (e) {
      lastError = e.toString();
      print('Schedule one-time error: $e');
      return false;
    }
  }

  static int taskNotificationId(String taskId) {
    final parsed = int.tryParse(taskId);
    if (parsed != null) {
      return 100000 + (parsed % 900000);
    }
    return 100000 + (taskId.hashCode.abs() % 900000);
  }

  static Future<void> cancel(int id) async {
    try {
      await _notifications.cancel(id);
    } catch (_) {}
  }

  static Future<void> cancelAll() async {
    try {
      await _notifications.cancelAll();
    } catch (_) {}
  }

  static Future<void> showInstant({
    required String title,
    required String body,
  }) async {
    try {
      await _ensureInit();
      await _notifications.show(
        99,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'tasks_channel',
            'تذكير المهام',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            enableVibration: true,
          ),
        ),
      );
    } catch (e) {
      print('Show instant error: $e');
    }
  }
}
