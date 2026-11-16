// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailabilityModel _$AvailabilityModelFromJson(Map<String, dynamic> json) =>
    AvailabilityModel(
      serviceId: json['serviceId'] as String,
      date: json['date'] as String,
      slots: (json['slots'] as List<dynamic>)
          .map((e) => TimeSlotModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

TimeSlotModel _$TimeSlotModelFromJson(Map<String, dynamic> json) =>
    TimeSlotModel(
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      available: json['available'] as bool,
    );
