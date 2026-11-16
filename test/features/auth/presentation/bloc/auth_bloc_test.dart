import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/auth/domain/usecases/logout.dart';
import 'package:easybook_app/features/auth/domain/usecases/restore_session.dart';
import 'package:easybook_app/features/auth/domain/usecases/watch_session_expired.dart';
import 'package:easybook_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/auth_fixtures.dart';

class _MockRestoreSession extends Mock implements RestoreSession;

class _MockLogout extends Mock implements Logout;

class _MockWatchSessionExpired extends Mock implements WatchSessionExpired;

void main() {
  late _MockRestoreSession restoreSession;
  late _MockLogout logout;
  late _MockWatchSessionExpired watchSessionExpired;
  late StreamController<void> expiry;

  setUp(() {
    restoreSession = _MockRestoreSession();
    logout = _MockLogout();
    watchSessionExpired = _MockWatchSessionExpired();
    expiry = StreamController<void>.broadcast();
    when(() => watchSessionExpired()).thenAnswer((_) => expiry.stream);
    when(() => logout()).thenAnswer((_) async => const Right(unit));
  });

  tearDown(() => expiry.close());

  AuthBloc buildBloc() => AuthBloc(
    restoreSession: restoreSession,
    logout: logout,
    watchSessionExpired: watchSessionExpired,
  );

  test('starts unknown, while the session is checked', () {
    expect(buildBloc().state, const AuthState.unknown());
  });

  group('AuthSessionRequested', () {
    blocTest<AuthBloc, AuthState>(
      'is authenticated when a valid token is stored',
      setUp: () =>
          when(() => restoreSession()).thenAnswer((_) async => Right(tUser)),
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthSessionRequested()),
      expect: () => [AuthState.authenticated(tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'is unauthenticated when there is no valid session',
      setUp: () =>
          when(() => restoreSession())
              .thenAnswer((_) async => const Right(null)),
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthSessionRequested()),
      expect: () => [const AuthState.unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'stays unknown with the failure when the check fails, then retries',
      setUp: () =>
          when(() => restoreSession())
              .thenAnswer((_) async => const Left(NetworkFailure())),
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const AuthSessionRequested());
        await Future<void>.delayed(Duration.zero);
        when(() => restoreSession()).thenAnswer((_) async => Right(tUser));
        bloc.add(const AuthSessionRequested());
      },
      expect: () => [
        const AuthState.unknown(failure: NetworkFailure()),
        const AuthState.unknown(),
        AuthState.authenticated(tUser),
      ],
    );
  });

  blocTest<AuthBloc, AuthState>(
    'AuthLoggedIn makes the user authenticated',
    build: buildBloc,
    act: (bloc) => bloc.add(AuthLoggedIn(tUser)),
    expect: () => [AuthState.authenticated(tUser)],
  );

  blocTest<AuthBloc, AuthState>(
    'AuthUserUpdated replaces the user only when logged in',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(AuthUserUpdated(tRenamedUser));
      await Future<void>.delayed(Duration.zero);
      bloc
        ..add(AuthLoggedIn(tUser))
        ..add(AuthUserUpdated(tRenamedUser));
    },
    expect: () => [
      AuthState.authenticated(tUser),
      AuthState.authenticated(tRenamedUser),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'AuthLogoutRequested clears the token and logs out',
    seed: () => AuthState.authenticated(tUser),
    build: buildBloc,
    act: (bloc) => bloc.add(const AuthLogoutRequested()),
    expect: () => [const AuthState.unauthenticated()],
    verify: (_) => verify(() => logout()).called(1),
  );

  blocTest<AuthBloc, AuthState>(
    'logs out even if clearing the token fails',
    setUp: () =>
        when(() => logout())
            .thenAnswer((_) async => const Left(ServerFailure())),
    seed: () => AuthState.authenticated(tUser),
    build: buildBloc,
    act: (bloc) => bloc.add(const AuthLogoutRequested()),
    expect: () => [const AuthState.unauthenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'a 401 on a protected request ends the session',
    seed: () => AuthState.authenticated(tUser),
    build: buildBloc,
    act: (_) => expiry.add(null),
    expect: () => [const AuthState.unauthenticated(sessionExpired: true)],
  );

  blocTest<AuthBloc, AuthState>(
    'ignores session expiry when already logged out',
    seed: () => const AuthState.unauthenticated(),
    build: buildBloc,
    act: (_) => expiry.add(null),
    expect: () => <AuthState>[],
  );
}
