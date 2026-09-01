import 'dart:async';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/storage_service.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/alarm/presentation/alarm_screen.dart';
import 'features/dsa/presentation/dsa_screen.dart';
import 'features/notes/presentation/notes_screen.dart';
import 'features/alarm/presentation/widgets/alarm_modal.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyProgressApp());
}

class MyProgressApp extends StatelessWidget {
  const MyProgressApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Progress',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      darkTheme: AppTheme.darkThemeData,
      themeMode: ThemeMode.system,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({Key? key}) : super(key: key);

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  Timer? _alarmCheckTimer;
  String? _lastTriggeredMinute;
  bool _isAlarmShowing = false;

  @override
  void initState() {
    super.initState();
    _startAlarmTicker();
  }

  @override
  void dispose() {
    _alarmCheckTimer?.cancel();
    super.dispose();
  }

  void _startAlarmTicker() {
    _alarmCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final now = DateTime.now();
      final settings = await StorageService.getAlarmSettings();
      final enabled = settings['enabled'] as bool? ?? true;

      if (enabled && !_isAlarmShowing) {
        final targetTime = settings['time'] as String? ?? '06:30';
        final hourStr = now.hour.toString().padLeft(2, '0');
        final minStr = now.minute.toString().padLeft(2, '0');
        final currentHHMM = '$hourStr:$minStr';
        final minuteKey = '${now.year}-${now.month}-${now.day}_$currentHHMM';

        if (currentHHMM == targetTime && _lastTriggeredMinute != minuteKey) {
          _lastTriggeredMinute = minuteKey;
          _triggerAlarmModal(
            settings['challengeText'] as String? ??
                'I will stay consistent with my goals and complete my daily work today.',
            settings['ringtonePath'] as String?,
          );
        }
      }
    });
  }

  void _triggerAlarmModal(String challengeText, String? ringtonePath) {
    if (_isAlarmShowing) return;
    setState(() => _isAlarmShowing = true);

    AlarmModal.show(context, challengeText, ringtonePath, () {
      setState(() => _isAlarmShowing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onNavigateTab: (index) => setState(() => _currentIndex = index),
      ),
      AlarmScreen(
        onTriggerTestAlarm: () async {
          final settings = await StorageService.getAlarmSettings();
          _triggerAlarmModal(
            settings['challengeText'] as String? ??
                'I will stay consistent with my goals and complete my daily work today.',
            settings['ringtonePath'] as String?,
          );
        },
      ),
      const DsaScreen(),
      const NotesScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        elevation: 0,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm_outlined),
            activeIcon: Icon(Icons.alarm),
            label: 'Daily Alarm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_on_outlined),
            activeIcon: Icon(Icons.grid_on),
            label: 'DSA Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_outlined),
            activeIcon: Icon(Icons.note_alt),
            label: 'Daily Notes',
          ),
        ],
      ),
    );
  }
}
