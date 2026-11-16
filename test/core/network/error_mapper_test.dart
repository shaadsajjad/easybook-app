import 'package:dio/dio.dart';
import 'package:easybook_app/core/error/exceptions.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/network/error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _badResponse(int status, Object? body) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<Object?>(
      requestOptions: options,
      statusCode: status,
      data: body,
    ),
  );
}

void main() {
  group('mapDioException', () {
    test('reads status, message and field errors from a bad response', () {
      final error = mapDioException(
        _badResponse(422, {
          'success': false,
          'message': 'Validation failed',
          'errors': [
            {'field': 'email', 'message': 'Invalid'},
          ],
        }),
      );
      expect(error, isA<ApiException>());
      error as ApiException;
      expect(error.statusCode, 422);
      expect(error.message, 'Validation failed');
      expect(error.fieldErrors, {
        'email': ['Invalid'],
      });
    });

    test('treats timeouts and connection errors as network errors', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
        DioExceptionType.unknown,
      ]) {
        final error = DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: type,
        );
        expect(
          mapDioException(error),
          isA<NetworkException>(),
          reason: '$type',
        );
      }
    });
  });

  group('mapExceptionToFailure', () {
    test('maps each status code to its failure, keeping the message', () {
      final cases = <int, Type>{
        401: UnauthorizedFailure,
        404: NotFoundFailure,
        409: ConflictFailure,
        429: RateLimitFailure,
        502: ServiceUnavailableFailure,
        503: ServiceUnavailableFailure,
        500: ServerFailure,
        400: ServerFailure,
      };
      for (final MapEntry(key: status, value: type) in cases.entries) {
        final failure = mapExceptionToFailure(
          ApiException(statusCode: status, message: 'msg $status'),
        );
        expect(failure.runtimeType, type, reason: '$status');
        expect(failure.message, 'msg $status');
      }
    });

    test('maps 422 to a ValidationFailure with field errors', () {
      final failure = mapExceptionToFailure(
        const ApiException(
          statusCode: 422,
          message: 'Validation failed',
          fieldErrors: {
            'email': ['Invalid'],
          },
        ),
      );
      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).errorFor('email'), 'Invalid');
      expect(failure.errorFor('name'), isNull);
    });

    test('maps a DioException directly', () {
      final failure = mapExceptionToFailure(
        _badResponse(409, {'success': false, 'message': 'Taken'}),
      );
      expect(failure, const ConflictFailure('Taken'));
    });

    test('maps network, parsing and unknown errors', () {
      expect(
        mapExceptionToFailure(const NetworkException()),
        isA<NetworkFailure>(),
      );
      expect(
        mapExceptionToFailure(const ParsingException('bad')),
        isA<ServerFailure>(),
      );
      expect(mapExceptionToFailure(Exception('?')), isA<ServerFailure>());
    });
  });
}
