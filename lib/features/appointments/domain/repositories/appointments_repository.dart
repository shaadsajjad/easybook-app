import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment.dart';
import 'package:easybook_app/features/appointments/domain/entities/bookings_tab.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AppointmentsRepository {
  /// Books [startTime] (sent exactly as the availability API returned it).
  /// A taken slot fails with a ConflictFailure (409).
  Future<Either<Failure, Appointment>> createAppointment({
    required String serviceId,
    required String startTime,
    String? notes,
  });

  /// The user's upcoming or past bookings, sorted by the server.
  Future<Either<Failure, List<Appointment>>> getAppointments(BookingsTab tab);

  /// One of the user's bookings. Someone else's id gives NotFoundFailure.
  Future<Either<Failure, Appointment>> getAppointmentById(String id);

  /// Cancels a PENDING booking. Other statuses give a ConflictFailure (409).
  Future<Either<Failure, Appointment>> cancelAppointment(String id);

  /// Emits after a booking is created or cancelled, so lists can refresh.
  Stream<void> get changes;
}
