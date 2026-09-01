import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String keyAlarm = 'my_progress_alarm_v1';
  static const String keyDsa = 'my_progress_dsa_v1';
  static const String keyNotes = 'my_progress_notes_v1';

  static final Map<String, dynamic> _defaultAlarm = {
    'enabled': true,
    'time': '06:30',
    'period': 'AM',
    'ringtonePath': '',
    'ringtoneName': 'Default Tone',
    'challengeText': 'I will stay consistent with my goals and complete my daily work today.'
  };

  // Alarm Settings
  static Future<Map<String, dynamic>> getAlarmSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(keyAlarm);
      if (raw == null) return Map<String, dynamic>.from(_defaultAlarm);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return {..._defaultAlarm, ...data};
    } catch (e) {
      return Map<String, dynamic>.from(_defaultAlarm);
    }
  }

  static Future<void> saveAlarmSettings(Map<String, dynamic> settings) async {
    try {
      final current = await getAlarmSettings();
      final updated = {...current, ...settings};
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyAlarm, jsonEncode(updated));
    } catch (e) {
      // Error handling
    }
  }

  // DSA Progress: Map<String, int> {"YYYY-MM-DD": count}
  static Future<Map<String, int>> getAllDsaProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(keyDsa);
      if (raw == null) return {};
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return data.map((key, value) => MapEntry(key, (value as num).toInt()));
    } catch (e) {
      return {};
    }
  }

  static Future<int> getDsaCountForDate(String dateKey) async {
    final all = await getAllDsaProgress();
    return all[dateKey] ?? 0;
  }

  static Future<void> setDsaCountForDate(String dateKey, int count) async {
    try {
      final all = await getAllDsaProgress();
      final validCount = count < 0 ? 0 : count;
      all[dateKey] = validCount;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyDsa, jsonEncode(all));
    } catch (e) {
      // Error handling
    }
  }

  // Daily Notes: Map<String, String> {"YYYY-MM-DD": content}
  static Future<Map<String, String>> getAllNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(keyNotes);
      if (raw == null) return {};
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return data.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return {};
    }
  }

  static Future<String> getNoteForDate(String dateKey) async {
    final all = await getAllNotes();
    return all[dateKey] ?? '';
  }

  static Future<void> saveNoteForDate(String dateKey, String content) async {
    try {
      final all = await getAllNotes();
      final trimmed = content.trim();
      if (trimmed.isEmpty) {
        all.remove(dateKey);
      } else {
        all[dateKey] = trimmed;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyNotes, jsonEncode(all));
    } catch (e) {
      // Error handling
    }
  }

  static Future<void> deleteNoteForDate(String dateKey) async {
    try {
      final all = await getAllNotes();
      all.remove(dateKey);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyNotes, jsonEncode(all));
    } catch (e) {
      // Error handling
    }
  }

  // Export all application data as portable JSON
  static Future<String> exportBackupJson() async {
    final alarm = await getAlarmSettings();
    final dsa = await getAllDsaProgress();
    final notes = await getAllNotes();

    final backup = {
      'app': 'My Progress',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'alarm': alarm,
      'dsa': dsa,
      'notes': notes,
    };

    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  // Import application data from JSON
  static Future<bool> importBackupJson(String rawJson) async {
    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();

      if (decoded.containsKey('alarm') && decoded['alarm'] is Map) {
        await prefs.setString(keyAlarm, jsonEncode(decoded['alarm']));
      }

      if (decoded.containsKey('dsa') && decoded['dsa'] is Map) {
        final dsaMap = (decoded['dsa'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
        await prefs.setString(keyDsa, jsonEncode(dsaMap));
      }

      if (decoded.containsKey('notes') && decoded['notes'] is Map) {
        final notesMap = (decoded['notes'] as Map).map((k, v) => MapEntry(k.toString(), v.toString()));
        await prefs.setString(keyNotes, jsonEncode(notesMap));
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
