import 'package:dio/dio.dart';
import 'package:easybook_app/core/constants/api_endpoints.dart';
import 'package:easybook_app/core/constants/app_constants.dart';
import 'package:easybook_app/features/services/data/datasources/services_remote_data_source.dart';
import 'package:easybook_app/features/services/domain/entities/service_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/service_fixtures.dart';

class _MockDio extends Mock implements Dio;

Response<Object?> _ok(Object? body) =>
    Response(requestOptions: RequestOptions(), statusCode: 200, data: body);

const _meta = {'page': 1, 'limit': 20, 'total': 1, 'totalPages': 1};

void main() {
  late _MockDio dio;
  late ServicesRemoteDataSource dataSource;

  setUp(() {
    dio = _MockDio();
    dataSource = ServicesRemoteDataSource(dio);
    when(
      () => dio.get<Object?>(
        ApiEndpoints.services,
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => _ok({
        'success': true,
        'data': [tServiceJson],
        'meta': _meta,
      }),
    );
  });

  Map<String, dynamic> sentQuery() =>
      verify(
            () => dio.get<Object?>(
              ApiEndpoints.services,
              queryParameters: captureAny(named: 'queryParameters'),
            ),
          ).captured.single
          as Map<String, dynamic>;

  test('sends only page and limit when nothing is filtered', () async {
    final (services, meta) = await dataSource.getServices(
      filter: const ServiceFilter(),
      page: 1,
    );

    expect(services.single.toEntity(), tService);
    expect(meta.totalPages, 1);
    expect(sentQuery(), {'page': 1, 'limit': AppConstants.servicesPageSize});
  });

  test('sends every active filter, with the search trimmed', () async {
    await dataSource.getServices(
      filter: const ServiceFilter(
        search: '  massage ',
        category: 'Wellness',
        minPrice: 500,
        maxPrice: 2000,
      ),
      page: 3,
      featuredOnly: true,
    );

    expect(sentQuery(), {
      'page': 3,
      'limit': AppConstants.servicesPageSize,
      'search': 'massage',
      'category': 'Wellness',
      'minPrice': 500.0,
      'maxPrice': 2000.0,
      'featured': 'true',
    });
  });

  test('reads the categories list', () async {
    when(() => dio.get<Object?>(ApiEndpoints.categories)).thenAnswer(
      (_) async => _ok({
        'success': true,
        'data': ['Health', 'Wellness'],
      }),
    );
    expect(await dataSource.getCategories(), ['Health', 'Wellness']);
  });

  test('reads one service by id', () async {
    when(() => dio.get<Object?>(ApiEndpoints.serviceById(tService.id)))
        .thenAnswer((_) async => _ok({'success': true, 'data': tServiceJson}));
    final model = await dataSource.getServiceById(tService.id);
    expect(model.toEntity(), tService);
  });
}
