import 'package:easybook_app/core/utils/booking_reference.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final created = DateTime.utc(2026, 11, 16, 15, 41);
  const idA = '4a202958-e874-485d-8e12-411f46c71aae';
  const idB = 'bc3101b4-c476-434a-b6a2-5163af163feb';

  group('BookingReference.format', () {
    test('is "B-" + two-digit year + three digits', () {
      final reference = BookingReference.format(id: idA, createdAt: created);
      expect(reference, matches(RegExp(r'^B-26\d{3}$')));
      expect(reference, isNot('B-26000'));
    });

    test('is the same every time for the same booking', () {
      expect(
        BookingReference.format(id: idA, createdAt: created),
        BookingReference.format(id: idA, createdAt: created),
      );
    });

    test('differs between bookings', () {
      expect(
        BookingReference.format(id: idA, createdAt: created),
        isNot(BookingReference.format(id: idB, createdAt: created)),
      );
    });

    test('uses the year the booking was made', () {
      final reference = BookingReference.format(
        id: idA,
        createdAt: DateTime.utc(2027, 6),
      );
      expect(reference, startsWith('B-27'));
    });
  });
}
