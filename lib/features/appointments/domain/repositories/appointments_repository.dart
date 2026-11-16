import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AppointmentsRepository {
  /// Books [startTime] (sent exactly as the availability API returned it).
  /// A taken slot fails with a ConflictFailure (409).
  Future<Either<Failure, Appointment>> createAppointment({
    required String serviceId,
    required String startTime,
    String? notes,
  });
}
