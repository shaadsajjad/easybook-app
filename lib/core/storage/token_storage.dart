import 'package:easybook_app/core/constants/storage_keys.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps the JWT in the platform's secure storage (Keychain / Keystore).
/// Nothing else is stored here.
class TokenStorage {
  const new(this._storage);

  final FlutterSecureStorage _storage;

  Future<String?> read() => _storage.read(key: StorageKeys.authToken);

  Future<void> save(String token) =>
      _storage.write(key: StorageKeys.authToken, value: token);

  Future<void> clear() => _storage.delete(key: StorageKeys.authToken);
}
