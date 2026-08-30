import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';
import '../services/storage_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadNotes();
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
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        final dateKey = AppDateUtils.formatDateKey(picked);
        _noteController.text = _allNotes[dateKey] ?? '';
      });
    }
  }

  Future<void> _saveNote() async {
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
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
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

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.emerald));
    }

    final dateKey = AppDateUtils.formatDateKey(_selectedDate);
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
          const Text(
            'Daily Notes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
          ),
          const SizedBox(height: 4),
          const Text(
            'Journal your thoughts, daily learnings, and DSA reflections.',
            style: TextStyle(fontSize: 13, color: AppTheme.slateMuted),
          ),
          const SizedBox(height: 16),

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
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 1),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedFullDate,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
                          ),
                        ],
                      ),
                      IconButton.outlined(
                        icon: const Icon(Icons.calendar_today, size: 18, color: AppTheme.primaryDark),
                        onPressed: _selectDate,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Text Editor
                  TextField(
                    controller: _noteController,
                    maxLines: 8,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Write your notes here... (e.g. Completed 5 DSA problems, learned about embeddings...)',
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
                        onPressed: _saveNote,
                        icon: const Icon(Icons.save, size: 18),
                        label: const Text('Save Note', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.borderLight),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          const SizedBox(height: 14),

          // History List
          if (filteredKeys.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              alignment: Alignment.center,
              child: Text(
                _searchQuery.isNotEmpty ? 'No notes matching search.' : 'No previous notes recorded yet.',
                style: const TextStyle(fontSize: 13, color: AppTheme.slateMuted),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredKeys.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final k = filteredKeys[index];
                final content = _allNotes[k] ?? '';
                final isSelected = k == dateKey;

                return InkWell(
                  onTap: () {
                    final parts = k.split('-').map(int.parse).toList();
                    setState(() {
                      _selectedDate = DateTime(parts[0], parts[1], parts[2]);
                      _noteController.text = content;
                    });
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.bgGreen : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppTheme.emerald : AppTheme.borderLight,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              k,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                              onPressed: () => _deleteNote(k),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: AppTheme.slateMuted, height: 1.4),
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
