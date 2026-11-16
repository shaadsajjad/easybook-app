import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/auth/domain/entities/user.dart';
import 'package:easybook_app/features/auth/domain/usecases/logout.dart';
import 'package:easybook_app/features/auth/domain/usecases/restore_session.dart';
import 'package:easybook_app/features/auth/domain/usecases/watch_session_expired.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// The app-wide session. It is the only app-level bloc: the router listens
/// to it to decide between splash, login and the main tabs.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  new({
    required this._restoreSession,
    required this._logout,
    required WatchSessionExpired watchSessionExpired,
  }) : super(const AuthState.unknown()) {
    on<AuthSessionRequested>(_onSessionRequested);
    on<AuthLoggedIn>(_onLoggedIn);
    on<AuthUserUpdated>(_onUserUpdated);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSessionExpired>(_onSessionExpired);

    _expirySubscription = watchSessionExpired().listen(
      (_) => add(const AuthSessionExpired()),
    );
  }

  final RestoreSession _restoreSession;
  final Logout _logout;
  late final StreamSubscription<void> _expirySubscription;

  Future<void> _onSessionRequested(
    AuthSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    // On a retry, clear the previous error so splash shows progress again.
    if (state != const AuthState.unknown()) emit(const AuthState.unknown());
    final result = await _restoreSession();
    emit(
      result.fold(
        (failure) => AuthState.unknown(failure: failure),
        (user) => user == null
            ? const AuthState.unauthenticated()
            : AuthState.authenticated(user),
      ),
    );
  }

  void _onLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) {
    emit(AuthState.authenticated(event.user));
  }

  void _onUserUpdated(AuthUserUpdated event, Emitter<AuthState> emit) {
    if (state.status == AuthStatus.authenticated) {
      emit(AuthState.authenticated(event.user));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _logout();
    // Even if deleting the token failed, the user asked to leave, so the
    // app always shows the login screen.
    emit(
      result.fold(
        (_) => const AuthState.unauthenticated(),
        (_) => const AuthState.unauthenticated(),
      ),
    );
  }

  void _onSessionExpired(AuthSessionExpired event, Emitter<AuthState> emit) {
    // Only an active (or restoring) session can expire.
    if (state.status != AuthStatus.unauthenticated) {
      emit(const AuthState.unauthenticated(sessionExpired: true));
    }
  }

  @override
  Future<void> close() async {
    await _expirySubscription.cancel();
    await super.close();
  }
}
