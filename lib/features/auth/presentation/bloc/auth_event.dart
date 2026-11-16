part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

/// App start (and "Try again" on the splash screen): check the stored token.
final class AuthSessionRequested extends AuthEvent {
  const new();
}

/// Login or register succeeded.
final class AuthLoggedIn extends AuthEvent {
  const new(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

/// The profile changed (step 7 sends this after an edit).
final class AuthUserUpdated extends AuthEvent {
  const new(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

/// The user tapped "Log out".
final class AuthLogoutRequested extends AuthEvent {
  const new();
}

/// A protected request returned 401 (sent by the bloc itself).
final class AuthSessionExpired extends AuthEvent {
  const new();
}
