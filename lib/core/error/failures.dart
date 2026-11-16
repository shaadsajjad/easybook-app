import 'package:equatable/equatable.dart';

/// Everything that can go wrong, as seen by the domain and presentation
/// layers. Repositories return `Either<Failure, T>`.
///
/// [message] is the API's own message (already friendly). It can be empty
/// when the app has no server message (for example no connection); the UI
/// then shows a localized fallback (see `FailureX.displayMessage`).
sealed class Failure extends Equatable {
  const new([this.message = '']);

  final String message;

  @override
  List<Object> get props => [message];
}

/// 422: the request broke a validation rule.
final class ValidationFailure extends Failure {
  const new(super.message, {this.fieldErrors = const {}});

  /// Field name -> messages, for example `email -> [Enter a valid email]`.
  final Map<String, List<String>> fieldErrors;

  /// The first message for [field], to show under that form field.
  String? errorFor(String field) => fieldErrors[field]?.first;

  @override
  List<Object> get props => [message, fieldErrors];
}

/// 401: missing, invalid or expired token, or wrong login details.
final class UnauthorizedFailure extends Failure {
  const new([super.message]);
}

/// 404: record or route not found (including someone else's booking).
final class NotFoundFailure extends Failure {
  const new([super.message]);
}

/// 409: email taken, slot already booked, booking can't be cancelled.
final class ConflictFailure extends Failure {
  const new([super.message]);
}

/// 429: too many requests.
final class RateLimitFailure extends Failure {
  const new([super.message]);
}

/// 502 / 503: the AI assistant is unavailable, busy or timed out.
final class ServiceUnavailableFailure extends Failure {
  const new([super.message]);
}

/// No connection or a timeout.
final class NetworkFailure extends Failure {
  const new([super.message]);
}

/// 500, other unexpected statuses, or a response we could not read.
final class ServerFailure extends Failure {
  const new([super.message]);
}
