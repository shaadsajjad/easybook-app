import 'package:dio/dio.dart';
import 'package:easybook_app/core/constants/api_endpoints.dart';
import 'package:easybook_app/core/error/exceptions.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/services/data/datasources/services_remote_data_source.dart';
import 'package:easybook_app/features/services/data/repositories/services_repository_impl.dart';
import 'package:easybook_app/features/services/domain/usecases/get_availability.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio;

void main() {
  late _MockDio dio;
  late GetAvailability getAvailability;

  setUp(() {
    dio = _MockDio();
    getAvailability = GetAvailability(
      ServicesRepositoryImpl(ServicesRemoteDataSource(dio)),
    );
  });

  test('asks for the picked calendar day as yyyy-MM-dd', () async {
    when(
      () => dio.get<Object?>(
        ApiEndpoints.availability('s1'),
        queryParameters: {'date': '2026-11-05'},
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(),
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'serviceId': 's1',
            'date': '2026-11-05',
            'slots': <Object>[],
          },
        },
      ),
    );

    final result = await getAvailability(
      // Late evening: still Nov 5 on the calendar, whatever UTC says.
      GetAvailabilityParams(serviceId: 's1', day: DateTime(2026, 11, 5, 23)),
    );

    expect(result.getRight().toNullable()?.date, '2026-11-05');
  });

  test('maps a 404 to NotFoundFailure', () async {
    when(
      () => dio.get<Object?>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenThrow(
      const ApiException(statusCode: 404, message: 'Service not found'),
    );

    final result = await getAvailability(
      GetAvailabilityParams(serviceId: 'x', day: DateTime(2026, 11, 5)),
    );

    expect(
      result.getLeft().toNullable(),
      const NotFoundFailure('Service not found'),
    );
  });
}
