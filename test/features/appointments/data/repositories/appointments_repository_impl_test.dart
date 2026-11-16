import 'package:easybook_app/core/error/exceptions.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/appointments/data/datasources/appointments_remote_data_source.dart';
import 'package:easybook_app/features/appointments/data/models/appointment_model.dart';
import 'package:easybook_app/features/appointments/data/repositories/appointments_repository_impl.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/booking_fixtures.dart';

class _MockRemote extends Mock implements AppointmentsRemoteDataSource;

void main() {
  late _MockRemote remote;
  late AppointmentsRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = AppointmentsRepositoryImpl(remote);
  });

  Future<Either<Failure, Appointment>> create() =>
      repository.createAppointment(serviceId: 's1', startTime: 't');

  void stubThrow(Object error) {
    when(
      () => remote.createAppointment(
        serviceId: any(named: 'serviceId'),
        startTime: any(named: 'startTime'),
        notes: any(named: 'notes'),
      ),
    ).thenThrow(error);
  }

  test('returns the created appointment', () async {
    when(() => remote.createAppointment(serviceId: 's1', startTime: 't'))
        .thenAnswer((_) async => AppointmentModel.fromJson(tAppointmentJson));

    expect(await create(), Right<Failure, Appointment>(tAppointment));
  });

  test(
    'maps a taken slot (409) to ConflictFailure with the API message',
    () async {
      stubThrow(
        const ApiException(
          statusCode: 409,
          message:
              'This time slot is already booked. Please choose another time.',
        ),
      );

      expect(
        await create(),
        const Left<Failure, Appointment>(
          ConflictFailure(
            'This time slot is already booked. Please choose another time.',
          ),
        ),
      );
    },
  );

  test('maps a booking rule error (422) with the startTime reason', () async {
    stubThrow(
      const ApiException(
        statusCode: 422,
        message: 'This time cannot be booked',
        fieldErrors: {
          'startTime': [
            'This time is in the past. Please choose a future slot.',
          ],
        },
      ),
    );

    final failure = (await create()).getLeft().toNullable();
    expect(
      (failure! as ValidationFailure).errorFor('startTime'),
      'This time is in the past. Please choose a future slot.',
    );
  });

  test('maps a lost connection to NetworkFailure', () async {
    stubThrow(const NetworkException());
    expect(await create(), const Left<Failure, Appointment>(NetworkFailure()));
  });
}
