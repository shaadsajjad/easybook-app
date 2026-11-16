import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment.dart';
import 'package:easybook_app/features/appointments/domain/repositories/appointments_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

class CreateAppointmentParams extends Equatable {
  const new({required this.serviceId, required this.startTime, this.notes});

  final String serviceId;
  final String startTime;
  final String? notes;

  @override
  List<Object?> get props => [serviceId, startTime, notes];
}

class CreateAppointment {
  const new(this._repository);

  final AppointmentsRepository _repository;

  Future<Either<Failure, Appointment>> call(CreateAppointmentParams params) {
    // Empty notes are not sent at all.
    final notes = params.notes?.trim();
    return _repository.createAppointment(
      serviceId: params.serviceId,
      startTime: params.startTime,
      notes: notes == null || notes.isEmpty ? null : notes,
    );
  }
}
