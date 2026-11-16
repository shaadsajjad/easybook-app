import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/auth/domain/entities/user.dart';
import 'package:easybook_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

class LoginParams extends Equatable {
  const new({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}

class Login {
  const new(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, User>> call(LoginParams params) =>
      _repository.login(email: params.email.trim(), password: params.password);
}
