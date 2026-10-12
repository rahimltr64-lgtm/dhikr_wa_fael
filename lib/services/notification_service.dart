import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int morningId = 1;
  static const int eveningId = 2;
  static const int sleepId = 3;

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);

    // طلب إذن الإشعارات (أندرويد 13+)
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  /// جدولة إشعار يومي في وقت محدد
  static Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'dhikr_channel',
          'تذكير الأذكار',
          channelDescription: 'إشعارات تذكير الأذكار والمهام',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// جدولة الإشعارات الافتراضية
  static Future<void> scheduleDefaultReminders() async {
    await scheduleDaily(
      id: morningId,
      title: 'أذكار الصباح 🌿',
      body: 'حان وقت أذكار الصباح، لا تنسَ ذكر الله',
      hour: 6,
      minute: 30,
    );
    await scheduleDaily(
      id: eveningId,
      title: 'أذكار المساء 🌙',
      body: 'حان وقت أذكار المساء',
      hour: 18,
      minute: 0,
    );
    await scheduleDaily(
      id: sleepId,
      title: 'أذكار النوم 😴',
      body: 'قبل النوم، اقرأ أذكار النوم',
      hour: 22,
      minute: 0,
    );
  }

  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// إشعار فوري (للاختبار)
  static Future<void> showInstant({
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      99,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'dhikr_channel',
          'تذكير الأذكار',
          channelDescription: 'إشعارات تذكير الأذكار والمهام',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
