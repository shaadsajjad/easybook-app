import 'package:dio/dio.dart';
import 'package:easybook_app/core/constants/api_endpoints.dart';
import 'package:easybook_app/features/appointments/data/datasources/appointments_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/booking_fixtures.dart';

class _MockDio extends Mock implements Dio;

void main() {
  late _MockDio dio;
  late AppointmentsRemoteDataSource dataSource;

  setUp(() {
    dio = _MockDio();
    dataSource = AppointmentsRemoteDataSource(dio);
    when(
      () => dio.post<Object?>(
        ApiEndpoints.appointments,
        data: any(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(),
        statusCode: 201,
        data: {'success': true, 'data': tAppointmentJson},
      ),
    );
  });

  test('posts the service, the exact start time and the notes', () async {
    final model = await dataSource.createAppointment(
      serviceId: 's1',
      startTime: '2026-11-20T04:00:00.000Z',
      notes: 'Hi',
    );

    expect(model.toEntity(), tAppointment);
    verify(
      () => dio.post<Object?>(
        ApiEndpoints.appointments,
        data: {
          'serviceId': 's1',
          'startTime': '2026-11-20T04:00:00.000Z',
          'notes': 'Hi',
        },
      ),
    ).called(1);
  });

  test('leaves notes out when there are none', () async {
    await dataSource.createAppointment(
      serviceId: 's1',
      startTime: '2026-11-20T04:00:00.000Z',
    );

    verify(
      () => dio.post<Object?>(
        ApiEndpoints.appointments,
        data: {'serviceId': 's1', 'startTime': '2026-11-20T04:00:00.000Z'},
      ),
    ).called(1);
  });
}
