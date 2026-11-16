import 'dart:async';

import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/network/request_guard.dart';
import 'package:easybook_app/features/appointments/data/datasources/appointments_remote_data_source.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment.dart';
import 'package:easybook_app/features/appointments/domain/entities/bookings_tab.dart';
import 'package:easybook_app/features/appointments/domain/repositories/appointments_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Registered once (singleton), so every screen hears [changes].
class AppointmentsRepositoryImpl implements AppointmentsRepository {
  new(this._remote);

  final AppointmentsRemoteDataSource _remote;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Stream<void> get changes => _changes.stream;

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
      _changes.add(null);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, List<Appointment>>> getAppointments(BookingsTab tab) {
    return guardRequest(() async {
      final models = await _remote.getAppointments(tab);
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, Appointment>> getAppointmentById(String id) {
    return guardRequest(() async {
      final model = await _remote.getAppointmentById(id);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, Appointment>> cancelAppointment(String id) {
    return guardRequest(() async {
      final model = await _remote.cancelAppointment(id);
      _changes.add(null);
      return model.toEntity();
    });
  }
}
