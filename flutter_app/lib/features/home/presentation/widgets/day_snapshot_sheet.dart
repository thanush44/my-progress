import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/services/storage_service.dart';
import '../../../dsa/presentation/widgets/day_counter_sheet.dart';

class DaySnapshotSheet extends StatefulWidget {
  final DateTime date;
  final int dayOfYear;
  final int totalYearDays;
  final VoidCallback onDataChanged;
  final void Function(DateTime date)? onJumpToNotes;

  const DaySnapshotSheet({
    Key? key,
    required this.date,
    required this.dayOfYear,
    required this.totalYearDays,
    required this.onDataChanged,
    this.onJumpToNotes,
  }) : super(key: key);

  static void show({
    required BuildContext context,
    required DateTime date,
    required int dayOfYear,
    required int totalYearDays,
    required VoidCallback onDataChanged,
    void Function(DateTime date)? onJumpToNotes,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DaySnapshotSheet(
        date: date,
        dayOfYear: dayOfYear,
        totalYearDays: totalYearDays,
        onDataChanged: onDataChanged,
        onJumpToNotes: onJumpToNotes,
      ),
    );
  }

  @override
  State<DaySnapshotSheet> createState() => _DaySnapshotSheetState();
}

class _DaySnapshotSheetState extends State<DaySnapshotSheet> {
  int _dsaCount = 0;
  String _noteText = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDayData();
  }

  Future<void> _loadDayData() async {
    final dateKey = AppDateUtils.formatDateKey(widget.date);
    final count = await StorageService.getDsaCountForDate(dateKey);
    final note = await StorageService.getNoteForDate(dateKey);

    if (mounted) {
      setState(() {
        _dsaCount = count;
        _noteText = note;
        _isLoading = false;
      });
    }
  }

  bool get _isToday {
    final now = DateTime.now();
    return widget.date.year == now.year &&
        widget.date.month == now.month &&
        widget.date.day == now.day;
  }

  bool get _isFuture {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(widget.date.year, widget.date.month, widget.date.day);
    return day.isAfter(today);
  }

  void _openCounterSheet() {
    final dateKey = AppDateUtils.formatDateKey(widget.date);
    final monthName = AppDateUtils.getMonthName(widget.date.month, widget.date.year);

    DayCounterSheet.show(
      context: context,
      dateKey: dateKey,
      dayNum: widget.date.day,
      monthName: monthName,
      year: widget.date.year,
      initialCount: _dsaCount,
      onSaved: () {
        _loadDayData();
        widget.onDataChanged();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullDate = AppDateUtils.getFormattedFullDate(widget.date);

    String statusBadgeText;
    Color statusBgColor;
    Color statusTextColor;

    if (_isToday) {
      statusBadgeText = 'TODAY';
      statusBgColor = AppTheme.bgGreen;
      statusTextColor = AppTheme.primary;
    } else if (_isFuture) {
      statusBadgeText = 'UPCOMING';
      statusBgColor = const Color(0xFFF1F5F9);
      statusTextColor = AppTheme.slateMuted;
    } else {
      statusBadgeText = 'COMPLETED DAY';
      statusBgColor = AppTheme.bgGreen;
      statusTextColor = AppTheme.primaryMid;
    }

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
          // Drag handle
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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Text(
                  statusBadgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: statusTextColor,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Text(
                'Day ${widget.dayOfYear} of ${widget.totalYearDays}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.slateMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            fullDate,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 20),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: CircularProgressIndicator(color: AppTheme.emerald)),
            )
          else ...[
            // DSA Section Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgGreen,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.lightMint),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.grid_on, color: AppTheme.mint, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DSA Problems Solved',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.slateMuted),
                        ),
                        Text(
                          '$_dsaCount Problems',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _openCounterSheet,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryDark,
                      side: const BorderSide(color: AppTheme.primaryMid),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Log', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Daily Notes Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.edit_note, color: AppTheme.primary, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Daily Focus Note',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
                          ),
                        ],
                      ),
                      if (widget.onJumpToNotes != null)
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onJumpToNotes!(widget.date);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(60, 24),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Open Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _noteText.isEmpty ? 'No notes written for this day.' : _noteText,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: _noteText.isEmpty ? FontStyle.italic : FontStyle.normal,
                      color: _noteText.isEmpty ? AppTheme.slateMuted : AppTheme.darkText,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Close Button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}
