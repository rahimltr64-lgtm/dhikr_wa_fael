import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int morningId = 1;
  static const int eveningId = 2;
  static const int sleepId = 3;

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
      } catch (_) {
        try {
          tz.setLocalLocation(tz.getLocation('UTC'));
        } catch (_) {}
      }

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);

      await _notifications.initialize(initSettings);

      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // إنشاء قنوات الإشعارات
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'dhikr_channel',
          'تذكير الأذكار',
          description: 'إشعارات تذكير الأذكار',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'tasks_channel',
          'تذكير المهام',
          description: 'إشعارات تذكير المهام',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );

      // طلب الأذونات
      try {
        await androidPlugin?.requestNotificationsPermission();
        await androidPlugin?.requestExactAlarmsPermission();
      } catch (_) {}

      _initialized = true;
    } catch (e) {
      print('Notification init error: $e');
    }
  }

  static Future<void> _ensureInit() async {
    if (!_initialized) {
      await init();
    }
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
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
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
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print('Schedule daily error: $e');
    }
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

  /// جدولة إشعار لمرة واحدة في وقت محدد (لتذكير المهام)
  static Future<bool> scheduleOneTime({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    try {
      await _ensureInit();

      final now = DateTime.now();
      if (when.isBefore(now.add(const Duration(seconds: 30)))) {
        // إذا كان الوقت قريباً جداً أو في الماضي، أرسل فوراً بعد ثوانٍ
        print('Time too soon or past, adjusting...');
      }
      if (when.isBefore(now)) {
        return false;
      }

      // بناء الوقت حسب المنطقة المحلية بشكل صحيح
      final scheduled = tz.TZDateTime(
        tz.local,
        when.year,
        when.month,
        when.day,
        when.hour,
        when.minute,
        when.second,
      );

      print('Scheduling task notification at: $scheduled (now: ${tz.TZDateTime.now(tz.local)})');

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
    } catch (e) {
      print('Schedule one-time error: $e');
      // محاولة بديلة بدون exact
      try {
        final scheduled = tz.TZDateTime(
          tz.local,
          when.year,
          when.month,
          when.day,
          when.hour,
          when.minute,
        );
        await _notifications.zonedSchedule(
          id,
          title,
          body,
          scheduled,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'tasks_channel',
              'تذكير المهام',
              importance: Importance.max,
              priority: Priority.max,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        return true;
      } catch (e2) {
        print('Fallback schedule error: $e2');
        return false;
      }
    }
  }

  static int taskNotificationId(String taskId) {
    return 100000 + (int.tryParse(taskId) ?? taskId.hashCode.abs()) % 900000;
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
