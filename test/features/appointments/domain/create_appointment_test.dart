import 'package:easybook_app/features/appointments/domain/repositories/appointments_repository.dart';
import 'package:easybook_app/features/appointments/domain/usecases/create_appointment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/booking_fixtures.dart';

class _MockRepository extends Mock implements AppointmentsRepository;

void main() {
  late _MockRepository repository;
  late CreateAppointment createAppointment;

  setUp(() {
    repository = _MockRepository();
    createAppointment = CreateAppointment(repository);
    when(
      () => repository.createAppointment(
        serviceId: any(named: 'serviceId'),
        startTime: any(named: 'startTime'),
        notes: any(named: 'notes'),
      ),
    ).thenAnswer((_) async => Right(tAppointment));
  });

  test('trims notes', () async {
    await createAppointment(
      const CreateAppointmentParams(
        serviceId: 's',
        startTime: 't',
        notes: ' Hi ',
      ),
    );
    verify(
      () => repository.createAppointment(
        serviceId: 's',
        startTime: 't',
        notes: 'Hi',
      ),
    ).called(1);
  });

  test('sends no notes when they are blank', () async {
    await createAppointment(
      const CreateAppointmentParams(
        serviceId: 's',
        startTime: 't',
        notes: '  ',
      ),
    );
    verify(() => repository.createAppointment(serviceId: 's', startTime: 't'))
        .called(1);
  });
}
