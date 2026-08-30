import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';
import '../services/storage_service.dart';
import '../widgets/day_counter_sheet.dart';

class DsaScreen extends StatefulWidget {
  const DsaScreen({Key? key}) : super(key: key);

  @override
  State<DsaScreen> createState() => _DsaScreenState();
}

class _DsaScreenState extends State<DsaScreen> {
  late int _selectedMonth;
  late int _selectedYear;
  Map<String, int> _dsaData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await StorageService.getAllDsaProgress();
    if (mounted) {
      setState(() {
        _dsaData = data;
        _isLoading = false;
      });
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth += delta;
      if (_selectedMonth > 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else if (_selectedMonth < 1) {
        _selectedMonth = 12;
        _selectedYear--;
      }
    });
  }

  Color _getContributionColor(int count) {
    if (count == 0) return Colors.white;
    if (count == 1) return const Color(0xFFD1FAE5);
    if (count <= 3) return const Color(0xFF6EE7B7);
    if (count <= 5) return AppTheme.emerald;
    return AppTheme.primaryDark;
  }

  Color _getTextColor(int count) {
    if (count <= 3) return AppTheme.darkText;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.emerald));
    }

    final totalDays = AppDateUtils.getDaysInMonth(_selectedYear, _selectedMonth);
    final monthName = AppDateUtils.getMonthName(_selectedMonth);

    int monthTotalProblems = 0;
    int activeDays = 0;

    for (int d = 1; d <= totalDays; d++) {
      final monthStr = _selectedMonth.toString().padLeft(2, '0');
      final dayStr = d.toString().padLeft(2, '0');
      final dateKey = '$_selectedYear-$monthStr-$dayStr';
      final count = _dsaData[dateKey] ?? 0;
      monthTotalProblems += count;
      if (count > 0) activeDays++;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Text(
            'DSA Progress',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
          ),
          const SizedBox(height: 4),
          const Text(
            'Track your daily algorithm & problem solving consistency.',
            style: TextStyle(fontSize: 13, color: AppTheme.slateMuted),
          ),
          const SizedBox(height: 16),

          // Month Navigation Bar Card
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: AppTheme.primary),
                    onPressed: () => _changeMonth(-1),
                  ),
                  Column(
                    children: [
                      Text(
                        '$monthName $_selectedYear',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
                      ),
                      Text(
                        '$monthTotalProblems Problems Solved',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryMid),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: AppTheme.primary),
                    onPressed: () => _changeMonth(1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Summary Stats Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    children: [
                      const Text('Month Total', style: TextStyle(fontSize: 11, color: AppTheme.slateMuted)),
                      const SizedBox(height: 2),
                      Text('$monthTotalProblems', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primaryMid)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    children: [
                      const Text('Active Days', style: TextStyle(fontSize: 11, color: AppTheme.slateMuted)),
                      const SizedBox(height: 2),
                      Text('$activeDays / $totalDays', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primaryDark)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grid Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Activity Grid ($totalDays Days)',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
                  ),
                  const SizedBox(height: 12),

                  // Legend
                  Row(
                    children: [
                      const Text('Less ', style: TextStyle(fontSize: 11, color: AppTheme.slateMuted, fontWeight: FontWeight.w600)),
                      _buildLegendBox(Colors.white),
                      const SizedBox(width: 4),
                      _buildLegendBox(const Color(0xFFD1FAE5)),
                      const SizedBox(width: 4),
                      _buildLegendBox(const Color(0xFF6EE7B7)),
                      const SizedBox(width: 4),
                      _buildLegendBox(AppTheme.emerald),
                      const SizedBox(width: 4),
                      _buildLegendBox(AppTheme.primaryDark),
                      const SizedBox(width: 4),
                      const Text(' More', style: TextStyle(fontSize: 11, color: AppTheme.slateMuted, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 7-Column Day Boxes Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: totalDays,
                    itemBuilder: (context, index) {
                      final dayNum = index + 1;
                      final monthStr = _selectedMonth.toString().padLeft(2, '0');
                      final dayStr = dayNum.toString().padLeft(2, '0');
                      final dateKey = '$_selectedYear-$monthStr-$dayStr';
                      final count = _dsaData[dateKey] ?? 0;

                      return InkWell(
                        onTap: () {
                          DayCounterSheet.show(
                            context: context,
                            dateKey: dateKey,
                            dayNum: dayNum,
                            monthName: monthName,
                            year: _selectedYear,
                            initialCount: count,
                            onSaved: _loadData,
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getContributionColor(count),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: count == 0 ? AppTheme.borderLight : Colors.transparent,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                '$dayNum',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getTextColor(count),
                                ),
                              ),
                              if (count > 0)
                                Positioned(
                                  bottom: 2,
                                  right: 4,
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: _getTextColor(count).withOpacity(0.85),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: color == Colors.white ? Border.all(color: AppTheme.borderLight) : null,
      ),
    );
  }
}
