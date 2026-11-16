import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/auth/domain/entities/user.dart';
import 'package:easybook_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Used on the splash screen: is there still a valid session?
class RestoreSession {
  const new(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, User?>> call() => _repository.restoreSession();
}
