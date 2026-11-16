import 'package:dio/dio.dart';
import 'package:easybook_app/core/error/exceptions.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/network/api_envelope.dart';

/// Turns a Dio error into one of our data-layer exceptions.
AppException mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.badResponse:
      final body = error.response?.data;
      return ApiException(
        statusCode: error.response?.statusCode ?? 500,
        message: ApiEnvelope.message(body) ?? '',
        fieldErrors: ApiEnvelope.fieldErrors(body),
      );
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.connectionError:
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      return const NetworkException();
  }
}

/// Turns anything a data source can throw into a [Failure].
///
/// Every repository uses this one function, so the status code -> Failure
/// rules are written (and tested) once.
Failure mapExceptionToFailure(Object error) {
  return switch (error) {
    DioException() => mapExceptionToFailure(mapDioException(error)),
    ApiException(statusCode: 422) => ValidationFailure(
      error.message,
      fieldErrors: error.fieldErrors,
    ),
    ApiException(statusCode: 401) => UnauthorizedFailure(error.message),
    ApiException(statusCode: 404) => NotFoundFailure(error.message),
    ApiException(statusCode: 409) => ConflictFailure(error.message),
    ApiException(statusCode: 429) => RateLimitFailure(error.message),
    ApiException(statusCode: 502 || 503) => ServiceUnavailableFailure(
      error.message,
    ),
    ApiException() => ServerFailure(error.message),
    NetworkException() => const NetworkFailure(),
    _ => const ServerFailure(),
  };
}
