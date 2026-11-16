import 'package:easybook_app/features/appointments/domain/entities/appointment_status.dart';
import 'package:easybook_app/features/appointments/domain/entities/service_summary.dart';
import 'package:equatable/equatable.dart';

/// A booking made by the logged-in user.
class Appointment extends Equatable {
  const new({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.service,
    required this.createdAt,
    this.notes,
  });

  final String id;

  /// UTC. Convert with `.toLocal()` only for display.
  final DateTime startTime;
  final DateTime endTime;
  final AppointmentStatus status;
  final ServiceSummary service;
  final String? notes;
  final DateTime createdAt;

  bool get canCancel => status.canCancel;

  @override
  List<Object?> get props => [
    id,
    startTime,
    endTime,
    status,
    service,
    notes,
    createdAt,
  ];
}
