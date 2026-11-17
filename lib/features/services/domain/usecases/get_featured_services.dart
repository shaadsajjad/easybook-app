import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/domain/repositories/services_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetFeaturedServices {
  const new(this._repository);

  final ServicesRepository _repository;

  /// [forceRefresh] skips the cache (pull to refresh).
  Future<Either<Failure, List<Service>>> call({bool forceRefresh = false}) =>
      _repository.getFeaturedServices(forceRefresh: forceRefresh);
}
