/// Exceptions thrown by remote data sources. Repositories catch them and
/// turn them into a `Failure` with `mapExceptionToFailure`.
sealed class AppException implements Exception {
  const new(this.message);

  final String message;
}

/// The server answered with an error status (4xx / 5xx).
final class ApiException extends AppException {
  const new({
    required this.statusCode,
    required String message,
    this.fieldErrors = const {},
  }) : super(message);

  final int statusCode;
  final Map<String, List<String>> fieldErrors;

  @override
  String toString() => 'ApiException($statusCode, $message)';
}

/// The server could not be reached (offline, DNS, timeout).
final class NetworkException extends AppException {
  const new([super.message = '']);

  @override
  String toString() => 'NetworkException';
}

/// The response arrived but did not have the expected shape.
final class ParsingException extends AppException {
  const new([super.message = '']);

  @override
  String toString() => 'ParsingException($message)';
}
