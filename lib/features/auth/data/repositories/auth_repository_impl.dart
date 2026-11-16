import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/network/request_guard.dart';
import 'package:easybook_app/core/network/session_expiry_notifier.dart';
import 'package:easybook_app/core/storage/token_storage.dart';
import 'package:easybook_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:easybook_app/features/auth/data/models/auth_result_model.dart';
import 'package:easybook_app/features/auth/domain/entities/user.dart';
import 'package:easybook_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  const new({
    required this._remote,
    required this._tokenStorage,
    required this._sessionExpiry,
  });

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;
  final SessionExpiryNotifier _sessionExpiry;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) {
    return guardRequest(() async {
      final result = await _remote.login(email: email, password: password);
      return await _saveSession(result);
    });
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  }) {
    return guardRequest(() async {
      final result = await _remote.register(
        name: name,
        email: email,
        password: password,
      );
      return await _saveSession(result);
    });
  }

  @override
  Future<Either<Failure, User?>> restoreSession() async {
    final token = await _tokenStorage.read();
    if (token == null) return const Right(null);

    final result = await guardRequest(_remote.getCurrentUser);
    switch (result) {
      case Right(value: final user):
        return Right(user.toEntity());
      case Left(value: UnauthorizedFailure()):
        // An expired or invalid token is not an error: it just means
        // "no session", so the user goes to the login screen.
        await _tokenStorage.clear();
        return const Right(null);
      case Left(value: final failure):
        // Anything else (for example no internet) is reported, so the splash
        // screen can offer a retry without logging the user out.
        return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() {
    return guardRequest(() async {
      await _tokenStorage.clear();
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> wakeServer() {
    return guardRequest(() async {
      await _remote.checkHealth();
      return unit;
    });
  }

  @override
  Stream<void> get sessionExpired => _sessionExpiry.stream;

  Future<User> _saveSession(AuthResultModel result) async {
    await _tokenStorage.save(result.token);
    return result.user.toEntity();
  }
}
