import 'package:easybook_app/features/appointments/domain/repositories/appointments_repository.dart';

/// Emits after any booking is created or cancelled.
class WatchAppointmentChanges {
  const new(this._repository);

  final AppointmentsRepository _repository;

  Stream<void> call() => _repository.changes;
}
