import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/network/request_guard.dart';
import 'package:easybook_app/features/appointments/data/datasources/appointments_remote_data_source.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment.dart';
import 'package:easybook_app/features/appointments/domain/repositories/appointments_repository.dart';
import 'package:fpdart/fpdart.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  const new(this._remote);

  final AppointmentsRemoteDataSource _remote;

  @override
  Future<Either<Failure, Appointment>> createAppointment({
    required String serviceId,
    required String startTime,
    String? notes,
  }) {
    return guardRequest(() async {
      final model = await _remote.createAppointment(
        serviceId: serviceId,
        startTime: startTime,
        notes: notes,
      );
      return model.toEntity();
    });
  }
}
