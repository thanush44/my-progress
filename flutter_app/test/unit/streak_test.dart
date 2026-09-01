import 'package:flutter_test/flutter_test.dart';
import 'package:my_progress/core/utils/streak_utils.dart';

void main() {
  group('StreakUtils Tests', () {
    final baseDate = DateTime(2026, 9, 1);

    test('empty data returns 0 streaks', () {
      final stats = StreakUtils.calculateStreak({}, baseDate);
      expect(stats.currentStreak, equals(0));
      expect(stats.longestStreak, equals(0));
      expect(stats.totalSolved, equals(0));
    });

    test('active today counts towards current streak', () {
      final data = {
        '2026-08-31': 3,
        '2026-09-01': 2,
      };
      final stats = StreakUtils.calculateStreak(data, baseDate);
      expect(stats.currentStreak, equals(2));
      expect(stats.longestStreak, equals(2));
      expect(stats.totalSolved, equals(5));
      expect(stats.activeDays, equals(2));
    });

    test('streak is alive if completed yesterday but not yet today', () {
      final data = {
        '2026-08-30': 1,
        '2026-08-31': 4,
      };
      final stats = StreakUtils.calculateStreak(data, baseDate);
      expect(stats.currentStreak, equals(2));
      expect(stats.longestStreak, equals(2));
    });

    test('broken streak drops current streak to 0 if missed yesterday and today', () {
      final data = {
        '2026-08-25': 2,
        '2026-08-26': 3,
      };
      final stats = StreakUtils.calculateStreak(data, baseDate);
      expect(stats.currentStreak, equals(0));
      expect(stats.longestStreak, equals(2));
    });

    test('longest streak tracks maximum historical consecutive sequence', () {
      final data = {
        // 4 consecutive days
        '2026-08-10': 2,
        '2026-08-11': 1,
        '2026-08-12': 3,
        '2026-08-13': 5,
        // gap
        '2026-08-20': 1,
        '2026-08-21': 2,
        // gap
        '2026-09-01': 3,
      };
      final stats = StreakUtils.calculateStreak(data, baseDate);
      expect(stats.longestStreak, equals(4));
      expect(stats.currentStreak, equals(1));
      expect(stats.totalSolved, equals(17));
    });
  });
}
