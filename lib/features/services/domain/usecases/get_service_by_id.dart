import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/domain/repositories/services_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetServiceById {
  const new(this._repository);

  final ServicesRepository _repository;

  Future<Either<Failure, Service>> call(String id) =>
      _repository.getServiceById(id);
}
