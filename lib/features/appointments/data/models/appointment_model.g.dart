// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppointmentModel _$AppointmentModelFromJson(Map<String, dynamic> json) =>
    AppointmentModel(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: parseAppointmentStatus(json['status'] as String),
      service: ServiceSummaryModel.fromJson(
        json['service'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String?,
    );

ServiceSummaryModel _$ServiceSummaryModelFromJson(Map<String, dynamic> json) =>
    ServiceSummaryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: _parsePrice(json['price'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
    );
