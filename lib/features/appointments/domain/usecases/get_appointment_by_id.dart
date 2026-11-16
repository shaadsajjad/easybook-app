import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment.dart';
import 'package:easybook_app/features/appointments/domain/repositories/appointments_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAppointmentById {
  const new(this._repository);

  final AppointmentsRepository _repository;

  Future<Either<Failure, Appointment>> call(String id) =>
      _repository.getAppointmentById(id);
}
