import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'services/app_state.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final storage = StorageService(prefs);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState(storage)..loadData()),
      ],
      child: const DhikrApp(),
    ),
  );

  // تهيئة الإشعارات في الخلفية
  Future.microtask(() async {
    try {
      await NotificationService.init();
      final enabled = prefs.getBool('notificationsEnabled') ?? true;
      if (enabled) {
        await NotificationService.scheduleDefaultReminders(
          morningHour: prefs.getInt('morningHour') ?? 6,
          morningMinute: prefs.getInt('morningMinute') ?? 30,
          eveningHour: prefs.getInt('eveningHour') ?? 18,
          eveningMinute: prefs.getInt('eveningMinute') ?? 0,
          sleepHour: prefs.getInt('sleepHour') ?? 22,
          sleepMinute: prefs.getInt('sleepMinute') ?? 0,
        );
      }
    } catch (e) {
      print('Background notification setup failed: $e');
    }
  });
}

class DhikrApp extends StatelessWidget {
  const DhikrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return MaterialApp(
          title: 'ذكر وفعل',
          debugShowCheckedModeBanner: false,
          themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F503C),
              brightness: Brightness.light,
              primary: const Color(0xFF0F503C),
              secondary: const Color(0xFFD4AF37),
            ),
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Color(0xFF0F503C),
              foregroundColor: Colors.white,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFFD4AF37),
              foregroundColor: Color(0xFF0F503C),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F503C),
              brightness: Brightness.dark,
              primary: const Color(0xFF1A7A5C),
              secondary: const Color(0xFFD4AF37),
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Color(0xFF0A3D2E),
              foregroundColor: Colors.white,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFFD4AF37),
              foregroundColor: Color(0xFF0A3D2E),
            ),
          ),
          home: const HomeScreen(),
          locale: const Locale('ar'),
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            );
          },
        );
      },
    );
  }
}