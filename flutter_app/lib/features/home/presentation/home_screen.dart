import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import 'widgets/day_snapshot_sheet.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const HomeScreen({Key? key, this.onNavigateTab}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _onDotTapped(int dayNum, int totalYearDays, int year) {
    final date = AppDateUtils.getDateFromDayOfYear(year, dayNum);
    DaySnapshotSheet.show(
      context: context,
      date: date,
      dayOfYear: dayNum,
      totalYearDays: totalYearDays,
      onDataChanged: () => setState(() {}),
      onJumpToNotes: (selectedDate) {
        if (widget.onNavigateTab != null) {
          widget.onNavigateTab!(3); // Index 3 is Notes
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final fullDateStr = AppDateUtils.getFormattedFullDate(now);
    final yearStats = AppDateUtils.getYearStats(now);
    final monthStats = AppDateUtils.getMonthStats(now);
    final weekStats = AppDateUtils.getWeekStats(now);

    final totalYearDays = yearStats['totalDays'] as int;
    final currentDayNum = yearStats['currentDayNumber'] as int;
    final currentYear = yearStats['year'] as int;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome Banner
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryDark, AppTheme.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryDark.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'MY PROGRESS',
                    style: TextStyle(
                      color: AppTheme.mint,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Good Morning 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fullDateStr,
                  style: const TextStyle(
                    color: AppTheme.tintGreen,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Year Progress Dots Grid Card
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
                          Text(
                            '$currentYear',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryDark,
                              height: 1,
                            ),
                          ),
                          const Text(
                            'Year Progress',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.slateMuted,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.bgGreen,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.lightMint),
                        ),
                        child: Text(
                          '${((yearStats['completed'] / totalYearDays) * 100).round()}%',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Dots Wrap/Grid Container
                  Container(
                    height: 220,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFCFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: List.generate(totalYearDays, (index) {
                          final dayNum = index + 1;
                          Color dotColor;
                          BoxBorder? border;
                          BoxShadow? shadow;

                          if (dayNum < currentDayNum) {
                            dotColor = AppTheme.emerald;
                          } else if (dayNum == currentDayNum) {
                            dotColor = AppTheme.primaryMid;
                            shadow = BoxShadow(
                              color: AppTheme.emerald.withValues(alpha: 0.5),
                              blurRadius: 6,
                              spreadRadius: 2,
                            );
                          } else {
                            dotColor = Colors.white;
                            border = Border.all(color: AppTheme.borderLight, width: 1.5);
                          }

                          return InkWell(
                            onTap: () => _onDotTapped(dayNum, totalYearDays, currentYear),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(1.5),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: dotColor,
                                  shape: BoxShape.circle,
                                  border: border,
                                  boxShadow: shadow != null ? [shadow] : null,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // User guidance helper
                  const Center(
                    child: Text(
                      'Tap any dot to inspect solved problems & notes',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dots Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem(AppTheme.emerald, 'Completed (${yearStats['completed']})'),
                      _buildLegendItem(AppTheme.primaryMid, 'Today'),
                      _buildLegendItem(Colors.white, 'Future (${yearStats['remaining']})', isOutline: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Year Statistics
          _buildSectionTitle('YEAR STATISTICS'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildStatCard('Days Completed', '${yearStats['completed']}', AppTheme.primaryMid)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard('Days Remaining', '${yearStats['remaining']}', AppTheme.slateMuted)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard('Total Days', '${yearStats['totalDays']}', AppTheme.primaryDark)),
            ],
          ),
          const SizedBox(height: 18),

          // Month Statistics
          _buildSectionTitle('MONTH STATISTICS'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${monthStats['monthName']} ${monthStats['year']}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.bgGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${((monthStats['completed'] / monthStats['totalDays']) * 100).round()}% Done',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRowStat('Days Completed', '${monthStats['completed']}', AppTheme.primaryMid),
                      _buildRowStat('Days Remaining', '${monthStats['remaining']}', AppTheme.slateMuted),
                      _buildRowStat('Total Days', '${monthStats['totalDays']}', AppTheme.darkText),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Week Statistics
          _buildSectionTitle('WEEK STATISTICS'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'This Week',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.bgGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${((weekStats['completed'] / weekStats['totalDays']) * 100).round()}% Passed',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRowStat('Days Completed', '${weekStats['completed']}', AppTheme.primaryMid),
                      _buildRowStat('Days Remaining', '${weekStats['remaining']}', AppTheme.slateMuted),
                      _buildRowStat('Total Days', '${weekStats['totalDays']}', AppTheme.darkText),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: AppTheme.slateMuted,
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool isOutline = false}) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isOutline ? Border.all(color: AppTheme.borderLight, width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.slateMuted),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.slateMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildRowStat(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.slateMuted)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: valueColor)),
      ],
    );
  }
}
