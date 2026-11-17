import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/services/domain/entities/availability.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/domain/entities/service_filter.dart';
import 'package:easybook_app/features/services/domain/entities/services_page.dart';
import 'package:fpdart/fpdart.dart';

/// Services data. Read-only lists may be answered from a short-lived cache;
/// pass `forceRefresh: true` (pull to refresh) to always ask the API.
abstract interface class ServicesRepository {
  /// Active services matching [filter], one page at a time.
  Future<Either<Failure, ServicesPage>> getServices({
    required ServiceFilter filter,
    required int page,
    bool forceRefresh = false,
  });

  /// The featured services for the Home carousel.
  Future<Either<Failure, List<Service>>> getFeaturedServices({
    bool forceRefresh = false,
  });

  /// Category names for the filter chips.
  Future<Either<Failure, List<String>>> getCategories({
    bool forceRefresh = false,
  });

  Future<Either<Failure, Service>> getServiceById(
    String id, {
    bool forceRefresh = false,
  });

  /// Every slot of [date] ("yyyy-MM-dd", business time zone). Never
  /// cached: slots change whenever someone books.
  Future<Either<Failure, Availability>> getAvailability({
    required String serviceId,
    required String date,
  });
}
