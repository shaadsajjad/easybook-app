import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

class ChangePasswordParams extends Equatable {
  const new({required this.currentPassword, required this.newPassword});

  final String currentPassword;
  final String newPassword;

  @override
  List<Object> get props => [currentPassword, newPassword];
}

class ChangePassword {
  const new(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, Unit>> call(ChangePasswordParams params) =>
      _repository.changePassword(
        currentPassword: params.currentPassword,
        newPassword: params.newPassword,
      );
}
