import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';

/// 30 -> "30 min", 60 -> "1 h", 90 -> "1 h 30 min" (digits follow the
/// locale, so Bengali shows "১ ঘণ্টা ৩০ মিনিট").
abstract final class DurationFormatter {
  static String format(int totalMinutes, String locale) {
    final number = NumberFormat.decimalPattern(locale);
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0) {
      return LocaleKeys.services_duration_minutes.tr(
        namedArgs: {'minutes': number.format(minutes)},
      );
    }
    if (minutes == 0) {
      return LocaleKeys.services_duration_hours.tr(
        namedArgs: {'hours': number.format(hours)},
      );
    }
    return LocaleKeys.services_duration_hours_minutes.tr(
      namedArgs: {
        'hours': number.format(hours),
        'minutes': number.format(minutes),
      },
    );
  }
}
