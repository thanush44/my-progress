import 'package:flutter_test/flutter_test.dart';
import 'package:my_progress/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils Tests', () {
    test('isLeapYear identifies leap years correctly', () {
      expect(AppDateUtils.isLeapYear(2024), isTrue);
      expect(AppDateUtils.isLeapYear(2028), isTrue);
      expect(AppDateUtils.isLeapYear(2000), isTrue);

      expect(AppDateUtils.isLeapYear(2025), isFalse);
      expect(AppDateUtils.isLeapYear(2026), isFalse);
      expect(AppDateUtils.isLeapYear(2100), isFalse);
    });

    test('getDaysInYear returns 366 for leap years and 365 for non-leap years', () {
      expect(AppDateUtils.getDaysInYear(2024), equals(366));
      expect(AppDateUtils.getDaysInYear(2026), equals(365));
    });

    test('getDaysInMonth returns correct days across months', () {
      expect(AppDateUtils.getDaysInMonth(2026, 1), equals(31)); // Jan
      expect(AppDateUtils.getDaysInMonth(2026, 2), equals(28)); // Feb non-leap
      expect(AppDateUtils.getDaysInMonth(2024, 2), equals(29)); // Feb leap
      expect(AppDateUtils.getDaysInMonth(2026, 4), equals(30)); // Apr
      expect(AppDateUtils.getDaysInMonth(2026, 12), equals(31)); // Dec
    });

    test('formatDateKey formats consistently with zero-padded months and days', () {
      expect(AppDateUtils.formatDateKey(DateTime(2026, 1, 5)), equals('2026-01-05'));
      expect(AppDateUtils.formatDateKey(DateTime(2026, 12, 25)), equals('2026-12-25'));
    });

    test('getDayOfYear handles beginning and end of year correctly', () {
      expect(AppDateUtils.getDayOfYear(DateTime(2026, 1, 1)), equals(1));
      expect(AppDateUtils.getDayOfYear(DateTime(2026, 1, 2)), equals(2));
    });

    test('getDateFromDayOfYear reverses dayOfYear correctly', () {
      final date1 = AppDateUtils.getDateFromDayOfYear(2026, 1);
      expect(date1.month, equals(1));
      expect(date1.day, equals(1));

      final date32 = AppDateUtils.getDateFromDayOfYear(2026, 32);
      expect(date32.month, equals(2));
      expect(date32.day, equals(1));
    });
  });
}
