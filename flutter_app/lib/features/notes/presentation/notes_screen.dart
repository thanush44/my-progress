import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/services/storage_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  Map<String, String> _allNotes = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _saveStatus = 'Saved ✓';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _noteController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final notes = await StorageService.getAllNotes();
    final dateKey = AppDateUtils.formatDateKey(_selectedDate);
    final currentNote = notes[dateKey] ?? '';

    if (mounted) {
      setState(() {
        _allNotes = notes;
        _noteController.text = currentNote;
        _isLoading = false;
        _saveStatus = 'Saved ✓';
      });
    }
  }

  void _onNoteTextChanged(String text) {
    setState(() {
      _saveStatus = 'Saving...';
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () async {
      final dateKey = AppDateUtils.formatDateKey(_selectedDate);
      await StorageService.saveNoteForDate(dateKey, text);
      final notes = await StorageService.getAllNotes();
      if (mounted) {
        setState(() {
          _allNotes = notes;
          _saveStatus = 'Saved ✓';
        });
      }
    });
  }

  void _selectPresetDay(int dayOffsetFromToday) {
    _debounceTimer?.cancel();
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day).add(Duration(days: dayOffsetFromToday));
    setState(() {
      _selectedDate = target;
      final dateKey = AppDateUtils.formatDateKey(target);
      _noteController.text = _allNotes[dateKey] ?? '';
      _saveStatus = 'Saved ✓';
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _selectedDate) {
      _debounceTimer?.cancel();
      setState(() {
        _selectedDate = picked;
        final dateKey = AppDateUtils.formatDateKey(picked);
        _noteController.text = _allNotes[dateKey] ?? '';
        _saveStatus = 'Saved ✓';
      });
    }
  }

  Future<void> _saveNoteManual() async {
    _debounceTimer?.cancel();
    final dateKey = AppDateUtils.formatDateKey(_selectedDate);
    final text = _noteController.text;
    await StorageService.saveNoteForDate(dateKey, text);
    await _loadNotes();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note saved successfully ✓')),
      );
    }
  }

  Future<void> _deleteNote(String dateKey) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete note for $dateKey?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.deleteNoteForDate(dateKey);
      await _loadNotes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted')),
        );
      }
    }
  }

  void _openBackupModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24.0),
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
                'Data Backup & Portability',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
              ),
              const SizedBox(height: 6),
              const Text(
                'Safely export your daily notes, DSA logs, and alarm settings to keep your data private and safe.',
                style: TextStyle(fontSize: 13, color: AppTheme.slateMuted),
              ),
              const SizedBox(height: 20),

              // Export Button
              ElevatedButton.icon(
                icon: const Icon(Icons.copy_all),
                label: const Text('Copy Backup JSON to Clipboard', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () async {
                  final jsonStr = await StorageService.exportBackupJson();
                  await Clipboard.setData(ClipboardData(text: jsonStr));
                  if (mounted) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Backup JSON copied to clipboard ✓')),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),

              // Import Button
              OutlinedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Restore from Backup JSON', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryDark,
                  side: const BorderSide(color: AppTheme.borderLight, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _openImportDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openImportDialog() {
    final importController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Restore Backup', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste your backup JSON below to restore your progress:',
                style: TextStyle(fontSize: 13, color: AppTheme.slateMuted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: importController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Paste backup JSON string here...',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderLight),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final text = importController.text.trim();
                if (text.isNotEmpty) {
                  final success = await StorageService.importBackupJson(text);
                  if (mounted) {
                    Navigator.of(ctx).pop();
                    if (success) {
                      await _loadNotes();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data restored successfully ✓')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid backup JSON format')),
                      );
                    }
                  }
                }
              },
              child: const Text('Restore'),
            ),
          ],
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.emerald));
    }

    final formattedFullDate = AppDateUtils.getFormattedFullDate(_selectedDate);

    final sortedKeys = _allNotes.keys.toList()..sort((a, b) => b.compareTo(a));
    final filteredKeys = sortedKeys.where((k) {
      if (_searchQuery.isEmpty) return true;
      final content = _allNotes[k] ?? '';
      return k.contains(_searchQuery.toLowerCase()) || content.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Notes',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Reflect, journal learnings & track consistency.',
                    style: TextStyle(fontSize: 13, color: AppTheme.slateMuted),
                  ),
                ],
              ),
              IconButton.outlined(
                icon: const Icon(Icons.cloud_sync_outlined, color: AppTheme.primaryDark),
                tooltip: 'Backup & Export',
                onPressed: _openBackupModal,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Date Strip
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ActionChip(
                  label: const Text('Yesterday'),
                  backgroundColor: AppTheme.bgGreen,
                  side: const BorderSide(color: AppTheme.lightMint),
                  labelStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                  onPressed: () => _selectPresetDay(-1),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Today'),
                  backgroundColor: AppTheme.primaryDark,
                  side: BorderSide.none,
                  labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  onPressed: () => _selectPresetDay(0),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Tomorrow'),
                  backgroundColor: AppTheme.bgGreen,
                  side: const BorderSide(color: AppTheme.lightMint),
                  labelStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                  onPressed: () => _selectPresetDay(1),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Icon(Icons.calendar_month, size: 16, color: AppTheme.slateMuted),
                  label: const Text('Pick Date'),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppTheme.borderLight),
                  labelStyle: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 12),
                  onPressed: _selectDate,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Note Editor Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.bgGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _isToday(_selectedDate) ? "TODAY'S NOTES" : "DATE NOTE",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedFullDate,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
                          ),
                        ],
                      ),
                      // Live Auto-Save status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _saveStatus == 'Saving...' ? Colors.amber.shade50 : AppTheme.bgGreen,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _saveStatus == 'Saving...' ? Colors.amber.shade300 : AppTheme.lightMint,
                          ),
                        ),
                        child: Text(
                          _saveStatus,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _saveStatus == 'Saving...' ? Colors.amber.shade800 : AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Text Editor
                  TextField(
                    controller: _noteController,
                    maxLines: 8,
                    onChanged: _onNoteTextChanged,
                    decoration: InputDecoration(
                      hintText: 'Write your notes here... (Auto-saves as you type)',
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
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_noteController.text.length} characters',
                        style: const TextStyle(fontSize: 12, color: AppTheme.slateMuted),
                      ),
                      ElevatedButton.icon(
                        onPressed: _saveNoteManual,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Save Now', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // History Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Previous Notes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.bgGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_allNotes.length} Saved',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Search Box
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search notes...',
              prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.slateMuted),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.borderLight),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // History List
          if (filteredKeys.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.notes_outlined, size: 40, color: AppTheme.slateMuted),
                  SizedBox(height: 8),
                  Text(
                    'No notes found',
                    style: TextStyle(color: AppTheme.slateMuted, fontSize: 14),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredKeys.length,
              itemBuilder: (context, index) {
                final key = filteredKeys[index];
                final content = _allNotes[key] ?? '';
                final isCurrentSelected = key == AppDateUtils.formatDateKey(_selectedDate);

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isCurrentSelected ? AppTheme.emerald : AppTheme.borderLight,
                      width: isCurrentSelected ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      key,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryDark),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18, color: AppTheme.primary),
                          onPressed: () {
                            final parts = key.split('-');
                            final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
                            setState(() {
                              _selectedDate = date;
                              _noteController.text = content;
                              _saveStatus = 'Saved ✓';
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          onPressed: () => _deleteNote(key),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
