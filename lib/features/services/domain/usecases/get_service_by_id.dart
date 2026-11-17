import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/domain/repositories/services_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetServiceById {
  const new(this._repository);

  final ServicesRepository _repository;

  /// [forceRefresh] skips the cache.
  Future<Either<Failure, Service>> call(
    String id, {
    bool forceRefresh = false,
  }) => _repository.getServiceById(id, forceRefresh: forceRefresh);
}
