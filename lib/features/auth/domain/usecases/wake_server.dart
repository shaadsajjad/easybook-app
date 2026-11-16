import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Pings the server on app start, because the free host sleeps when idle.
class WakeServer {
  const new(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call() => _repository.wakeServer();
}
