import 'package:easybook_app/features/appointments/domain/entities/appointment.dart';
import 'package:easybook_app/features/appointments/domain/entities/appointment_status.dart';
import 'package:easybook_app/features/appointments/domain/entities/service_summary.dart';
import 'package:json_annotation/json_annotation.dart';

part 'appointment_model.g.dart';

/// The `Appointment` JSON from the API (with its service summary).
@JsonSerializable(createToJson: false)
class AppointmentModel {
  const new({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.service,
    required this.createdAt,
    this.notes,
  });

  factory fromJson(Map<String, dynamic> json) =>
      _$AppointmentModelFromJson(json);

  final String id;
  final DateTime startTime;
  final DateTime endTime;
  @JsonKey(fromJson: parseAppointmentStatus)
  final AppointmentStatus status;
  final ServiceSummaryModel service;
  final String? notes;
  final DateTime createdAt;

  Appointment toEntity() => Appointment(
    id: id,
    startTime: startTime,
    endTime: endTime,
    status: status,
    service: service.toEntity(),
    notes: notes,
    createdAt: createdAt,
  );
}

/// `service` inside an appointment. Price is a string, like everywhere.
@JsonSerializable(createToJson: false)
class ServiceSummaryModel {
  const new({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMinutes,
    required this.imageUrl,
    required this.category,
  });

  factory fromJson(Map<String, dynamic> json) =>
      _$ServiceSummaryModelFromJson(json);

  final String id;
  final String name;
  @JsonKey(fromJson: _parsePrice)
  final double price;
  final int durationMinutes;
  final String imageUrl;
  final String category;

  ServiceSummary toEntity() => ServiceSummary(
    id: id,
    name: name,
    price: price,
    durationMinutes: durationMinutes,
    imageUrl: imageUrl,
    category: category,
  );
}

double _parsePrice(String value) => double.parse(value);

/// "PENDING" -> AppointmentStatus.pending (the API uses upper case).
AppointmentStatus parseAppointmentStatus(String value) =>
    AppointmentStatus.values.byName(value.toLowerCase());
