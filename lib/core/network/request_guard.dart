import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/network/error_mapper.dart';
import 'package:fpdart/fpdart.dart';

/// Runs a data-source call and wraps the outcome in an [Either]:
/// the value on success, or a [Failure] built by [mapExceptionToFailure].
///
/// Every repository uses this, so no repository repeats try/catch logic.
Future<Either<Failure, T>> guardRequest<T>(Future<T> Function() request) async {
  try {
    return Right(await request());
  } on Object catch (error) {
    return Left(mapExceptionToFailure(error));
  }
}
