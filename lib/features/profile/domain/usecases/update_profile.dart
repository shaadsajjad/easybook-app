import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/auth/domain/entities/user.dart';
import 'package:easybook_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

class UpdateProfileParams extends Equatable {
  const new({required this.name, this.phone});

  final String name;
  final String? phone;

  @override
  List<Object?> get props => [name, phone];
}

class UpdateProfile {
  const new(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, User>> call(UpdateProfileParams params) {
    // An empty phone field means "remove my phone number".
    final phone = params.phone?.trim();
    return _repository.updateProfile(
      name: params.name.trim(),
      phone: phone == null || phone.isEmpty ? null : phone,
    );
  }
}
