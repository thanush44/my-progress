import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/audio_service.dart';

class AlarmScreen extends StatefulWidget {
  final VoidCallback onTriggerTestAlarm;

  const AlarmScreen({Key? key, required this.onTriggerTestAlarm}) : super(key: key);

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  Map<String, dynamic> _settings = {};
  bool _isLoading = true;
  bool _isPreviewPlaying = false;
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _audioService.stopAlarm();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final s = await StorageService.getAlarmSettings();
    if (mounted) {
      setState(() {
        _settings = s;
        _isLoading = false;
      });
    }
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

  Future<void> _pickLocalRingtone() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty && result.files.single.path != null) {
        final path = result.files.single.path!;
        final name = result.files.single.name;

        await _audioService.stopAlarm();
        setState(() => _isPreviewPlaying = false);

        await StorageService.saveAlarmSettings({
          'ringtonePath': path,
          'ringtoneName': name,
        });
        await _loadSettings();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Custom ringtone set: $name ✓')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick audio file: $e')),
        );
      }
    }
  }

  Future<void> _togglePreview(String path) async {
    if (_isPreviewPlaying) {
      await _audioService.stopAlarm();
      setState(() => _isPreviewPlaying = false);
    } else {
      if (path.isNotEmpty) {
        await _audioService.playPreview(path);
        setState(() => _isPreviewPlaying = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No custom audio file selected yet. Please pick one.')),
        );
      }
    }
  }

  Future<void> _resetRingtone() async {
    await _audioService.stopAlarm();
    setState(() => _isPreviewPlaying = false);

    await StorageService.saveAlarmSettings({
      'ringtonePath': '',
      'ringtoneName': 'Default Tone',
    });
    await _loadSettings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ringtone reset to Default Tone ✓')),
      );
    }
  }

  void _openAffirmationEditor(String currentText) {
    final textController = TextEditingController(text: currentText);

    final presets = [
      {
        'title': 'Daily Focus',
        'text': 'I will stay consistent with my goals and complete my daily work today.'
      },
      {
        'title': 'Zero Excuses',
        'text': 'Distraction is the enemy of progress. Today I will work with deep focus and zero excuses.'
      },
      {
        'title': 'DSA Mastery',
        'text': 'Consistency beats talent. I will solve my daily problems and master data structures step by step.'
      },
      {
        'title': 'Stoic Grit',
        'text': 'The obstacle in the path becomes the path. Never forget, within every obstacle is an opportunity.'
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.borderLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Customize Morning Challenge',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'This is the paragraph you must type verbatim to turn off your morning alarm.',
                      style: TextStyle(fontSize: 13, color: AppTheme.slateMuted),
                    ),
                    const SizedBox(height: 16),

                    // Preset Chips
                    const Text(
                      'QUICK PRESETS:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryMid),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: presets.map((p) {
                        return ActionChip(
                          label: Text(p['title']!),
                          backgroundColor: AppTheme.bgGreen,
                          side: const BorderSide(color: AppTheme.lightMint),
                          labelStyle: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onPressed: () {
                            setSheetState(() {
                              textController.text = p['text']!;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Custom Text Field
                    TextField(
                      controller: textController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Challenge Paragraph',
                        hintText: 'Enter your custom affirmative paragraph...',
                        filled: true,
                        fillColor: const Color(0xFFFAFCFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppTheme.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppTheme.emerald, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () async {
                        final newText = textController.text.trim();
                        if (newText.isNotEmpty) {
                          await StorageService.saveAlarmSettings({'challengeText': newText});
                          await _loadSettings();
                          if (mounted) {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Morning challenge updated ✓')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Save Challenge', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
    final ringtoneName = _settings['ringtoneName'] as String? ?? 'Default Tone';
    final ringtonePath = _settings['ringtonePath'] as String? ?? '';
    final challengeText = _settings['challengeText'] as String? ??
        'I will stay consistent with my goals and complete my daily work today.';

    final hasCustomRingtone = ringtonePath.isNotEmpty;

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
                        Text(
                          isEnabled ? 'Alarm active everyday' : 'Alarm currently turned off',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isEnabled ? AppTheme.primary : AppTheme.slateMuted,
                          ),
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
                      activeThumbColor: AppTheme.emerald,
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
                    'Set Wake-up Time',
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

          // Local Ringtone Selector Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Alarm Ringtone',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
                      ),
                      if (hasCustomRingtone)
                        TextButton(
                          onPressed: _resetRingtone,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Reset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Choose your favorite song or tone from your phone storage.',
                    style: TextStyle(fontSize: 13, color: AppTheme.slateMuted),
                  ),
                  const SizedBox(height: 14),

                  // Display selected ringtone
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: hasCustomRingtone ? AppTheme.bgGreen : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasCustomRingtone ? AppTheme.lightMint : AppTheme.borderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.music_note,
                          color: hasCustomRingtone ? AppTheme.primary : AppTheme.slateMuted,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ringtoneName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: hasCustomRingtone ? AppTheme.primaryDark : AppTheme.darkText,
                                ),
                              ),
                              Text(
                                hasCustomRingtone ? 'Custom local audio file' : 'Default alarm sound',
                                style: const TextStyle(fontSize: 11, color: AppTheme.slateMuted),
                              ),
                            ],
                          ),
                        ),
                        if (hasCustomRingtone)
                          IconButton(
                            icon: Icon(
                              _isPreviewPlaying ? Icons.stop_circle : Icons.play_circle_filled,
                              color: AppTheme.primary,
                              size: 28,
                            ),
                            tooltip: _isPreviewPlaying ? 'Stop preview' : 'Preview tone',
                            onPressed: () => _togglePreview(ringtonePath),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: _pickLocalRingtone,
                    icon: const Icon(Icons.folder_open),
                    label: Text(
                      hasCustomRingtone ? 'Change Audio File' : 'Choose from Local Files',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.borderLight, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Paragraph Challenge Customization
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Morning Challenge',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.edit, size: 14),
                        label: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => _openAffirmationEditor(challengeText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'You must type this exact paragraph to silence your morning alarm.',
                    style: TextStyle(fontSize: 13, color: AppTheme.slateMuted),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
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
                  'Test Alarm & Ringtone',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Test how your picked ringtone and typing challenge works right now.',
                  style: TextStyle(fontSize: 13, color: AppTheme.slateMuted),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: widget.onTriggerTestAlarm,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Test Alarm & Challenge Now', style: TextStyle(fontWeight: FontWeight.bold)),
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
        ],
      ),
    );
  }
}
