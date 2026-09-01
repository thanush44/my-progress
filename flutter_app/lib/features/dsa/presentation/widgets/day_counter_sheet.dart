import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/storage_service.dart';

class DayCounterSheet extends StatefulWidget {
  final String dateKey;
  final int dayNum;
  final String monthName;
  final int year;
  final int initialCount;
  final VoidCallback onSaved;

  const DayCounterSheet({
    Key? key,
    required this.dateKey,
    required this.dayNum,
    required this.monthName,
    required this.year,
    required this.initialCount,
    required this.onSaved,
  }) : super(key: key);

  static void show({
    required BuildContext context,
    required String dateKey,
    required int dayNum,
    required String monthName,
    required int year,
    required int initialCount,
    required VoidCallback onSaved,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DayCounterSheet(
        dateKey: dateKey,
        dayNum: dayNum,
        monthName: monthName,
        year: year,
        initialCount: initialCount,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<DayCounterSheet> createState() => _DayCounterSheetState();
}

class _DayCounterSheetState extends State<DayCounterSheet> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
  }

  void _save() async {
    await StorageService.setDsaCountForDate(widget.dateKey, _count);
    widget.onSaved();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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

          // Sheet Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.monthName} ${widget.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.slateMuted,
                    ),
                  ),
                  Text(
                    '${widget.monthName} ${widget.dayNum}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Counter Section
          const Text(
            'Problems Completed',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.slateMuted,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.outlined(
                iconSize: 28,
                icon: const Icon(Icons.remove),
                color: AppTheme.primaryDark,
                onPressed: () {
                  if (_count > 0) {
                    setState(() => _count--);
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Text(
                  '$_count',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ),
              IconButton.outlined(
                iconSize: 28,
                icon: const Icon(Icons.add),
                color: AppTheme.primaryDark,
                onPressed: () {
                  setState(() => _count++);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Preset Chips
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                label: const Text('+1 Problem'),
                backgroundColor: AppTheme.bgGreen,
                side: const BorderSide(color: AppTheme.lightMint),
                labelStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                onPressed: () => setState(() => _count += 1),
              ),
              ActionChip(
                label: const Text('+2 Problems'),
                backgroundColor: AppTheme.bgGreen,
                side: const BorderSide(color: AppTheme.lightMint),
                labelStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                onPressed: () => setState(() => _count += 2),
              ),
              ActionChip(
                label: const Text('+5 Problems'),
                backgroundColor: AppTheme.bgGreen,
                side: const BorderSide(color: AppTheme.lightMint),
                labelStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                onPressed: () => setState(() => _count += 5),
              ),
              ActionChip(
                label: const Text('Reset 0'),
                backgroundColor: const Color(0xFFF1F5F9),
                side: const BorderSide(color: AppTheme.borderLight),
                labelStyle: const TextStyle(color: AppTheme.slateMuted, fontWeight: FontWeight.bold, fontSize: 12),
                onPressed: () => setState(() => _count = 0),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Save Button
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Save Progress',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
