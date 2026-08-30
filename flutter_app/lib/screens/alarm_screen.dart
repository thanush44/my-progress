import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../widgets/alarm_modal.dart';

class AlarmScreen extends StatefulWidget {
  final VoidCallback onTriggerTestAlarm;

  const AlarmScreen({Key? key, required this.onTriggerTestAlarm}) : super(key: key);

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  Map<String, dynamic> _settings = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final s = await StorageService.getAlarmSettings();
    setState(() {
      _settings = s;
      _isLoading = false;
    });
  }

  Future<void> _toggleAlarm(bool value) async {
    await StorageService.saveAlarmSettings({'enabled': value});
    await _loadSettings();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'Daily alarm enabled ✓' : 'Daily alarm disabled'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _selectTime() async {
    final currentStr = _settings['time'] as String? ?? '06:30';
    final parts = currentStr.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minStr = picked.minute.toString().padLeft(2, '0');
      final period = picked.hour >= 12 ? 'PM' : 'AM';
      final newTimeStr = '$hourStr:$minStr';

      await StorageService.saveAlarmSettings({
        'time': newTimeStr,
        'period': period,
        'enabled': true,
      });
      await _loadSettings();

      if (mounted) {
        final displayTime = picked.format(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alarm set for $displayTime ✓')),
        );
      }
    }
  }

  String _formatDisplayTime(String timeStr) {
    if (timeStr.isEmpty) return '06:30 AM';
    final parts = timeStr.split(':');
    var h = int.tryParse(parts[0]) ?? 6;
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    h = h % 12;
    if (h == 0) h = 12;
    final hPadded = h.toString().padLeft(2, '0');
    return '$hPadded:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.emerald));
    }

    final isEnabled = _settings['enabled'] as bool? ?? true;
    final timeStr = _settings['time'] as String? ?? '06:30';
    final challengeText = _settings['challengeText'] as String? ??
        'I will stay consistent with my goals and complete my daily work today.';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Text(
            'Daily Alarm',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
          ),
          const SizedBox(height: 4),
          const Text(
            'Build daily consistency with a mandatory morning paragraph challenge.',
            style: TextStyle(fontSize: 13, color: AppTheme.slateMuted),
          ),
          const SizedBox(height: 16),

          // Alarm Status Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, AppTheme.bgGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isEnabled ? AppTheme.emerald : AppTheme.borderLight,
                width: isEnabled ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDark,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.alarm, color: AppTheme.mint, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDisplayTime(timeStr),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryDark,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isEnabled ? AppTheme.primaryMid : AppTheme.slateMuted,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isEnabled ? 'Alarm Enabled' : 'Alarm Disabled',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isEnabled ? AppTheme.primaryMid : AppTheme.slateMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daily Alarm Active',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                    ),
                    Switch(
                      value: isEnabled,
                      activeColor: AppTheme.emerald,
                      onChanged: _toggleAlarm,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Change Alarm Time Button Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Set Alarm Time',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Select your target wake-up time for daily consistency.',
                    style: TextStyle(fontSize: 13, color: AppTheme.slateMuted),
                  ),
                  const SizedBox(height: 14),

                  OutlinedButton.icon(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      'Change Time (${_formatDisplayTime(timeStr)})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.primaryDark, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Test Alarm Button Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.bgGreen,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.emerald, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Test Alarm Ringing',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Test how the morning alarm and typing challenge works right now.',
                  style: TextStyle(fontSize: 13, color: AppTheme.slateMuted),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: widget.onTriggerTestAlarm,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Test Alarm Now', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    minimumSize: const Size.fromHeight(48),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Paragraph Challenge Customization Preview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Required Paragraph Challenge',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'You must type this exact paragraph to turn off your morning alarm.',
                    style: TextStyle(fontSize: 13, color: AppTheme.slateMuted),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(left: BorderSide(color: AppTheme.primary, width: 4)),
                    ),
                    child: Text(
                      '"$challengeText"',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        color: Color(0xFF334155),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
