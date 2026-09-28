import 'package:intl/intl.dart';

/// Formatter for human-readable dates, booking ranges, and timestamps.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _dayMonthYear = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _dayMonthYearTime = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  static final DateFormat _dayMonth = DateFormat('dd MMM', 'id_ID');

  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    try {
      return _dayMonthYear.format(date);
    } catch (_) {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    try {
      return _dayMonthYearTime.format(dateTime);
    } catch (_) {
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    }
  }

  static String formatDateRange(DateTime start, DateTime end) {
    try {
      return '${_dayMonth.format(start)} - ${_dayMonthYear.format(end)}';
    } catch (_) {
      return '${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}';
    }
  }

  static int calculateRentalDays(DateTime start, DateTime end) {
    final difference = end.difference(start).inHours;
    if (difference <= 0) return 1;
    // At least 1 day; every subsequent 24 hours counts
    return (difference / 24).ceil();
  }
}
