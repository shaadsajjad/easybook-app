import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/services/domain/entities/service_filter.dart';
import 'package:easybook_app/features/services/domain/entities/services_page.dart';
import 'package:easybook_app/features/services/domain/usecases/get_services.dart';
import 'package:easybook_app/features/services/presentation/bloc/services_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/service_fixtures.dart';

class _MockGetServices extends Mock implements GetServices;

const _debounce = Duration(milliseconds: 20);

void main() {
  late _MockGetServices getServices;

  setUpAll(
    () =>
        registerFallbackValue(const GetServicesParams(filter: ServiceFilter())),
  );

  setUp(() {
    getServices = _MockGetServices();
    when(() => getServices(any()))
        .thenAnswer((_) async => Right(tPage([tService])));
  });

  ServicesBloc buildBloc() =>
      ServicesBloc(getServices: getServices, searchDebounce: _debounce);

  const loaded = ServicesState(
    status: ServicesStatus.success,
    services: [tService],
    page: 1,
    totalPages: 2,
    total: 2,
  );

  group('ServicesStarted', () {
    blocTest<ServicesBloc, ServicesState>(
      'loads the first page',
      build: buildBloc,
      act: (bloc) => bloc.add(const ServicesStarted()),
      expect: () => [
        const ServicesState(status: ServicesStatus.loading),
        const ServicesState(
          status: ServicesStatus.success,
          services: [tService],
          page: 1,
          totalPages: 1,
          total: 1,
        ),
      ],
    );

    blocTest<ServicesBloc, ServicesState>(
      'shows a failure',
      setUp: () =>
          when(() => getServices(any()))
              .thenAnswer((_) async => const Left(NetworkFailure())),
      build: buildBloc,
      act: (bloc) => bloc.add(const ServicesStarted()),
      expect: () => [
        const ServicesState(status: ServicesStatus.loading),
        const ServicesState(
          status: ServicesStatus.failure,
          failure: NetworkFailure(),
        ),
      ],
    );

    blocTest<ServicesBloc, ServicesState>(
      'an empty result is a success with no services',
      setUp: () =>
          when(() => getServices(any()))
              .thenAnswer((_) async => Right(tPage(const [], totalPages: 0))),
      build: buildBloc,
      act: (bloc) => bloc.add(const ServicesStarted()),
      verify: (bloc) => expect(bloc.state.isEmpty, isTrue),
    );
  });

  blocTest<ServicesBloc, ServicesState>(
    'debounces typing so only the last search is sent',
    build: buildBloc,
    act: (bloc) async {
      bloc
        ..add(const ServicesSearchChanged('m'))
        ..add(const ServicesSearchChanged('ma'))
        ..add(const ServicesSearchChanged('mas'));
      await Future<void>.delayed(_debounce * 3);
    },
    verify: (bloc) {
      verify(
        () => getServices(
          const GetServicesParams(filter: ServiceFilter(search: 'mas')),
        ),
      ).called(1);
      verifyNoMoreInteractions(getServices);
      expect(bloc.state.filter.search, 'mas');
    },
  );

  blocTest<ServicesBloc, ServicesState>(
    'a category reloads page 1 and keeps the search',
    seed: () => loaded.copyWith(filter: const ServiceFilter(search: 'cut')),
    build: buildBloc,
    act: (bloc) => bloc.add(const ServicesCategorySelected('Hair & Beauty')),
    verify: (_) => verify(
      () => getServices(
        const GetServicesParams(
          filter: ServiceFilter(search: 'cut', category: 'Hair & Beauty'),
        ),
      ),
    ).called(1),
  );

  blocTest<ServicesBloc, ServicesState>(
    'a new category clears the old cards while loading (skeletons)',
    seed: () => loaded,
    build: buildBloc,
    act: (bloc) => bloc.add(const ServicesCategorySelected('Health')),
    expect: () => [
      const ServicesState(
        status: ServicesStatus.loading,
        filter: ServiceFilter(category: 'Health'),
      ),
      isA<ServicesState>().having(
        (s) => s.status,
        'status',
        ServicesStatus.success,
      ),
    ],
  );

  blocTest<ServicesBloc, ServicesState>(
    'pull to refresh keeps the cards while loading',
    seed: () => loaded,
    build: buildBloc,
    act: (bloc) => bloc.add(const ServicesRefreshed()),
    expect: () => [
      isA<ServicesState>()
          .having((s) => s.status, 'status', ServicesStatus.loading)
          .having((s) => s.services, 'services', [tService]),
      isA<ServicesState>().having(
        (s) => s.status,
        'status',
        ServicesStatus.success,
      ),
    ],
  );

  blocTest<ServicesBloc, ServicesState>(
    'a price range reloads with min and max',
    build: buildBloc,
    act: (bloc) => bloc.add(
      const ServicesPriceRangeChanged(minPrice: 1000, maxPrice: 3000),
    ),
    verify: (bloc) {
      expect(
        bloc.state.filter,
        const ServiceFilter(minPrice: 1000, maxPrice: 3000),
      );
    },
  );

  blocTest<ServicesBloc, ServicesState>(
    'clearing filters reloads without any filter',
    seed: () => loaded.copyWith(
      filter: const ServiceFilter(search: 'x', category: 'Health'),
    ),
    build: buildBloc,
    act: (bloc) => bloc.add(const ServicesFiltersCleared()),
    verify: (bloc) => expect(bloc.state.filter, const ServiceFilter()),
  );

  test('ignores an older result that arrives after a newer one', () async {
    final slow = Completer<Either<Failure, ServicesPage>>();
    when(
      () => getServices(
        const GetServicesParams(filter: ServiceFilter(category: 'Health')),
      ),
    ).thenAnswer((_) => slow.future);
    when(
      () => getServices(
        const GetServicesParams(filter: ServiceFilter(category: 'Wellness')),
      ),
    ).thenAnswer((_) async => Right(tPage([tMassage])));

    final bloc = buildBloc()
      ..add(const ServicesCategorySelected('Health'))
      ..add(const ServicesCategorySelected('Wellness'));
    await Future<void>.delayed(Duration.zero);
    slow.complete(Right(tPage([tService])));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.services, [tMassage]);
    expect(bloc.state.filter.category, 'Wellness');
    await bloc.close();
  });

  group('ServicesNextPageRequested', () {
    blocTest<ServicesBloc, ServicesState>(
      'appends the next page',
      setUp: () =>
          when(
            () => getServices(
              const GetServicesParams(filter: ServiceFilter(), page: 2),
            ),
          ).thenAnswer(
            (_) async => Right(tPage([tMassage], page: 2, totalPages: 2)),
          ),
      seed: () => loaded,
      build: buildBloc,
      act: (bloc) => bloc.add(const ServicesNextPageRequested()),
      expect: () => [
        loaded.copyWith(isLoadingMore: true),
        loaded.copyWith(
          services: [tService, tMassage],
          page: 2,
          totalPages: 2,
          total: 2,
        ),
      ],
    );

    blocTest<ServicesBloc, ServicesState>(
      'does nothing on the last page',
      seed: () => loaded.copyWith(totalPages: 1),
      build: buildBloc,
      act: (bloc) => bloc.add(const ServicesNextPageRequested()),
      expect: () => <ServicesState>[],
    );

    blocTest<ServicesBloc, ServicesState>(
      'does nothing while a page is already loading',
      seed: () => loaded.copyWith(isLoadingMore: true),
      build: buildBloc,
      act: (bloc) => bloc.add(const ServicesNextPageRequested()),
      expect: () => <ServicesState>[],
    );

    blocTest<ServicesBloc, ServicesState>(
      'keeps the list and reports a load-more failure',
      setUp: () =>
          when(() => getServices(any()))
              .thenAnswer((_) async => const Left(NetworkFailure())),
      seed: () => loaded,
      build: buildBloc,
      act: (bloc) => bloc.add(const ServicesNextPageRequested()),
      expect: () => [
        loaded.copyWith(isLoadingMore: true),
        loaded.copyWith(loadMoreFailure: () => const NetworkFailure()),
      ],
    );
  });

  blocTest<ServicesBloc, ServicesState>(
    'refresh reloads page 1 with the current filter, skipping the cache',
    seed: () => loaded.copyWith(filter: const ServiceFilter(search: 'spa')),
    build: buildBloc,
    act: (bloc) => bloc.add(const ServicesRefreshed()),
    verify: (_) => verify(
      () => getServices(
        const GetServicesParams(
          filter: ServiceFilter(search: 'spa'),
          forceRefresh: true,
        ),
      ),
    ).called(1),
  );
}
