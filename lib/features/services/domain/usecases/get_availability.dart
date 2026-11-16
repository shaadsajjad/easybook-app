import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/utils/date_formatter.dart';
import 'package:easybook_app/features/services/domain/entities/availability.dart';
import 'package:easybook_app/features/services/domain/repositories/services_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

class GetAvailabilityParams extends Equatable {
  const new({required this.serviceId, required this.day});

  final String serviceId;

  /// The picked calendar day (only year, month and day are used).
  final DateTime day;

  @override
  List<Object> get props => [serviceId, day];
}

class GetAvailability {
  const new(this._repository);

  final ServicesRepository _repository;

  Future<Either<Failure, Availability>> call(GetAvailabilityParams params) =>
      _repository.getAvailability(
        serviceId: params.serviceId,
        date: DateFormatter.toApiDate(params.day),
      );
}
