import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/auth/domain/entities/user.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ProfileRepository {
  /// Updates the name and phone. A null [phone] removes it.
  /// The email can never be changed.
  Future<Either<Failure, User>> updateProfile({
    required String name,
    String? phone,
  });

  /// A wrong [currentPassword] is a ValidationFailure (422), not a 401,
  /// so it never logs the user out. The token stays valid afterwards.
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
