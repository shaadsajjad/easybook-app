import 'package:dio/dio.dart';
import 'package:easybook_app/core/error/exceptions.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/network/session_expiry_notifier.dart';
import 'package:easybook_app/core/storage/token_storage.dart';
import 'package:easybook_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:easybook_app/features/auth/data/models/auth_result_model.dart';
import 'package:easybook_app/features/auth/data/models/user_model.dart';
import 'package:easybook_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/auth_fixtures.dart';

class _MockRemote extends Mock implements AuthRemoteDataSource;

class _MockTokenStorage extends Mock implements TokenStorage;

final _authResult = AuthResultModel(
  user: UserModel.fromJson(tUserJson),
  token: tToken,
);

void main() {
  late _MockRemote remote;
  late _MockTokenStorage tokenStorage;
  late SessionExpiryNotifier sessionExpiry;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    tokenStorage = _MockTokenStorage();
    sessionExpiry = SessionExpiryNotifier();
    repository = AuthRepositoryImpl(
      remote: remote,
      tokenStorage: tokenStorage,
      sessionExpiry: sessionExpiry,
    );
    when(() => tokenStorage.save(any())).thenAnswer((_) async {});
    when(() => tokenStorage.clear()).thenAnswer((_) async {});
  });

  tearDown(() => sessionExpiry.dispose());

  group('login', () {
    test('saves the token and returns the user', () async {
      when(() => remote.login(email: 'demo@example.com', password: 'Demo1234'))
          .thenAnswer((_) async => _authResult);

      final result = await repository.login(
        email: 'demo@example.com',
        password: 'Demo1234',
      );

      expect(result, Right<Failure, dynamic>(tUser));
      verify(() => tokenStorage.save(tToken)).called(1);
    });

    test('returns UnauthorizedFailure with the API message on 401 and '
        'saves nothing', () async {
      when(
        () => remote.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        const ApiException(
          statusCode: 401,
          message: 'Invalid email or password',
        ),
      );

      final result = await repository.login(email: 'a@b.co', password: 'x');

      expect(
        result,
        const Left<Failure, dynamic>(
          UnauthorizedFailure('Invalid email or password'),
        ),
      );
      verifyNever(() => tokenStorage.save(any()));
    });

    test('returns NetworkFailure when the server is unreachable', () async {
      when(
        () => remote.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await repository.login(email: 'a@b.co', password: 'x');

      expect(result, const Left<Failure, dynamic>(NetworkFailure()));
    });
  });

  group('register', () {
    test('saves the token and returns the user', () async {
      when(
        () => remote.register(
          name: 'Demo User',
          email: 'demo@example.com',
          password: 'Demo1234',
        ),
      ).thenAnswer((_) async => _authResult);

      final result = await repository.register(
        name: 'Demo User',
        email: 'demo@example.com',
        password: 'Demo1234',
      );

      expect(result, Right<Failure, dynamic>(tUser));
      verify(() => tokenStorage.save(tToken)).called(1);
    });

    test('returns ConflictFailure when the email is taken', () async {
      when(
        () => remote.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        const ApiException(
          statusCode: 409,
          message: 'An account with this email already exists',
        ),
      );

      final result = await repository.register(
        name: 'A B',
        email: 'a@b.co',
        password: 'Secret123',
      );

      expect(
        result,
        const Left<Failure, dynamic>(
          ConflictFailure('An account with this email already exists'),
        ),
      );
    });

    test('returns ValidationFailure with field errors on 422', () async {
      when(
        () => remote.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        const ApiException(
          statusCode: 422,
          message: 'Validation failed',
          fieldErrors: {
            'email': ['Enter a valid email address'],
          },
        ),
      );

      final result = await repository.register(
        name: 'A B',
        email: 'bad',
        password: 'Secret123',
      );

      final failure = result.getLeft().toNullable();
      expect(failure, isA<ValidationFailure>());
      expect(
        (failure! as ValidationFailure).errorFor('email'),
        'Enter a valid email address',
      );
    });
  });

  group('restoreSession', () {
    test(
      'returns null without calling the API when no token is stored',
      () async {
        when(() => tokenStorage.read()).thenAnswer((_) async => null);

        final result = await repository.restoreSession();

        expect(result, const Right<Failure, dynamic>(null));
        verifyNever(() => remote.getCurrentUser());
      },
    );

    test('returns the user when the stored token is valid', () async {
      when(() => tokenStorage.read()).thenAnswer((_) async => tToken);
      when(() => remote.getCurrentUser())
          .thenAnswer((_) async => UserModel.fromJson(tUserJson));

      final result = await repository.restoreSession();

      expect(result, Right<Failure, dynamic>(tUser));
    });

    test('clears the token and returns null on 401', () async {
      when(() => tokenStorage.read()).thenAnswer((_) async => tToken);
      when(() => remote.getCurrentUser()).thenThrow(
        const ApiException(statusCode: 401, message: 'Session expired'),
      );

      final result = await repository.restoreSession();

      expect(result, const Right<Failure, dynamic>(null));
      verify(() => tokenStorage.clear()).called(1);
    });

    test('keeps the token and reports other failures', () async {
      when(() => tokenStorage.read()).thenAnswer((_) async => tToken);
      when(() => remote.getCurrentUser()).thenThrow(const NetworkException());

      final result = await repository.restoreSession();

      expect(result, const Left<Failure, dynamic>(NetworkFailure()));
      verifyNever(() => tokenStorage.clear());
    });
  });

  test('logout clears the token', () async {
    final result = await repository.logout();
    expect(result, const Right<Failure, Unit>(unit));
    verify(() => tokenStorage.clear()).called(1);
  });

  group('wakeServer', () {
    test('succeeds when the health check answers', () async {
      when(() => remote.checkHealth()).thenAnswer((_) async {});
      expect(await repository.wakeServer(), const Right<Failure, Unit>(unit));
    });

    test('returns a failure when it does not', () async {
      when(() => remote.checkHealth()).thenThrow(const NetworkException());
      expect(
        await repository.wakeServer(),
        const Left<Failure, Unit>(NetworkFailure()),
      );
    });
  });

  test('sessionExpired forwards the notifier', () async {
    final expectation = expectLater(repository.sessionExpired, emits(null));
    sessionExpiry.notify();
    await expectation;
  });
}
