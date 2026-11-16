import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/network/request_guard.dart';
import 'package:easybook_app/features/services/data/datasources/services_remote_data_source.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/domain/entities/service_filter.dart';
import 'package:easybook_app/features/services/domain/entities/services_page.dart';
import 'package:easybook_app/features/services/domain/repositories/services_repository.dart';
import 'package:fpdart/fpdart.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  const new(this._remote);

  final ServicesRemoteDataSource _remote;

  @override
  Future<Either<Failure, ServicesPage>> getServices({
    required ServiceFilter filter,
    required int page,
  }) {
    return guardRequest(() async {
      final (services, meta) = await _remote.getServices(
        filter: filter,
        page: page,
      );
      return ServicesPage(
        services: services.map((model) => model.toEntity()).toList(),
        page: meta.page,
        totalPages: meta.totalPages,
        total: meta.total,
      );
    });
  }

  @override
  Future<Either<Failure, List<Service>>> getFeaturedServices() {
    return guardRequest(() async {
      final (services, _) = await _remote.getServices(
        filter: const ServiceFilter(),
        page: 1,
        featuredOnly: true,
      );
      return services.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() =>
      guardRequest(_remote.getCategories);

  @override
  Future<Either<Failure, Service>> getServiceById(String id) {
    return guardRequest(() async {
      final model = await _remote.getServiceById(id);
      return model.toEntity();
    });
  }
}
