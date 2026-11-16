import 'package:easybook_app/core/constants/storage_keys.dart';
import 'package:easybook_app/core/storage/token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage;

void main() {
  late _MockSecureStorage storage;
  late TokenStorage tokenStorage;

  setUp(() {
    storage = _MockSecureStorage();
    tokenStorage = TokenStorage(storage);
  });

  test('read returns the stored token', () async {
    when(() => storage.read(key: StorageKeys.authToken))
        .thenAnswer((_) async => 'abc');
    expect(await tokenStorage.read(), 'abc');
  });

  test('save writes the token under the auth key', () async {
    when(() => storage.write(key: StorageKeys.authToken, value: 'abc'))
        .thenAnswer((_) async {});
    await tokenStorage.save('abc');
    verify(() => storage.write(key: StorageKeys.authToken, value: 'abc'))
        .called(1);
  });

  test('clear deletes the token', () async {
    when(() => storage.delete(key: StorageKeys.authToken))
        .thenAnswer((_) async {});
    await tokenStorage.clear();
    verify(() => storage.delete(key: StorageKeys.authToken)).called(1);
  });
}
