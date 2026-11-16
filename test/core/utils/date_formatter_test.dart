import 'package:easybook_app/core/utils/date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(initializeDateFormatting);

  group('DateFormatter', () {
    test('parseToLocal returns the same instant in local time', () {
      final local = DateFormatter.parseToLocal('2026-11-18T03:00:00.000Z');
      expect(local.isUtc, isFalse);
      expect(local.toUtc(), DateTime.utc(2026, 11, 18, 3));
    });

    test('toApiDateTime sends UTC ISO 8601', () {
      final value = DateTime.utc(2026, 11, 18, 3).toLocal();
      expect(DateFormatter.toApiDateTime(value), '2026-11-18T03:00:00.000Z');
    });

    test('toApiDate uses the picked calendar day, not a UTC conversion', () {
      // 00:30 local time on Nov 18 is still Nov 18, whatever the time zone.
      expect(
        DateFormatter.toApiDate(DateTime(2026, 11, 18, 0, 30)),
        '2026-11-18',
      );
      expect(DateFormatter.toApiDate(DateTime(2026, 1, 5)), '2026-01-05');
    });

    test('formats display values for the given locale', () {
      final value = DateTime(2026, 11, 18, 15, 30);
      expect(DateFormatter.time(value, 'en'), '3:30 PM');
      expect(DateFormatter.fullDate(value, 'en'), 'Wed, Nov 18, 2026');
      expect(DateFormatter.shortDate(value, 'en'), 'Nov 18');
      expect(DateFormatter.weekdayShort(value, 'en'), 'Wed');
      expect(DateFormatter.dayOfMonth(value, 'en'), '18');
      expect(DateFormatter.monthShort(value, 'en'), 'Nov');
    });

    test('formats a time range', () {
      final start = DateTime(2026, 11, 18, 9);
      final end = DateTime(2026, 11, 18, 10);
      expect(DateFormatter.timeRange(start, end, 'en'), '9:00 AM – 10:00 AM');
    });

    test('supports Bengali', () {
      final value = DateTime(2026, 11, 18);
      expect(DateFormatter.dayOfMonth(value, 'bn'), '১৮');
    });
  });
}
