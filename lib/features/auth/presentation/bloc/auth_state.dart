part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Who is using the app. The router redirects based on [status].
final class AuthState extends Equatable {
  /// Still checking the stored token. [failure] is set when the check
  /// could not finish (for example no internet), so splash shows a retry.
  const new unknown({this.failure})
    : status = AuthStatus.unknown,
      user = null,
      sessionExpired = false;

  const new authenticated(User this.user)
    : status = AuthStatus.authenticated,
      failure = null,
      sessionExpired = false;

  /// [sessionExpired] is true when the server ended the session, so the
  /// login screen can explain why the user is there.
  const new unauthenticated({this.sessionExpired = false})
    : status = AuthStatus.unauthenticated,
      user = null,
      failure = null;

  final AuthStatus status;
  final User? user;
  final Failure? failure;
  final bool sessionExpired;

  @override
  List<Object?> get props => [status, user, failure, sessionExpired];
}
