import 'package:easybook_app/features/services/data/models/availability_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps the start time string exactly as the API sent it', () {
    final availability = AvailabilityModel.fromJson({
      'serviceId': 's1',
      'date': '2026-11-18',
      'timeZone': 'Asia/Dhaka',
      'durationMinutes': 60,
      'slots': [
        {
          'startTime': '2026-11-18T03:00:00.000Z',
          'endTime': '2026-11-18T04:00:00.000Z',
          'available': true,
        },
        {
          'startTime': '2026-11-18T03:30:00.000Z',
          'endTime': '2026-11-18T04:30:00.000Z',
          'available': false,
        },
      ],
    }).toEntity();

    expect(availability.date, '2026-11-18');
    expect(availability.slots, hasLength(2));
    final first = availability.slots.first;
    expect(first.startTimeValue, '2026-11-18T03:00:00.000Z');
    expect(first.start, DateTime.utc(2026, 11, 18, 3));
    expect(first.start.isUtc, isTrue);
    expect(availability.slots.last.available, isFalse);
    expect(availability.hasAvailableSlot, isTrue);
  });
}
