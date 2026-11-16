import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/auth/domain/entities/user.dart';
import 'package:easybook_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

class RegisterParams extends Equatable {
  const new({required this.name, required this.email, required this.password});

  final String name;
  final String email;
  final String password;

  @override
  List<Object> get props => [name, email, password];
}

class Register {
  const new(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, User>> call(RegisterParams params) =>
      _repository.register(
        name: params.name.trim(),
        email: params.email.trim(),
        password: params.password,
      );
}
