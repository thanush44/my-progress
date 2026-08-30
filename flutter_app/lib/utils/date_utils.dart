import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDateKey(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  static int getDaysInYear(int year) {
    return isLeapYear(year) ? 366 : 365;
  }

  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  static int getDayOfYear(DateTime date) {
    final diff = date.difference(DateTime(date.year, 1, 1));
    return diff.inDays + 1;
  }

  static String getFormattedFullDate(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy').format(date);
  }

  static String getMonthName(int month) {
    final date = DateTime(2026, month, 1);
    return DateFormat('MMMM').format(date);
  }

  static Map<String, dynamic> getYearStats(DateTime now) {
    final year = now.year;
    final totalDays = getDaysInYear(year);
    final completed = getDayOfYear(now);
    final remaining = (totalDays - completed).clamp(0, totalDays);

    return {
      'year': year,
      'totalDays': totalDays,
      'completed': completed,
      'remaining': remaining,
      'currentDayNumber': completed,
    };
  }

  static Map<String, dynamic> getMonthStats(DateTime now) {
    final year = now.year;
    final month = now.month;
    final monthName = getMonthName(month);
    final totalDays = getDaysInMonth(year, month);
    final completed = now.day;
    final remaining = (totalDays - completed).clamp(0, totalDays);

    return {
      'year': year,
      'month': month,
      'monthName': monthName,
      'totalDays': totalDays,
      'completed': completed,
      'remaining': remaining,
    };
  }

  static Map<String, dynamic> getWeekStats(DateTime now) {
    // 1=Monday ... 7=Sunday
    final weekday = now.weekday;
    const totalDays = 7;
    final completed = weekday;
    final remaining = totalDays - completed;

    return {
      'completed': completed,
      'remaining': remaining,
      'totalDays': totalDays,
    };
  }
}
