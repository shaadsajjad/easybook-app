import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/network/request_guard.dart';
import 'package:easybook_app/features/auth/domain/entities/user.dart';
import 'package:easybook_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:easybook_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const new(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<Either<Failure, User>> updateProfile({
    required String name,
    String? phone,
  }) {
    return guardRequest(() async {
      final model = await _remote.updateProfile(name: name, phone: phone);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return guardRequest(() async {
      await _remote.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return unit;
    });
  }
}
