import 'package:dio/dio.dart';
import 'package:easybook_app/core/constants/api_endpoints.dart';
import 'package:easybook_app/core/network/auth_interceptor.dart';
import 'package:easybook_app/core/network/session_expiry_notifier.dart';
import 'package:easybook_app/core/storage/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockTokenStorage extends Mock implements TokenStorage;

class _MockRequestHandler extends Mock implements RequestInterceptorHandler;

class _MockErrorHandler extends Mock implements ErrorInterceptorHandler;

DioException _error(String path, int status) {
  final options = RequestOptions(path: path);
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<Object?>(requestOptions: options, statusCode: status),
  );
}

void main() {
  late _MockTokenStorage tokenStorage;
  late SessionExpiryNotifier sessionExpiry;
  late AuthInterceptor interceptor;

  setUpAll(() {
    registerFallbackValue(RequestOptions());
    registerFallbackValue(DioException(requestOptions: RequestOptions()));
  });

  setUp(() {
    tokenStorage = _MockTokenStorage();
    sessionExpiry = SessionExpiryNotifier();
    interceptor = AuthInterceptor(
      tokenStorage: tokenStorage,
      sessionExpiry: sessionExpiry,
    );
    when(() => tokenStorage.clear()).thenAnswer((_) async {});
  });

  tearDown(() => sessionExpiry.dispose());

  group('onRequest', () {
    test('adds the Bearer token when one is stored', () async {
      when(() => tokenStorage.read()).thenAnswer((_) async => 'abc');
      final handler = _MockRequestHandler();
      final options = RequestOptions(path: ApiEndpoints.me);

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer abc');
      verify(() => handler.next(options)).called(1);
    });

    test('sends no header when no token is stored', () async {
      when(() => tokenStorage.read()).thenAnswer((_) async => null);
      final handler = _MockRequestHandler();
      final options = RequestOptions(path: ApiEndpoints.services);

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      verify(() => handler.next(options)).called(1);
    });

    test('never sends a token to login or register', () async {
      when(() => tokenStorage.read()).thenAnswer((_) async => 'abc');
      final handler = _MockRequestHandler();
      final options = RequestOptions(path: ApiEndpoints.login);

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      verifyNever(() => tokenStorage.read());
    });
  });

  group('onError', () {
    test('a 401 on a protected route clears the token and expires the '
        'session', () async {
      final handler = _MockErrorHandler();
      final error = _error(ApiEndpoints.me, 401);
      final expired = expectLater(sessionExpiry.stream, emits(null));

      await interceptor.onError(error, handler);

      verify(() => tokenStorage.clear()).called(1);
      await expired;
      verify(() => handler.next(error)).called(1);
    });

    test('a 401 from login is a normal error and logs nobody out', () async {
      final handler = _MockErrorHandler();
      final error = _error(ApiEndpoints.login, 401);
      var notified = false;
      sessionExpiry.stream.listen((_) => notified = true);

      await interceptor.onError(error, handler);
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => tokenStorage.clear());
      expect(notified, isFalse);
      verify(() => handler.next(error)).called(1);
    });

    test('other errors pass through untouched', () async {
      final handler = _MockErrorHandler();
      final error = _error(ApiEndpoints.appointments, 409);

      await interceptor.onError(error, handler);

      verifyNever(() => tokenStorage.clear());
      verify(() => handler.next(error)).called(1);
    });
  });
}
