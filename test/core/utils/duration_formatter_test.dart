import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/utils/duration_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

// Translations are not loaded in unit tests, so tr() returns the key and
// we can check which wording (minutes / hours / both) was chosen.
void main() {
  test('uses minutes under an hour', () {
    expect(
      DurationFormatter.format(30, 'en'),
      LocaleKeys.services_duration_minutes,
    );
  });

  test('uses hours for whole hours', () {
    expect(
      DurationFormatter.format(120, 'en'),
      LocaleKeys.services_duration_hours,
    );
  });

  test('uses hours and minutes otherwise', () {
    expect(
      DurationFormatter.format(90, 'en'),
      LocaleKeys.services_duration_hours_minutes,
    );
  });
}
