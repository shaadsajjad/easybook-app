import 'package:easybook_app/features/appointments/data/models/appointment_model.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/booking_fixtures.dart';

void main() {
  test('reads the API appointment, its status and service summary', () {
    final appointment = AppointmentModel.fromJson(tAppointmentJson).toEntity();
    expect(appointment, tAppointment);
    expect(appointment.startTime.isUtc, isTrue);
    expect(appointment.service.price, 500);
  });

  test('accepts null notes', () {
    final json = {...tAppointmentJson, 'notes': null};
    expect(AppointmentModel.fromJson(json).notes, isNull);
  });

  test('maps every API status', () {
    expect(parseAppointmentStatus('PENDING'), AppointmentStatus.pending);
    expect(parseAppointmentStatus('CONFIRMED'), AppointmentStatus.confirmed);
    expect(parseAppointmentStatus('CANCELLED'), AppointmentStatus.cancelled);
    expect(parseAppointmentStatus('COMPLETED'), AppointmentStatus.completed);
  });

  test('only pending bookings can be cancelled', () {
    expect(AppointmentStatus.pending.canCancel, isTrue);
    expect(AppointmentStatus.confirmed.canCancel, isFalse);
    expect(AppointmentStatus.cancelled.canCancel, isFalse);
    expect(AppointmentStatus.completed.canCancel, isFalse);
  });
}
