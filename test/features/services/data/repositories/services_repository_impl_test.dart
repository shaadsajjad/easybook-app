import 'package:easybook_app/core/error/exceptions.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/services/data/datasources/services_remote_data_source.dart';
import 'package:easybook_app/features/services/data/models/pagination_meta_model.dart';
import 'package:easybook_app/features/services/data/models/service_model.dart';
import 'package:easybook_app/features/services/data/repositories/services_repository_impl.dart';
import 'package:easybook_app/features/services/domain/entities/service_filter.dart';
import 'package:easybook_app/features/services/domain/entities/services_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/service_fixtures.dart';

class _MockRemote extends Mock implements ServicesRemoteDataSource;

final _model = ServiceModel.fromJson(tServiceJson);
const _meta = PaginationMetaModel(page: 1, limit: 20, total: 21, totalPages: 2);

void main() {
  late _MockRemote remote;
  late ServicesRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(const ServiceFilter()));

  setUp(() {
    remote = _MockRemote();
    repository = ServicesRepositoryImpl(remote);
  });

  group('getServices', () {
    test('returns a page with pagination info', () async {
      when(() => remote.getServices(filter: const ServiceFilter(), page: 1))
          .thenAnswer((_) async => ([_model], _meta));

      final result = await repository.getServices(
        filter: const ServiceFilter(),
        page: 1,
      );

      expect(
        result,
        const Right<Failure, ServicesPage>(
          ServicesPage(services: [tService], page: 1, totalPages: 2, total: 21),
        ),
      );
      expect(result.getRight().toNullable()?.hasMore, isTrue);
    });

    test('maps a 422 to a ValidationFailure', () async {
      when(
        () => remote.getServices(
          filter: any(named: 'filter'),
          page: any(named: 'page'),
        ),
      ).thenThrow(
        const ApiException(statusCode: 422, message: 'Validation failed'),
      );

      final result = await repository.getServices(
        filter: const ServiceFilter(),
        page: 1,
      );

      expect(result.getLeft().toNullable(), isA<ValidationFailure>());
    });

    test('maps a lost connection to a NetworkFailure', () async {
      when(
        () => remote.getServices(
          filter: any(named: 'filter'),
          page: any(named: 'page'),
        ),
      ).thenThrow(const NetworkException());

      final result = await repository.getServices(
        filter: const ServiceFilter(),
        page: 1,
      );

      expect(result, const Left<Failure, ServicesPage>(NetworkFailure()));
    });
  });

  test('getFeaturedServices asks for featured services only', () async {
    when(
      () => remote.getServices(
        filter: const ServiceFilter(),
        page: 1,
        featuredOnly: true,
      ),
    ).thenAnswer((_) async => ([_model], _meta));

    final result = await repository.getFeaturedServices();

    expect(result.getRight().toNullable(), [tService]);
  });

  test('getCategories returns the names', () async {
    when(() => remote.getCategories()).thenAnswer((_) async => ['Health']);
    expect((await repository.getCategories()).getRight().toNullable(), [
      'Health',
    ]);
  });

  group('getServiceById', () {
    test('returns the service', () async {
      when(() => remote.getServiceById(tService.id))
          .thenAnswer((_) async => _model);
      expect(
        (await repository.getServiceById(tService.id)).getRight().toNullable(),
        tService,
      );
    });

    test('maps 404 to NotFoundFailure with the API message', () async {
      when(() => remote.getServiceById(any())).thenThrow(
        const ApiException(statusCode: 404, message: 'Service not found'),
      );
      expect(
        await repository.getServiceById('x'),
        const Left<Failure, dynamic>(NotFoundFailure('Service not found')),
      );
    });
  });
}
