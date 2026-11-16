import 'package:easybook_app/features/auth/domain/repositories/auth_repository.dart';

/// Emits whenever the server rejects the stored token (401).
class WatchSessionExpired {
  const new(this._repository);

  final AuthRepository _repository;

  Stream<void> call() => _repository.sessionExpired;
}
