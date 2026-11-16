import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/auth/domain/entities/user.dart';
import 'package:fpdart/fpdart.dart';

/// What the app needs from authentication. Implemented in the data layer.
abstract interface class AuthRepository {
  /// Logs in and stores the token.
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Creates an account, logs in straight away and stores the token.
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  });

  /// Restores the session from a stored token.
  /// `Right(null)` means "no valid session": the user must log in.
  Future<Either<Failure, User?>> restoreSession();

  /// Deletes the stored token. There is no logout endpoint.
  Future<Either<Failure, Unit>> logout();

  /// Calls `GET /health` to wake the free-tier server.
  Future<Either<Failure, Unit>> wakeServer();

  /// Fires when a protected request returns 401.
  Stream<void> get sessionExpired;
}
