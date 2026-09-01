class StreakUtils {
  /// Computes streak statistics from a map of {"YYYY-MM-DD": count}
  static StreakStats calculateStreak(Map<String, int> dsaData, [DateTime? referenceDate]) {
    if (dsaData.isEmpty) {
      return StreakStats(
        currentStreak: 0,
        longestStreak: 0,
        totalSolved: 0,
        activeDays: 0,
      );
    }

    int totalSolved = 0;
    int activeDays = 0;
    final Set<String> activeDateKeys = {};

    for (final entry in dsaData.entries) {
      final count = entry.value;
      if (count > 0) {
        totalSolved += count;
        activeDays++;
        activeDateKeys.add(entry.key);
      }
    }

    if (activeDateKeys.isEmpty) {
      return StreakStats(
        currentStreak: 0,
        longestStreak: 0,
        totalSolved: totalSolved,
        activeDays: 0,
      );
    }

    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayKey = _formatKey(today);
    final yesterdayKey = _formatKey(yesterday);

    // Calculate current streak
    int currentStreak = 0;
    DateTime checkDate;

    if (activeDateKeys.contains(todayKey)) {
      // Streak starts with today
      currentStreak = 1;
      checkDate = yesterday;
      while (activeDateKeys.contains(_formatKey(checkDate))) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    } else if (activeDateKeys.contains(yesterdayKey)) {
      // User hasn't logged today yet, but streak from yesterday is still alive
      currentStreak = 1;
      checkDate = yesterday.subtract(const Duration(days: 1));
      while (activeDateKeys.contains(_formatKey(checkDate))) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    } else {
      currentStreak = 0;
    }

    // Calculate longest historic streak
    final sortedDates = activeDateKeys.map((k) {
      final parts = k.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    }).toList()..sort();

    int longestStreak = 0;
    int runningStreak = 0;
    DateTime? prevDate;

    for (final d in sortedDates) {
      if (prevDate == null) {
        runningStreak = 1;
      } else {
        final diff = d.difference(prevDate).inDays;
        if (diff == 1) {
          runningStreak++;
        } else if (diff > 1) {
          runningStreak = 1;
        }
      }
      prevDate = d;
      if (runningStreak > longestStreak) {
        longestStreak = runningStreak;
      }
    }

    return StreakStats(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalSolved: totalSolved,
      activeDays: activeDays,
    );
  }

  static String _formatKey(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class StreakStats {
  final int currentStreak;
  final int longestStreak;
  final int totalSolved;
  final int activeDays;

  StreakStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalSolved,
    required this.activeDays,
  });
}
