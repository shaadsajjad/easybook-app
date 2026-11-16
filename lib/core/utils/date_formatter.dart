import 'package:intl/intl.dart';

/// Date and time helpers.
///
/// The API always sends and receives UTC (ISO 8601). We convert to the
/// device's local time only for display.
abstract final class DateFormatter {
  /// API string -> local DateTime.
  static DateTime parseToLocal(String iso) => DateTime.parse(iso).toLocal();

  /// Any DateTime -> UTC ISO 8601 string for the API.
  static String toApiDateTime(DateTime value) =>
      value.toUtc().toIso8601String();

  /// The picked calendar day -> "yyyy-MM-dd" for `?date=`.
  /// Built from the day's own year/month/day, never from a UTC conversion.
  static String toApiDate(DateTime day) {
    final month = day.month.toString().padLeft(2, '0');
    final date = day.day.toString().padLeft(2, '0');
    return '${day.year}-$month-$date';
  }

  /// "3:30 PM"
  static String time(DateTime value, String locale) =>
      DateFormat.jm(locale).format(value.toLocal());

  /// "3:30 PM – 4:30 PM"
  static String timeRange(DateTime start, DateTime end, String locale) =>
      '${time(start, locale)} – ${time(end, locale)}';

  /// "Wed, Nov 18, 2026"
  static String fullDate(DateTime value, String locale) =>
      DateFormat.yMMMEd(locale).format(value.toLocal());

  /// "Nov 18"
  static String shortDate(DateTime value, String locale) =>
      DateFormat.MMMd(locale).format(value.toLocal());

  /// "Wed"
  static String weekdayShort(DateTime value, String locale) =>
      DateFormat.E(locale).format(value.toLocal());

  /// "18"
  static String dayOfMonth(DateTime value, String locale) =>
      DateFormat.d(locale).format(value.toLocal());

  /// "Nov"
  static String monthShort(DateTime value, String locale) =>
      DateFormat.MMM(locale).format(value.toLocal());
}
