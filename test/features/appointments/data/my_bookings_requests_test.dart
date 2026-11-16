import 'package:dio/dio.dart';
import 'package:easybook_app/core/constants/api_endpoints.dart';
import 'package:easybook_app/core/error/exceptions.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/appointments/data/datasources/appointments_remote_data_source.dart';
import 'package:easybook_app/features/appointments/data/repositories/appointments_repository_impl.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment_status.dart';
import 'package:easybook_app/features/appointments/domain/entities/bookings_tab.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/booking_fixtures.dart';

class _MockDio extends Mock implements Dio;

Response<Object?> _ok(Object? data) => Response(
  requestOptions: RequestOptions(),
  statusCode: 200,
  data: {'success': true, 'data': data},
);

void main() {
  late _MockDio dio;
  late AppointmentsRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = AppointmentsRepositoryImpl(AppointmentsRemoteDataSource(dio));
  });

  group('getAppointments', () {
    test('asks for the tab as ?type= and returns the list', () async {
      when(
        () => dio.get<Object?>(
          ApiEndpoints.appointments,
          queryParameters: {'type': 'upcoming'},
        ),
      ).thenAnswer((_) async => _ok([tAppointmentJson]));

      final result = await repository.getAppointments(BookingsTab.upcoming);

      expect(result.getRight().toNullable(), [tAppointment]);
    });

    test('uses type=past for the Past tab', () async {
      when(
        () => dio.get<Object?>(
          ApiEndpoints.appointments,
          queryParameters: {'type': 'past'},
        ),
      ).thenAnswer((_) async => _ok(<Object>[]));

      final result = await repository.getAppointments(BookingsTab.past);

      expect(result.getRight().toNullable(), isEmpty);
    });
  });

  group('getAppointmentById', () {
    test('returns the booking', () async {
      when(
        () => dio.get<Object?>(ApiEndpoints.appointmentById(tAppointment.id)),
      ).thenAnswer((_) async => _ok(tAppointmentJson));

      final result = await repository.getAppointmentById(tAppointment.id);

      expect(result.getRight().toNullable(), tAppointment);
    });

    test("someone else's booking is a NotFoundFailure", () async {
      when(() => dio.get<Object?>(any())).thenThrow(
        const ApiException(statusCode: 404, message: 'Appointment not found'),
      );

      final result = await repository.getAppointmentById('x');

      expect(
        result.getLeft().toNullable(),
        const NotFoundFailure('Appointment not found'),
      );
    });
  });

  group('cancelAppointment', () {
    test('returns the cancelled booking and announces the change', () async {
      when(
        () =>
            dio.patch<Object?>(ApiEndpoints.cancelAppointment(tAppointment.id)),
      ).thenAnswer(
        (_) async => _ok({...tAppointmentJson, 'status': 'CANCELLED'}),
      );
      final changed = expectLater(repository.changes, emits(null));

      final result = await repository.cancelAppointment(tAppointment.id);

      expect(
        result.getRight().toNullable()?.status,
        AppointmentStatus.cancelled,
      );
      await changed;
    });

    test('a non-pending booking gives a ConflictFailure', () async {
      when(() => dio.patch<Object?>(any())).thenThrow(
        const ApiException(
          statusCode: 409,
          message:
              'Only pending appointments can be cancelled. '
              'This appointment is confirmed.',
        ),
      );

      final result = await repository.cancelAppointment('x');

      expect(result.getLeft().toNullable(), isA<ConflictFailure>());
    });
  });

  test('creating a booking announces the change too', () async {
    when(
      () => dio.post<Object?>(
        ApiEndpoints.appointments,
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => _ok(tAppointmentJson));
    final changed = expectLater(repository.changes, emits(null));

    await repository.createAppointment(serviceId: 's', startTime: 't');

    await changed;
  });
}
