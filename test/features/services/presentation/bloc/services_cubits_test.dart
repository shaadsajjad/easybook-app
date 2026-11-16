import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/services/domain/usecases/get_categories.dart';
import 'package:easybook_app/features/services/domain/usecases/get_featured_services.dart';
import 'package:easybook_app/features/services/domain/usecases/get_service_by_id.dart';
import 'package:easybook_app/features/services/presentation/bloc/categories_cubit.dart';
import 'package:easybook_app/features/services/presentation/bloc/featured_services_cubit.dart';
import 'package:easybook_app/features/services/presentation/bloc/service_detail_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/service_fixtures.dart';

class _MockGetFeatured extends Mock implements GetFeaturedServices;

class _MockGetCategories extends Mock implements GetCategories;

class _MockGetServiceById extends Mock implements GetServiceById;

void main() {
  group('FeaturedServicesCubit', () {
    late _MockGetFeatured getFeatured;
    setUp(() => getFeatured = _MockGetFeatured());

    blocTest<FeaturedServicesCubit, FeaturedServicesState>(
      'loads the featured services',
      setUp: () =>
          when(() => getFeatured())
              .thenAnswer((_) async => const Right([tService])),
      build: () => FeaturedServicesCubit(getFeaturedServices: getFeatured),
      act: (cubit) => cubit.load(),
      expect: () => [
        const FeaturedServicesState(status: FeaturedStatus.loading),
        const FeaturedServicesState(
          status: FeaturedStatus.success,
          services: [tService],
        ),
      ],
    );

    blocTest<FeaturedServicesCubit, FeaturedServicesState>(
      'reports a failure',
      setUp: () =>
          when(() => getFeatured())
              .thenAnswer((_) async => const Left(NetworkFailure())),
      build: () => FeaturedServicesCubit(getFeaturedServices: getFeatured),
      act: (cubit) => cubit.load(),
      expect: () => [
        const FeaturedServicesState(status: FeaturedStatus.loading),
        const FeaturedServicesState(
          status: FeaturedStatus.failure,
          failure: NetworkFailure(),
        ),
      ],
    );
  });

  group('CategoriesCubit', () {
    late _MockGetCategories getCategories;
    setUp(() => getCategories = _MockGetCategories());

    blocTest<CategoriesCubit, CategoriesState>(
      'loads the categories',
      setUp: () =>
          when(() => getCategories())
              .thenAnswer((_) async => const Right(['Health', 'Wellness'])),
      build: () => CategoriesCubit(getCategories: getCategories),
      act: (cubit) => cubit.load(),
      expect: () => [
        const CategoriesState(status: CategoriesStatus.loading),
        const CategoriesState(
          status: CategoriesStatus.success,
          categories: ['Health', 'Wellness'],
        ),
      ],
    );

    blocTest<CategoriesCubit, CategoriesState>(
      'reports a failure',
      setUp: () =>
          when(() => getCategories())
              .thenAnswer((_) async => const Left(ServerFailure())),
      build: () => CategoriesCubit(getCategories: getCategories),
      act: (cubit) => cubit.load(),
      expect: () => [
        const CategoriesState(status: CategoriesStatus.loading),
        const CategoriesState(
          status: CategoriesStatus.failure,
          failure: ServerFailure(),
        ),
      ],
    );
  });

  group('ServiceDetailCubit', () {
    late _MockGetServiceById getById;
    setUp(() => getById = _MockGetServiceById());

    ServiceDetailCubit build() => ServiceDetailCubit(getServiceById: getById);

    blocTest<ServiceDetailCubit, ServiceDetailState>(
      'loads the service by id',
      setUp: () =>
          when(() => getById(tService.id))
              .thenAnswer((_) async => const Right(tService)),
      build: build,
      act: (cubit) => cubit.load(tService.id),
      expect: () => [
        const ServiceDetailState(status: ServiceDetailStatus.loading),
        const ServiceDetailState(
          status: ServiceDetailStatus.success,
          service: tService,
        ),
      ],
    );

    blocTest<ServiceDetailCubit, ServiceDetailState>(
      'shows the tapped service at once, then the fresh copy',
      setUp: () =>
          when(() => getById(tService.id))
              .thenAnswer((_) async => const Right(tService)),
      build: build,
      act: (cubit) => cubit.load(tService.id, initial: tService),
      expect: () => [
        const ServiceDetailState(
          status: ServiceDetailStatus.success,
          service: tService,
        ),
      ],
    );

    blocTest<ServiceDetailCubit, ServiceDetailState>(
      'keeps the tapped service when the refresh fails offline',
      setUp: () =>
          when(() => getById(tService.id))
              .thenAnswer((_) async => const Left(NetworkFailure())),
      build: build,
      act: (cubit) => cubit.load(tService.id, initial: tService),
      expect: () => [
        const ServiceDetailState(
          status: ServiceDetailStatus.success,
          service: tService,
        ),
      ],
    );

    blocTest<ServiceDetailCubit, ServiceDetailState>(
      'shows not found when the service is gone',
      setUp: () => when(() => getById(tService.id)).thenAnswer(
        (_) async => const Left(NotFoundFailure('Service not found')),
      ),
      build: build,
      act: (cubit) => cubit.load(tService.id, initial: tService),
      expect: () => [
        const ServiceDetailState(
          status: ServiceDetailStatus.success,
          service: tService,
        ),
        const ServiceDetailState(
          status: ServiceDetailStatus.failure,
          failure: NotFoundFailure('Service not found'),
        ),
      ],
    );
  });
}
