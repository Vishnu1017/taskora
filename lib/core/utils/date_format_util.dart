import 'package:intl/intl.dart';

/// Clean and expressive relative date and time formatting utilities.
class DateFormatUtil {
  DateFormatUtil._();

  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _shortDateFormat = DateFormat('MMM d');
  static final DateFormat _fullDateFormat = DateFormat('EEE, MMM d, yyyy');
  static final DateFormat _dayOfWeekFormat = DateFormat('EEE');
  static final DateFormat _dayNumberFormat = DateFormat('d');

  static String formatTime(DateTime date) => _timeFormat.format(date);
  static String formatShortDate(DateTime date) => _shortDateFormat.format(date);
  static String formatFullDate(DateTime date) => _fullDateFormat.format(date);
  static String formatDayOfWeek(DateTime date) => _dayOfWeekFormat.format(date);
  static String formatDayNumber(DateTime date) => _dayNumberFormat.format(date);

  /// Returns friendly human-readable relative string:
  /// "Today, 4:00 PM", "Tomorrow, 9:00 AM", "Yesterday", or "Oct 24, 2:30 PM".
  static String formatRelative(DateTime? date, {bool includeTime = true}) {
    if (date == null) return 'No due date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final differenceDays = target.difference(today).inDays;

    String dateStr;
    if (differenceDays == 0) {
      dateStr = 'Today';
    } else if (differenceDays == 1) {
      dateStr = 'Tomorrow';
    } else if (differenceDays == -1) {
      dateStr = 'Yesterday';
    } else if (differenceDays > 1 && differenceDays < 7) {
      dateStr = DateFormat('EEEE').format(date);
    } else {
      dateStr = _shortDateFormat.format(date);
    }

    if (includeTime) {
      return '$dateStr, ${_timeFormat.format(date)}';
    }
    return dateStr;
  }

  /// Checks if two dates are on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
