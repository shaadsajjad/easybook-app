import 'package:easybook_app/features/appointments/domain/entities/appointment.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment_status.dart';
import 'package:easybook_app/features/appointments/domain/entities/service_summary.dart';
import 'package:easybook_app/features/services/domain/entities/availability.dart';
import 'package:easybook_app/features/services/domain/entities/time_slot.dart';

/// `POST /appointments` response data, copied from docs/API.md.
const Map<String, dynamic> tAppointmentJson = {
  'id': '4a202958-e874-485d-8e12-411f46c71aae',
  'serviceId': '5e000000-0000-4000-8000-000000000001',
  'startTime': '2026-11-20T04:00:00.000Z',
  'endTime': '2026-11-20T04:30:00.000Z',
  'status': 'PENDING',
  'notes': 'Short on the sides, please.',
  'createdAt': '2026-11-16T15:41:53.197Z',
  'updatedAt': '2026-11-16T15:41:53.197Z',
  'service': {
    'id': '5e000000-0000-4000-8000-000000000001',
    'name': 'Classic Haircut',
    'price': '500.00',
    'durationMinutes': 30,
    'imageUrl': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1',
    'category': 'Hair & Beauty',
  },
};

final Appointment tAppointment = Appointment(
  id: '4a202958-e874-485d-8e12-411f46c71aae',
  startTime: DateTime.utc(2026, 11, 20, 4),
  endTime: DateTime.utc(2026, 11, 20, 4, 30),
  status: AppointmentStatus.pending,
  notes: 'Short on the sides, please.',
  createdAt: DateTime.utc(2026, 11, 16, 15, 41, 53, 197),
  service: const ServiceSummary(
    id: '5e000000-0000-4000-8000-000000000001',
    name: 'Classic Haircut',
    price: 500,
    durationMinutes: 30,
    imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1',
    category: 'Hair & Beauty',
  ),
);

TimeSlot tSlot(int hourUtc, {bool available = true}) {
  final value = '2026-11-20T${hourUtc.toString().padLeft(2, '0')}:00:00.000Z';
  final start = DateTime.parse(value);
  return TimeSlot(
    startTimeValue: value,
    start: start,
    end: start.add(const Duration(minutes: 30)),
    available: available,
  );
}

final Availability tAvailability = Availability(
  serviceId: '5e000000-0000-4000-8000-000000000001',
  date: '2026-11-20',
  slots: [tSlot(3), tSlot(4, available: false), tSlot(5)],
);
