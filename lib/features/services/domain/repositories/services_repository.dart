import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/services/domain/entities/service.dart';
import 'package:easybook_app/features/services/domain/entities/service_filter.dart';
import 'package:easybook_app/features/services/domain/entities/services_page.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ServicesRepository {
  /// Active services matching [filter], one page at a time.
  Future<Either<Failure, ServicesPage>> getServices({
    required ServiceFilter filter,
    required int page,
  });

  /// The featured services for the Home carousel.
  Future<Either<Failure, List<Service>>> getFeaturedServices();

  /// Category names for the filter chips.
  Future<Either<Failure, List<String>>> getCategories();

  Future<Either<Failure, Service>> getServiceById(String id);
}
